/**
 * @file temp_humidity.h
 * @brief SHT41 temperatur + fugtigheds-sensor driver + VPD calculation.
 *
 * SHT41 sidder på I2C (GPIO4 SDA / GPIO5 SCL, adresse 0x44). Sampler hver
 * 60. sek; rum-klima ændres langsomt så høj samplerate er ikke nødvendigt.
 * Varmeren (0x39) kan genoprette sensoren efter lang tid ved høj fugt —
 * max 5% duty cycle, og målinger under opvarmning er ikke gyldige.
 *
 * Hovedformål for projektet:
 *   1. VPD-baseret dose-modifikator i control_task
 *   2. Reservoir-fordampning prediction
 *   3. HomeKit room-climate sensors (extra value)
 *   4. Termisk drift-kompensation for HX711-aflæsninger
 *
 * Se ADR 007 (miljøsensor) og ADR 015 (SHT41 i stedet for AHT20).
 */

#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define SHT41_I2C_ADDR         0x44      ///< SHT41-AD1B (7-bit)
#define SHT41_CMD_MEASURE_HP   0xFD      ///< T + RH, høj præcision (max 8,3 ms)
#define SHT41_CMD_HEATER_1S    0x39      ///< 200 mW i 1 s + måling (genopretning)
#define SHT41_CMD_SOFT_RESET   0x94
#define SHT41_MEAS_DELAY_MS    10        ///< Tid efter trigger før read

#define ENV_SAMPLE_INTERVAL_MS 60000     ///< Sample-frekvens (1 minut)
#define ENV_VPD_REFERENCE_KPA  1.3f      ///< 22°C / 50% RH = komfortabelt
#define ENV_VPD_SCALE_MIN      0.5f      ///< Min dose-scale faktor
#define ENV_VPD_SCALE_MAX      2.0f      ///< Max dose-scale faktor

/**
 * Resultat af en environmental måling.
 */
typedef struct {
    float temp_c;        ///< Temperatur (-40 til +85 °C)
    float humidity_pct;  ///< Relativ luftfugtighed (0-100 %RH)
    float vpd_kpa;       ///< Beregnet Vapor Pressure Deficit (kPa)
    uint32_t timestamp_ms; ///< Boot-time millis ved måling
    bool valid;          ///< False hvis I2C-fejl eller CRC-mismatch
} env_reading_t;

/**
 * Initialiser I2C-master + SHT41-sensor.
 *
 * Skal kaldes én gang ved boot. Hvis init fejler (fx ingen SHT41 tilstede),
 * returneres negativ værdi og firmware fortsætter uden environmental sensing
 * (graceful degradation — se ADR 007).
 *
 * @return 0 ved success, negativt ved fejl.
 */
int env_sensor_init(void);

/**
 * Trigger måling og læs resultatet.
 *
 * Blokerer i ~10ms under SHT41 conversion. Kald fra sensor_task med passende
 * interval (ENV_SAMPLE_INTERVAL_MS).
 *
 * @param[out] out Resultat-struct fyldes ved success. .valid sættes til
 *                 true ved gyldig måling, false ved fejl.
 * @return 0 ved success, negativt ved fejl. out->valid afspejler ligeledes.
 */
int env_sensor_read(env_reading_t *out);

/**
 * Tjek om environmental sensor er tilgængelig.
 *
 * Sat til true hvis env_sensor_init() lykkedes ved boot. Andre tasks bør
 * tjekke dette før de stoler på env-data.
 *
 * @return true hvis SHT41 er aktiv.
 */
bool env_sensor_available(void);

// ─── SHT4x protokol (pure functions, kan unit-testes native) ────────────────

/**
 * Sensirion CRC-8: polynomium 0x31, init 0xFF, ingen final XOR.
 * Datablad-eksempel: CRC(0xBE, 0xEF) = 0x92.
 */
uint8_t sht4x_crc8(const uint8_t *data, int len);

/**
 * Pars 6 bytes fra en måling: [T_msb, T_lsb, T_crc, RH_msb, RH_lsb, RH_crc].
 *   T  = -45 + 175 · ticks / 65535      [°C]
 *   RH =  -6 + 125 · ticks / 65535      [%], clampet til 0-100
 *
 * @return 0 ved success, -1 ved CRC-fejl (out-parametre urørte).
 */
int sht4x_parse(const uint8_t raw[6], float *temp_c, float *humidity_pct);

// ─── VPD calculations (pure functions, kan unit-testes native) ──────────────

/**
 * Saturation vapor pressure (Tetens formel) — kPa.
 *
 * Approximation valid i temperaturområdet -10°C til +50°C, hvilket
 * dækker indeklima.
 *
 * @param temp_c Lufttemperatur i Celsius.
 * @return Mætnings-damptryk i kPa.
 */
float env_saturation_vapor_pressure(float temp_c);

/**
 * Vapor Pressure Deficit (kPa).
 *
 * VPD er den korrekte fysiologiske metric for plante-transpiration.
 *   - VPD < 0.4 kPa  → meget fugtig, lavt transpirations-krav
 *   - VPD 0.8-1.2 kPa → ideelt for de fleste indendørs planter
 *   - VPD > 2.0 kPa  → tørt, høj transpirations-stress
 *
 * @param temp_c Lufttemperatur i Celsius.
 * @param humidity_pct Relativ luftfugtighed (0-100 %).
 * @return VPD i kPa.
 */
float env_calculate_vpd(float temp_c, float humidity_pct);

/**
 * Beregn dose-scaling faktor baseret på aktuel VPD.
 *
 * Lineær skalering vs reference (1.3 kPa ≈ 22°C/50%RH), clampet til
 * [ENV_VPD_SCALE_MIN, ENV_VPD_SCALE_MAX] for sikkerhed.
 *
 *   scale = clamp(VPD / 1.3, 0.5, 2.0)
 *
 * Brug: `actual_dose_ml = profile.dose_ml * scale;`
 *
 * @param vpd_kpa Aktuel VPD i kPa.
 * @return Scale-faktor, dimensions-løs.
 */
float env_vpd_dose_scale(float vpd_kpa);

#ifdef __cplusplus
}
#endif
