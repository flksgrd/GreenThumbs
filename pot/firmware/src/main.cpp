/**
 * @file main.cpp
 * @brief GreenThumbs Plantekrukke — entry point + FreeRTOS task setup.
 *
 * Arkitektur (se docs/architecture.md):
 *   - sensor_task: sampler soil/water/weight hver 30s
 *   - control_task: evaluerer profil, beslutter om pumpe skal trigges
 *   - matter_task: Matter event loop + cluster updates
 *   - safety_task: watchdog, float-switch ISR håndtering, leak detection
 *
 * Shared state mellem tasks beskyttes med FreeRTOS mutexes.
 *
 * STATUS: skeleton. Fyldes ud i Fase 1 (firmware bring-up).
 */

// Hele filen er ESP-IDF-specifik — udelukkes fra native unit-test builds
// (test/native/ bygger src/ via test_build_src; kun pure-math filer skal med).
#ifndef NATIVE_TEST

#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "esp_log.h"
#include "nvs_flash.h"

#include "profiles.h"
#include "temp_humidity.h"
#include "buzzer.h"
#include "battery_gauge.h"

static const char *TAG = "greenthumbs";


// =============================================================================
// Pin assignments — se pot/hardware/breadboard/wiring-diagram.md
// =============================================================================
// ESP32-H2 (ADR 014). Fælles med orkiden: buzzer 0, I2C 4/5 (SHT41 +
// MAX17048), knap 12, boost 22. Reserveret: 13/14 (32 kHz-krystal på eget PCB),
// 24 (UART0 TX = ROM-log), 8/9/25 (strapping), 26/27 (USB).
constexpr int PIN_BUZZER        = 0;   // LEDC PWM
constexpr int PIN_SOIL_ADC      = 1;   // ADC1_CH0
constexpr int PIN_FLOAT_SWITCH  = 2;   // intern pull-up; LOW = vand tomt
// GPIO3 (ADC1_CH2) er fri — batteriet måles af MAX17048 på I2C (ADR 016)
constexpr int PIN_I2C_SDA       = 4;   // I2C: SHT41 + MAX17048 + water level
constexpr int PIN_I2C_SCL       = 5;
constexpr uint8_t WATER_I2C_LOW   = 0x77; // nederste 8 pads
constexpr uint8_t WATER_I2C_HIGH  = 0x78; // øverste 12 pads
constexpr int PIN_HX711_SCK     = 10;
constexpr int PIN_HX711_DOUT    = 11;
constexpr int PIN_MANUAL_BUTTON = 12;  // LP-pin → kan vække fra alle sleep-modes
constexpr int PIN_PUMP_EN       = 22;  // switch A → boost 12V → pumpe (HIGH = on)
constexpr int PIN_SENSOR_PWR    = 23;  // switch B (LOW = sensorer tændt; pull-up ved reset)


// =============================================================================
// Shared state
// =============================================================================
struct sensor_state_t {
    uint8_t moisture_pct;
    uint8_t water_level_pct;
    bool float_low;          // true hvis float-switch siger vand tom
    int32_t weight_g;
    float temp_c;            // fra SHT41
    float humidity_pct;      // fra SHT41
    float vpd_kpa;           // beregnet VPD
    uint32_t last_update_ms;
};

struct pump_state_t {
    uint32_t last_pump_ms;
    uint16_t daily_ml;
    uint32_t day_start_ms;   // til at resette daily_ml ved midnat
};

static sensor_state_t g_sensors;
static pump_state_t g_pump;
static plant_profile_t g_active_profile;
static SemaphoreHandle_t g_state_mutex;


// =============================================================================
// Task forward declarations
// =============================================================================
static void sensor_task(void *pvParameters);
static void control_task(void *pvParameters);
static void matter_task(void *pvParameters);
static void safety_task(void *pvParameters);


// =============================================================================
// Setup helpers
// =============================================================================
static esp_err_t init_nvs(void)
{
    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        err = nvs_flash_init();
    }
    return err;
}

static void init_pins(void)
{
    // TODO: gpio_config for alle pins
    // ADC1 init for soil og batteri
    // Pull-up på float switch og button
    // Pumpe- og sensor-switch: output, starter slukket (GPIO22 LOW, GPIO23 HIGH)
    ESP_LOGI(TAG, "Pin init: TODO (Fase 1)");
}

static void init_matter(void)
{
    // TODO: ESP-Matter SDK initialisering
    //   1. esp_matter::node_t create
    //   2. Tilføj endpoints: humidity sensor (soil), humidity sensor (water),
    //      leak detector (float), on/off switch (manual pump), mode select (profile)
    //   3. esp_matter::start()
    //   4. Print QR-code til serial for first-time pairing
    ESP_LOGI(TAG, "Matter init: TODO (Fase 1)");
}


// =============================================================================
// Entry point
// =============================================================================
extern "C" void app_main(void)
{
    ESP_LOGI(TAG, "=== GreenThumbs Plantekrukke booting (v%s) ===", GREENTHUMBS_VERSION);

    // 1. NVS init
    ESP_ERROR_CHECK(init_nvs());

    // 2. Load aktiv profil (eller default = Monstera)
    if (profile_load_from_nvs(&g_active_profile) != 0) {
        ESP_LOGW(TAG, "No saved profile, using default: %s",
                 PROFILE_DEFAULTS[PROFILE_MONSTERA].name);
        g_active_profile = PROFILE_DEFAULTS[PROFILE_MONSTERA];
    }
    ESP_LOGI(TAG, "Active profile: %s", g_active_profile.name);

    // 3. State mutex
    g_state_mutex = xSemaphoreCreateMutex();

    // 4. Hardware init
    init_pins();

    // 5. Environmental sensor (SHT41 over I2C)
    if (env_sensor_init() != 0) {
        ESP_LOGW(TAG, "SHT41 init failed — VPD-aware dosing disabled");
        // Fortsætter med graceful degradation (se ADR 007)
    }

    // 6. Matter stack
    init_matter();

    // 7. Spawn tasks
    // Stack sizes (audit-fix): Matter event-handling + I2C/ADC-buffere kræver
    // mere end de oprindelige gæt. TODO Fase 1: mål reelt forbrug med
    // uxTaskGetStackHighWaterMark() og trim.
    xTaskCreate(sensor_task,  "sensor",  8192,  nullptr, 5, nullptr);
    xTaskCreate(control_task, "control", 4096,  nullptr, 5, nullptr);
    xTaskCreate(matter_task,  "matter",  16384, nullptr, 4, nullptr);
    xTaskCreate(safety_task,  "safety",  2048,  nullptr, 6, nullptr);

    ESP_LOGI(TAG, "All tasks started, app_main exiting.");
}


// =============================================================================
// Task implementations (skeletons)
// =============================================================================

static void sensor_task(void * /*pvParameters*/)
{
    const TickType_t period = pdMS_TO_TICKS(30 * 1000);
    TickType_t last_wake = xTaskGetTickCount();

    for (;;) {
        // TODO Fase 1:
        //   - Læs soil ADC, beregn moisture_pct via profile_moisture_pct()
        //   - Læs water level via I2C (0x77: 8 bytes, 0x78: 12 bytes), tæl
        //     pads over tærskel → pct af water_full_pads (calibration.md §3)
        //   - Læs float switch
        //   - Læs HX711 (DETECT_WEIGHT/HYBRID modes, hvis available)
        //   - Læs SHT41 hver 60s (env_sensor_read), beregn VPD
        //   - Lås mutex, opdater g_sensors (inkl. temp/humidity/vpd), frigør mutex
        //   - REFILL-DETECTION (ADR 008): hvis water level steg >5 procentpoint
        //     på 10 sek → refill-mode → buzzer_pattern(BUZZ_REFILL_PROGRESS)
        //     ved 25/50/75% og BUZZ_REFILL_FULL ved ≥95%. Forlad mode efter
        //     30 sek stabil level.
        //
        // VIGTIGT: spring HX711-sample over hvis pump_active = true (vibrationer
        // forplanter sig fra pump til load cell). Se docs/architecture.md.

        ESP_LOGD(TAG, "[sensor] sample tick");
        vTaskDelayUntil(&last_wake, period);
    }
}

static void control_task(void * /*pvParameters*/)
{
    const TickType_t period = pdMS_TO_TICKS(60 * 1000);
    TickType_t last_wake = xTaskGetTickCount();

    for (;;) {
        // TODO Fase 1:
        //   - Lås mutex, kopier g_sensors + g_pump + g_active_profile
        //   - Frigør mutex
        //   - Kald profile_should_pump(...)
        //   - Hvis true:
        //       * dose = profile_effective_dose_ml(&profile,
        //                    g_sensors.vpd_kpa, env_sensor_available())
        //       * Trig pumpe via pump_dose_ml(dose)
        //   - Opdater g_pump.last_pump_ms og daily_ml

        ESP_LOGD(TAG, "[control] eval tick");
        vTaskDelayUntil(&last_wake, period);
    }
}

static void matter_task(void * /*pvParameters*/)
{
    // ESP-Matter har sin egen event loop. Denne task wrapper det
    // og synker cluster-værdier til vores g_sensors-state.
    for (;;) {
        // TODO Fase 1:
        //   - Hver 10s: lås mutex, læs g_sensors, opdater Matter cluster-attributter
        //   - Håndter incoming commands (manual pump trigger, profile change)
        vTaskDelay(pdMS_TO_TICKS(10 * 1000));
    }
}

static void safety_task(void * /*pvParameters*/)
{
    for (;;) {
        // TODO Fase 1:
        //   - Tjek at sensor_task ikke er stuck (g_sensors.last_update_ms ny nok)
        //   - Tjek float-switch ISR-counter
        //   - Hvis vægt falder hurtigere end forventet → leak suspected → disable pump
        //   - Watchdog feed
        vTaskDelay(pdMS_TO_TICKS(5 * 1000));
    }
}

#endif  // !NATIVE_TEST
