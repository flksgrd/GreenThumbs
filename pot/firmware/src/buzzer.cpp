/**
 * @file buzzer.cpp
 * @brief Passiv piezo buzzer driver implementation.
 *
 * STATUS: Skeleton — LEDC-opsætning implementeres i Fase 1.
 */

#include "buzzer.h"

#ifndef NATIVE_TEST
#include "driver/ledc.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const char *TAG = "buzzer";
#endif

int buzzer_init(void)
{
#ifdef NATIVE_TEST
    return -1;
#else
    // TODO Fase 1: LEDC setup
    //   1. ledc_timer_config: LEDC_TIMER_0, 10-bit resolution, 2000 Hz default
    //   2. ledc_channel_config: GPIO2 (D2), duty 0 (off)
    //   3. Frekvens ændres per beep via ledc_set_freq()
    ESP_LOGW(TAG, "buzzer_init: TODO (Fase 1)");
    return 0;
#endif
}

void buzzer_beep(uint16_t freq_hz, uint16_t duration_ms)
{
#ifdef NATIVE_TEST
    (void)freq_hz;
    (void)duration_ms;
#else
    // TODO Fase 1:
    //   1. ledc_set_freq(freq_hz)
    //   2. ledc_set_duty 50% + update
    //   3. vTaskDelay(duration_ms)
    //   4. duty 0 (off)
    (void)freq_hz;
    (void)duration_ms;
#endif
}

void buzzer_pattern(buzzer_pattern_t pattern, uint8_t level_pct)
{
    switch (pattern) {
    case BUZZ_REFILL_PROGRESS:
        // Pitch stiger med vandstand: 25% → 2000 Hz, 75% → 3000 Hz
        buzzer_beep(1500 + (uint16_t)level_pct * 20, 100);
        break;

    case BUZZ_REFILL_FULL:
        buzzer_beep(3500, 150);
        // TODO Fase 1: 80ms pause mellem beeps (vTaskDelay)
        buzzer_beep(3500, 150);
        break;

    case BUZZ_ERROR:
        buzzer_beep(200, 1000);
        break;

    case BUZZ_LOW_WATER:
        // TODO Fase 1: 3× beep med 100ms pause
        buzzer_beep(2500, 80);
        buzzer_beep(2500, 80);
        buzzer_beep(2500, 80);
        break;
    }
}
