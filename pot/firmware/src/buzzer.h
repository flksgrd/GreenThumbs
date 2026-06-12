/**
 * @file buzzer.h
 * @brief Passiv piezo buzzer driver — refill-indikator + fejl-signalering.
 *
 * Buzzer på D2 (GPIO2) drives med PWM via ESP32 LEDC. Bruges KUN i
 * refill-mode og ved fejl — aldrig periodisk (ingen irriterende bip).
 *
 * Se ADR 008 for designvalg og beep-mønstre.
 */

#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Foruddefinerede beep-mønstre. Se ADR 008.
 */
typedef enum {
    BUZZ_REFILL_PROGRESS = 0,  ///< Kort beep, pitch stiger med vandstand (25/50/75%)
    BUZZ_REFILL_FULL,          ///< Dobbelt-beep — "stop påfyldning" (≥95%)
    BUZZ_ERROR,                ///< Lav buzz 200 Hz 1s — profil/hardware mismatch
    BUZZ_LOW_WATER,            ///< Tre korte beeps — float switch alarm
} buzzer_pattern_t;

/**
 * Initialiser LEDC PWM-kanal for buzzer-pin.
 *
 * @return 0 ved success, negativt ved fejl.
 */
int buzzer_init(void);

/**
 * Spil en enkelt tone.
 *
 * Blokerer i duration_ms (kald fra lav-prioritets task, ikke ISR).
 *
 * @param freq_hz Tone-frekvens (typisk 1000-4000 Hz; piezo-resonans ~2-4 kHz).
 * @param duration_ms Varighed i millisekunder.
 */
void buzzer_beep(uint16_t freq_hz, uint16_t duration_ms);

/**
 * Spil et foruddefineret mønster.
 *
 * For BUZZ_REFILL_PROGRESS bruges level_pct til pitch-mapping:
 * pitch = 1500 + level_pct * 20 Hz (25% → 2000 Hz, 75% → 3000 Hz).
 *
 * @param pattern Mønster fra buzzer_pattern_t.
 * @param level_pct Vandstand i % — kun brugt af BUZZ_REFILL_PROGRESS, ellers 0.
 */
void buzzer_pattern(buzzer_pattern_t pattern, uint8_t level_pct);

#ifdef __cplusplus
}
#endif
