/**
 * @file test_main.cpp
 * @brief Native unit tests for profiles.cpp + temp_humidity.cpp (pure math).
 *
 * Kør: pio test -e native_test
 */

#include <unity.h>
#include <cmath>

#include "profiles.h"
#include "temp_humidity.h"

void setUp(void) {}
void tearDown(void) {}


// ─── profile_moisture_pct ────────────────────────────────────────────────────

static void test_moisture_pct_endpoints(void)
{
    const plant_profile_t *m = &PROFILE_DEFAULTS[PROFILE_MONSTERA];
    TEST_ASSERT_EQUAL_UINT8(0,   profile_moisture_pct(3000, m));  // = adc_dry
    TEST_ASSERT_EQUAL_UINT8(100, profile_moisture_pct(1200, m));  // = adc_wet
    TEST_ASSERT_EQUAL_UINT8(50,  profile_moisture_pct(2100, m));  // midtpunkt
}

static void test_moisture_pct_clamps(void)
{
    const plant_profile_t *m = &PROFILE_DEFAULTS[PROFILE_MONSTERA];
    TEST_ASSERT_EQUAL_UINT8(0,   profile_moisture_pct(4000, m));  // over dry
    TEST_ASSERT_EQUAL_UINT8(100, profile_moisture_pct(500, m));   // under wet
}


// ─── profile_should_pump ─────────────────────────────────────────────────────

static void test_should_pump_moisture_mode(void)
{
    const plant_profile_t *m = &PROFILE_DEFAULTS[PROFILE_MONSTERA];
    // target_min 35, cooldown 360, daily cap 100
    TEST_ASSERT_TRUE(profile_should_pump(30, 0, 400, 0, m));      // tør, klar
    TEST_ASSERT_FALSE(profile_should_pump(40, 0, 400, 0, m));     // ikke tør
    TEST_ASSERT_FALSE(profile_should_pump(30, 0, 100, 0, m));     // cooldown
    TEST_ASSERT_FALSE(profile_should_pump(30, 0, 400, 100, m));   // daily cap
}

static void test_should_pump_wick_only_never_pumps(void)
{
    const plant_profile_t *av = &PROFILE_DEFAULTS[PROFILE_AFRICAN_VIOLET];
    TEST_ASSERT_FALSE(profile_should_pump(0, 0, 99999, 0, av));
}

static void test_should_pump_weight_mode(void)
{
    plant_profile_t orchid = PROFILE_DEFAULTS[PROFILE_ORCHID];
    orchid.weight_baseline_g = 1200;  // tara sat (delta er -80)
    TEST_ASSERT_TRUE(profile_should_pump(0, 1120, 99999, 0, &orchid));
    TEST_ASSERT_FALSE(profile_should_pump(0, 1150, 99999, 0, &orchid));
}


// ─── profile_validate (ADR 004 hardware-mismatch) ───────────────────────────

static void test_validate_weight_requires_loadcell(void)
{
    const plant_profile_t *orchid = &PROFILE_DEFAULTS[PROFILE_ORCHID];
    const plant_profile_t *m = &PROFILE_DEFAULTS[PROFILE_MONSTERA];
    TEST_ASSERT_FALSE(profile_validate(orchid, false));
    TEST_ASSERT_TRUE(profile_validate(orchid, true));
    TEST_ASSERT_TRUE(profile_validate(m, false));  // moisture behøver ikke vægt
}


// ─── VPD math (ADR 007) ─────────────────────────────────────────────────────

static void test_tetens_known_values(void)
{
    // Kendte referenceværdier: es(20°C) ≈ 2.34 kPa, es(25°C) ≈ 3.17 kPa
    TEST_ASSERT_FLOAT_WITHIN(0.02f, 2.34f, env_saturation_vapor_pressure(20.0f));
    TEST_ASSERT_FLOAT_WITHIN(0.03f, 3.17f, env_saturation_vapor_pressure(25.0f));
}

static void test_vpd_dose_scale_reference_and_clamps(void)
{
    // 22°C/50% RH ≈ komfort-reference → scale ≈ 1.0
    float vpd = env_calculate_vpd(22.0f, 50.0f);
    TEST_ASSERT_FLOAT_WITHIN(0.05f, 1.0f, env_vpd_dose_scale(vpd));

    TEST_ASSERT_EQUAL_FLOAT(2.0f, env_vpd_dose_scale(10.0f));  // clamp max
    TEST_ASSERT_EQUAL_FLOAT(0.5f, env_vpd_dose_scale(0.1f));   // clamp min
}

static void test_effective_dose(void)
{
    const plant_profile_t *m = &PROFILE_DEFAULTS[PROFILE_MONSTERA];
    // monstera 50ml: VPD 2.6 → scale 2.0 → 100ml. Uden env-sensor: uændret.
    TEST_ASSERT_EQUAL_UINT16(100, profile_effective_dose_ml(m, 2.6f, true));
    TEST_ASSERT_EQUAL_UINT16(50,  profile_effective_dose_ml(m, 2.6f, false));
}


int main(int, char **)
{
    UNITY_BEGIN();
    RUN_TEST(test_moisture_pct_endpoints);
    RUN_TEST(test_moisture_pct_clamps);
    RUN_TEST(test_should_pump_moisture_mode);
    RUN_TEST(test_should_pump_wick_only_never_pumps);
    RUN_TEST(test_should_pump_weight_mode);
    RUN_TEST(test_validate_weight_requires_loadcell);
    RUN_TEST(test_tetens_known_values);
    RUN_TEST(test_vpd_dose_scale_reference_and_clamps);
    RUN_TEST(test_effective_dose);
    return UNITY_END();
}
