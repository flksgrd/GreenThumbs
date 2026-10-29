/**
 * @file temp_humidity.cpp
 * @brief SHT41 driver implementation + VPD math.
 *
 * STATUS: Skeleton — SHT4x-CRC/-konvertering og VPD virker (pure, testet
 * native); I2C-kaldene implementeres i Fase 1 firmware bring-up.
 */

#include "temp_humidity.h"

#include <math.h>
#include <string.h>

// ESP-IDF headers (kun tilgængelige når PlatformIO har installeret SDK)
#ifndef NATIVE_TEST
#include "driver/i2c_master.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#endif

static const char *TAG = "env_sensor";

// Module state — sat ved init, læst af andre funktioner
static bool g_sensor_available = false;

#ifndef NATIVE_TEST
static i2c_master_bus_handle_t g_i2c_bus = NULL;
static i2c_master_dev_handle_t g_sht41_dev = NULL;
#endif


// ─── I2C / SHT41 funktioner ─────────────────────────────────────────────────

int env_sensor_init(void)
{
#ifdef NATIVE_TEST
    // Native test build — ingen I2C tilgængelig
    g_sensor_available = false;
    return -1;
#else
    // TODO Fase 1: implementer I2C bus + SHT41 device init
    //
    // Steps:
    //   1. i2c_new_master_bus() med SDA = GPIO4, SCL = GPIO5 (pot/: sensor-
    //      skinnen skal være tændt først — GPIO23 LOW)
    //   2. i2c_master_bus_add_device() med SHT41_I2C_ADDR
    //   3. Send SHT41_CMD_SOFT_RESET, vent 1 ms
    //   4. Læs serienummer (0x89, 6 bytes) og tjek CRC → sensoren svarer
    //   5. Hvis OK → g_sensor_available = true, returnér 0
    //   6. Ellers → log warning, g_sensor_available = false, returnér -1
    //
    // Se ESP-IDF v5 i2c_master.h docs for API.
    ESP_LOGW(TAG, "env_sensor_init: TODO (Fase 1) — SHT41 ikke aktiv");
    g_sensor_available = false;
    return -1;
#endif
}

int env_sensor_read(env_reading_t *out)
{
    if (out == NULL) return -1;
    memset(out, 0, sizeof(*out));

    if (!g_sensor_available) {
        out->valid = false;
        return -1;
    }

#ifdef NATIVE_TEST
    out->valid = false;
    return -1;
#else
    // TODO Fase 1: implementer measurement-sekvens
    //
    // Steps:
    //   1. Send SHT41_CMD_MEASURE_HP
    //   2. vTaskDelay(pdMS_TO_TICKS(SHT41_MEAS_DELAY_MS))
    //   3. Læs 6 bytes
    //   4. sht4x_parse() → temp_c + humidity_pct (fejler ved CRC-mismatch)
    //   5. Beregn VPD via env_calculate_vpd()
    //   6. Sæt timestamp_ms via esp_timer_get_time() / 1000
    //   7. out->valid = true
    out->valid = false;
    return -1;
#endif
}

bool env_sensor_available(void)
{
    return g_sensor_available;
}


// ─── SHT4x protokol (pure functions — virker uden hardware) ─────────────────

uint8_t sht4x_crc8(const uint8_t *data, int len)
{
    uint8_t crc = 0xFF;
    for (int i = 0; i < len; i++) {
        crc ^= data[i];
        for (int b = 0; b < 8; b++)
            crc = (crc & 0x80) ? (uint8_t)((crc << 1) ^ 0x31) : (uint8_t)(crc << 1);
    }
    return crc;
}

int sht4x_parse(const uint8_t raw[6], float *temp_c, float *humidity_pct)
{
    if (sht4x_crc8(&raw[0], 2) != raw[2] || sht4x_crc8(&raw[3], 2) != raw[5])
        return -1;

    uint16_t t_ticks  = (uint16_t)((raw[0] << 8) | raw[1]);
    uint16_t rh_ticks = (uint16_t)((raw[3] << 8) | raw[4]);
    float rh = -6.0f + 125.0f * rh_ticks / 65535.0f;

    *temp_c       = -45.0f + 175.0f * t_ticks / 65535.0f;
    *humidity_pct = rh < 0.0f ? 0.0f : (rh > 100.0f ? 100.0f : rh);
    return 0;
}


// ─── VPD math (pure functions — virker uden hardware) ───────────────────────

float env_saturation_vapor_pressure(float temp_c)
{
    // Tetens formula
    // es(T) = 0.611 * exp(17.27 * T / (T + 237.3))    [kPa]
    return 0.611f * expf(17.27f * temp_c / (temp_c + 237.3f));
}

float env_calculate_vpd(float temp_c, float humidity_pct)
{
    float es = env_saturation_vapor_pressure(temp_c);
    return es * (1.0f - humidity_pct / 100.0f);
}

float env_vpd_dose_scale(float vpd_kpa)
{
    float scale = vpd_kpa / ENV_VPD_REFERENCE_KPA;

    // Clamp til sikker range
    if (scale < ENV_VPD_SCALE_MIN) scale = ENV_VPD_SCALE_MIN;
    if (scale > ENV_VPD_SCALE_MAX) scale = ENV_VPD_SCALE_MAX;

    return scale;
}
