/**
 * @file temp_humidity.cpp
 * @brief AHT20 driver implementation + VPD math.
 *
 * STATUS: Skeleton — VPD-funktioner virker (pure math), AHT20 I2C-kode
 * skal implementeres i Fase 1 firmware bring-up.
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
static i2c_master_dev_handle_t g_aht20_dev = NULL;
#endif


// ─── I2C / AHT20 funktioner ─────────────────────────────────────────────────

int env_sensor_init(void)
{
#ifdef NATIVE_TEST
    // Native test build — ingen I2C tilgængelig
    g_sensor_available = false;
    return -1;
#else
    // TODO Fase 1: implementer I2C bus + AHT20 device init
    //
    // Steps:
    //   1. i2c_new_master_bus() med SDA = GPIO22 (D4), SCL = GPIO23 (D5)
    //   2. i2c_master_bus_add_device() med AHT20_I2C_ADDR
    //   3. Send AHT20 calibration command (0xBE 0x08 0x00) + vent 10ms
    //   4. Læs status byte; tjek calibration enabled bit
    //   5. Hvis OK → g_sensor_available = true, returnér 0
    //   6. Ellers → log warning, g_sensor_available = false, returnér -1
    //
    // Se ESP-IDF v5 i2c_master.h docs for API.
    ESP_LOGW(TAG, "env_sensor_init: TODO (Fase 1) — AHT20 ikke aktiv");
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
    //   1. Send trigger: 0xAC 0x33 0x00
    //   2. vTaskDelay(pdMS_TO_TICKS(AHT20_MEAS_DELAY_MS))
    //   3. Læs 6 bytes: [status, hum_high, hum_mid, hum_low_temp_high,
    //      temp_mid, temp_low] (humidity og temp deler én byte 4:4)
    //   4. Tjek CRC (byte 6 ≠ inkluderet i nogle AHT20-variants — verificer)
    //   5. Parse 20-bit humidity og 20-bit temperature
    //   6. Konverter:
    //        humidity_pct = (hum_raw / 1048576.0f) * 100.0f
    //        temp_c       = (temp_raw / 1048576.0f) * 200.0f - 50.0f
    //   7. Beregn VPD via env_calculate_vpd()
    //   8. Sæt timestamp_ms via esp_timer_get_time() / 1000
    //   9. out->valid = true
    out->valid = false;
    return -1;
#endif
}

bool env_sensor_available(void)
{
    return g_sensor_available;
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
