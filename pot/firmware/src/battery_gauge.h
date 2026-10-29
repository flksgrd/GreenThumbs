/**
 * @file battery_gauge.h
 * @brief MAX17048 fuel gauge (batteriniveau til HomeKit) — ADR 016.
 *
 * MAX17048 sidder på I2C-bussen (0x36) og forsynes direkte fra cellen
 * (VDD = TP4056 OUT+). ModelGauge-algoritmen giver SOC i % uden
 * strømmåler; 3 µA i hibernate, som den selv vælger ved lav belastning.
 *
 * VIGTIGT: skriv aldrig MODE.EnSleep = 1. I pot/ slukkes I2C-bussens
 * pull-ups sammen med sensor-skinnen, og med EnSleep sat ville lave
 * SDA/SCL (> 2,5 s) sende måleren i sleep, hvor den holder op med at måle.
 */

#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MAX17048_I2C_ADDR   0x36
#define MAX17048_REG_VCELL  0x02    ///< 78,125 µV/LSB
#define MAX17048_REG_SOC    0x04    ///< 1/256 %/LSB
#define MAX17048_REG_MODE   0x06    ///< EnSleep — rør ikke (se ovenfor)
#define MAX17048_REG_VERSION 0x08   ///< 0x001_ — bruges til at finde chippen

#define BATTERY_LOW_PCT     15      ///< HomeKit "lavt batteri"

/** VCELL-registeret (big-endian 16 bit) → cellespænding i volt. */
float max17048_vcell_v(uint16_t raw);

/** SOC-registeret (big-endian 16 bit) → state of charge i %, clampet 0-100. */
float max17048_soc_pct(uint16_t raw);

/**
 * Initialiser måleren (tjek VERSION-registeret).
 * @return 0 ved success, negativt hvis chippen ikke svarer.
 */
int battery_gauge_init(void);

/**
 * Læs SOC og cellespænding.
 * pot/: sensor-skinnen (GPIO23) skal være tændt, ellers har bussen ingen pull-ups.
 * @return 0 ved success, negativt ved I2C-fejl.
 */
int battery_gauge_read(float *soc_pct, float *vcell_v);

#ifdef __cplusplus
}
#endif
