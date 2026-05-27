/**
 * @file profiles.h
 * @brief Planteprofil-struct og predefinerede profiler.
 *
 * Hver profil definerer vandstrategi for en plantetype. Profilerne loades
 * fra NVS ved boot; hvis ingen er gemt, bruges fabriks-defaults herfra.
 */

#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Detection mode bestemmer hvilken sensor der primært driver pump-beslutninger.
 */
typedef enum {
    DETECT_MOISTURE = 0,   ///< Soil capacitive sensor (Monstera, Pothos)
    DETECT_WEIGHT,         ///< HX711 load cell (Orkide — bark medium)
    DETECT_HYBRID,         ///< Begge — moisture primær, weight sanity check (Succulenter)
} detection_mode_t;

/**
 * Plant profile struct. Lagres i NVS som binær blob.
 *
 * Total størrelse: ~48 bytes. Padding optimeret for 4-byte alignment.
 */
typedef struct {
    char name[16];                  ///< Profilnavn (null-terminated)
    detection_mode_t mode;          ///< Detektions-strategi

    // Soil moisture (relevant for DETECT_MOISTURE og DETECT_HYBRID)
    uint16_t adc_dry;               ///< ADC-værdi sensor i luft
    uint16_t adc_wet;               ///< ADC-værdi sensor i vand
    uint8_t target_min_pct;         ///< Pump trigger threshold (%)
    uint8_t target_max_pct;         ///< Pump stop threshold (%)

    // Weight (relevant for DETECT_WEIGHT og DETECT_HYBRID)
    int32_t weight_baseline_g;      ///< Tara-vægt sat ved init
    int32_t weight_dry_delta_g;     ///< Gram tabt før vanding (negativt tal)

    // Pump-styring (alle modes)
    uint16_t dose_ml;               ///< Ml per vandings-cyklus
    uint16_t cooldown_min;          ///< Min minutter mellem doseringer
    uint16_t daily_ml_cap;          ///< Max ml per døgn (safety)

    // Orkide soak-cyklus (kun relevant for DETECT_WEIGHT)
    uint16_t soak_seconds;          ///< Pump-tid per soak-burst
    uint8_t soak_repeats;           ///< Antal bursts per cyklus
    uint16_t soak_pause_seconds;    ///< Pause mellem bursts
} plant_profile_t;

/**
 * Index for fabriks-default profiler. Index matches PROFILE_DEFAULTS array.
 */
typedef enum {
    PROFILE_MONSTERA = 0,
    PROFILE_POTHOS,
    PROFILE_PEACE_LILY,
    PROFILE_SUCCULENT,
    PROFILE_ORCHID,
    PROFILE_CUSTOM,
    PROFILE_COUNT,
} profile_id_t;

/**
 * Predefinerede profiler. Defineret i profiles.c.
 * Se docs/plant-profiles.md for begrundelse for hver værdi.
 */
extern const plant_profile_t PROFILE_DEFAULTS[PROFILE_COUNT];

/**
 * Load aktiv profil fra NVS. Hvis intet er gemt, sættes PROFILE_DEFAULTS[PROFILE_MONSTERA].
 *
 * @param[out] profile Profil-struct der fyldes med data fra NVS.
 * @return 0 ved success, negativt ved fejl.
 */
int profile_load_from_nvs(plant_profile_t *profile);

/**
 * Gem profil til NVS. Persister på tværs af reboots.
 *
 * @param[in] profile Profil-data der gemmes.
 * @return 0 ved success, negativt ved fejl.
 */
int profile_save_to_nvs(const plant_profile_t *profile);

/**
 * Beregn moisture i procent ud fra rå ADC-værdi og profil-kalibrering.
 *
 * @param adc_reading Rå ADC-værdi fra soil sensor (0-4095 for 12-bit).
 * @param profile Aktiv profil (bruger adc_dry og adc_wet).
 * @return Moisture i % (0-100), clampet.
 */
uint8_t profile_moisture_pct(uint16_t adc_reading, const plant_profile_t *profile);

/**
 * Beslut om pumpen skal trigges, baseret på sensor-state og aktiv profil.
 *
 * @param moisture_pct Aktuel jord-fugtighed (%).
 * @param weight_g Aktuel plante-vægt (gram).
 * @param last_pump_minutes_ago Minutter siden sidste vanding.
 * @param daily_ml_so_far Ml vandet i dag (siden midnat).
 * @param profile Aktiv profil.
 * @return true hvis pumpen skal trigges, false ellers.
 */
bool profile_should_pump(uint8_t moisture_pct,
                          int32_t weight_g,
                          uint32_t last_pump_minutes_ago,
                          uint16_t daily_ml_so_far,
                          const plant_profile_t *profile);

#ifdef __cplusplus
}
#endif
