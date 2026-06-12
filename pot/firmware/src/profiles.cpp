/**
 * @file profiles.cpp
 * @brief Planteprofiler — factory defaults + beslutningslogik.
 *
 * Threshold-logik og dose-beregning er fuldt implementeret (pure functions,
 * native-testbare). NVS-persistens er stub indtil Fase 1.
 *
 * Profil-værdier dokumenteret i docs/plant-profiles.md — ret dem DÉR først,
 * og synk derefter hertil.
 */

#include "profiles.h"
#include "temp_humidity.h"

#include <string.h>

// =============================================================================
// Factory defaults — se docs/plant-profiles.md for begrundelser
// =============================================================================
// adc_dry/adc_wet er typiske startværdier (DFRobot capacitive v2 @ 3.3V);
// overskrives af reel kalibrering per sensor (docs/calibration.md).
//
// Felt-rækkefølge: name, mode, adc_dry, adc_wet, target_min, target_max,
//                  weight_baseline_g, weight_dry_delta_g,
//                  dose_ml, cooldown_min, daily_ml_cap,
//                  soak_seconds, soak_repeats, soak_pause_seconds

const plant_profile_t PROFILE_DEFAULTS[PROFILE_COUNT] = {
    // PROFILE_MONSTERA — tropisk, moisture-styret, top-drip
    { "monstera",       DETECT_MOISTURE, 3000, 1200, 35, 55,
      0, 0,
      50, 360, 100,
      0, 0, 0 },

    // PROFILE_POTHOS — tørke-tolerant tropisk
    { "pothos",         DETECT_MOISTURE, 3000, 1200, 30, 50,
      0, 0,
      30, 720, 60,
      0, 0, 0 },

    // PROFILE_PEACE_LILY — fugt-elsker, wick anbefales
    { "peace_lily",     DETECT_MOISTURE, 3000, 1200, 40, 60,
      0, 0,
      40, 480, 100,
      0, 0, 0 },

    // PROFILE_AFRICAN_VIOLET — wick-ONLY: dose 0, pumpe aldrig aktiv
    { "african_violet", DETECT_MOISTURE, 3000, 1200, 35, 50,
      0, 0,
      0, 0, 0,
      0, 0, 0 },

    // PROFILE_SUCCULENT — minimal vanding, lange tørre perioder, INGEN wick
    { "succulent",      DETECT_MOISTURE, 3000, 1200, 10, 20,
      0, 0,
      15, 4320, 15,
      0, 0, 0 },

    // PROFILE_ORCHID — vægt-styret soak-cyklus (kræver HX711, ADR 004)
    { "orchid_phal",    DETECT_WEIGHT,   0, 0, 0, 0,
      0, -80,
      0, 10080, 100,
      10, 3, 30 },

    // PROFILE_CUSTOM — konservative defaults, alt bruger-redigerbart
    { "custom",         DETECT_MOISTURE, 3000, 1200, 25, 45,
      0, 0,
      25, 720, 50,
      0, 0, 0 },
};


// =============================================================================
// NVS-persistens — stub indtil Fase 1 (kræver ESP-IDF nvs_flash API)
// =============================================================================

int profile_load_from_nvs(plant_profile_t *profile)
{
    // TODO Fase 1: nvs_open("greenthumbs") → nvs_get_blob("profile")
    // Returnér -1 så main.cpp falder tilbage på PROFILE_DEFAULTS[MONSTERA].
    (void)profile;
    return -1;
}

int profile_save_to_nvs(const plant_profile_t *profile)
{
    // TODO Fase 1: nvs_set_blob + nvs_commit
    (void)profile;
    return -1;
}


// =============================================================================
// Beslutningslogik — pure functions, native-testbare
// =============================================================================

uint8_t profile_moisture_pct(uint16_t adc_reading, const plant_profile_t *profile)
{
    // Kapacitiv sensor: højere ADC = tørrere. pct = 100*(dry-x)/(dry-wet)
    if (profile == NULL || profile->adc_dry <= profile->adc_wet) {
        return 0;  // ukalibreret eller defekt config — rapportér tørt (fail-safe
                   // mod over-vanding sker via cooldown + daily cap, ikke her)
    }

    if (adc_reading >= profile->adc_dry) return 0;
    if (adc_reading <= profile->adc_wet) return 100;

    uint32_t span = (uint32_t)(profile->adc_dry - profile->adc_wet);
    uint32_t above_wet = (uint32_t)(profile->adc_dry - adc_reading);
    return (uint8_t)(100u * above_wet / span);
}

bool profile_should_pump(uint8_t moisture_pct,
                          int32_t weight_g,
                          uint32_t last_pump_minutes_ago,
                          uint16_t daily_ml_so_far,
                          const plant_profile_t *profile)
{
    if (profile == NULL) return false;

    // Wick-only profiler (dose 0) pumper aldrig
    if (profile->dose_ml == 0 && profile->mode == DETECT_MOISTURE) {
        // orchid har også dose_ml = 0 men bruger soak_seconds — undtag WEIGHT-mode
        return false;
    }

    // Safety: cooldown mellem doseringer
    if (last_pump_minutes_ago < profile->cooldown_min) return false;

    // Safety: dagligt loft
    if (profile->daily_ml_cap > 0 && daily_ml_so_far >= profile->daily_ml_cap) {
        return false;
    }

    bool moisture_dry = (moisture_pct < profile->target_min_pct);
    bool weight_dry =
        (weight_g <= profile->weight_baseline_g + profile->weight_dry_delta_g);
    // weight_dry_delta_g er negativ: baseline 1200 + (-80) = trigger ved <= 1120g

    switch (profile->mode) {
    case DETECT_MOISTURE:
        return moisture_dry;
    case DETECT_WEIGHT:
        return weight_dry;
    case DETECT_HYBRID:
        return moisture_dry && weight_dry;
    default:
        return false;
    }
}

uint16_t profile_effective_dose_ml(const plant_profile_t *profile,
                                    float vpd_kpa,
                                    bool env_available)
{
    if (profile == NULL) return 0;
    if (!env_available) return profile->dose_ml;  // graceful degradation

    float scaled = (float)profile->dose_ml * env_vpd_dose_scale(vpd_kpa);
    return (uint16_t)(scaled + 0.5f);
}

bool profile_validate(const plant_profile_t *profile, bool weight_available)
{
    if (profile == NULL) return false;

    if ((profile->mode == DETECT_WEIGHT || profile->mode == DETECT_HYBRID)
        && !weight_available) {
        return false;  // profil kræver load cell der ikke er installeret (ADR 004)
    }
    return true;
}
