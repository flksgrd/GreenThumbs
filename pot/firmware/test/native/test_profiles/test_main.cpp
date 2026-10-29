/**
 * @file test_main.cpp
 * @brief Native unit tests for profiles.cpp + temp_humidity.cpp (pure math + SHT4x).
 *
 * Kør: pio test -e native_test
 */

#include <unity.h>
#include <cmath>

#include "profiles.h"
#include "temp_humidity.h"
#include "battery_gauge.h"

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


// ─── SHT4x (CRC + konvertering, Sensirion-datablad) ──────────────────────────

static void test_sht4x_crc_datasheet_example(void)
{
    const uint8_t d[2] = {0xBE, 0xEF};
    TEST_ASSERT_EQUAL_HEX8(0x92, sht4x_crc8(d, 2));
}

static void make_frame(uint16_t t, uint16_t rh, uint8_t out[6])
{
    out[0] = t >> 8;  out[1] = t & 0xFF;  out[2] = sht4x_crc8(&out[0], 2);
    out[3] = rh >> 8; out[4] = rh & 0xFF; out[5] = sht4x_crc8(&out[3], 2);
}

static void test_sht4x_parse_known_values(void)
{
    uint8_t f[6];
    float t, rh;
    make_frame(26214, 29360, f);        // 0,4·65535 → 25 °C; → ~50 %RH
    TEST_ASSERT_EQUAL_INT(0, sht4x_parse(f, &t, &rh));
    TEST_ASSERT_FLOAT_WITHIN(0.01f, 25.0f, t);
    TEST_ASSERT_FLOAT_WITHIN(0.01f, 50.0f, rh);
}

static void test_sht4x_parse_clamps_and_crc(void)
{
    uint8_t f[6];
    float t = 0, rh = 0;
    make_frame(26214, 0xFFFF, f);       // RH-formlen giver 119 % → 100
    TEST_ASSERT_EQUAL_INT(0, sht4x_parse(f, &t, &rh));
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 100.0f, rh);
    make_frame(26214, 0, f);            // -6 % → 0
    sht4x_parse(f, &t, &rh);
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 0.0f, rh);
    f[5] ^= 0x01;                       // ødelagt CRC → fejl
    TEST_ASSERT_EQUAL_INT(-1, sht4x_parse(f, &t, &rh));
}


// ─── MAX17048 (registerformater fra databladet) ──────────────────────────────

static void test_max17048_vcell(void)
{
    TEST_ASSERT_FLOAT_WITHIN(0.0001f, 3.7f, max17048_vcell_v(47360));   // 47360·78,125 µV
    TEST_ASSERT_FLOAT_WITHIN(0.0001f, 0.0f, max17048_vcell_v(0));
}

static void test_max17048_soc(void)
{
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 50.5f, max17048_soc_pct(0x3280));  // 0x32 = 50 %, 0x80 = ½
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 100.0f, max17048_soc_pct(0x6500)); // 101 % → 100
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
    RUN_TEST(test_sht4x_crc_datasheet_example);
    RUN_TEST(test_sht4x_parse_known_values);
    RUN_TEST(test_sht4x_parse_clamps_and_crc);
    RUN_TEST(test_max17048_vcell);
    RUN_TEST(test_max17048_soc);
    return UNITY_END();
}
