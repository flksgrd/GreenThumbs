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

static const char *TAG = "greenthumbs";


// =============================================================================
// Pin assignments — se pot/hardware/breadboard/wiring-diagram.md
// =============================================================================
// NB: D4/D5 er nu reserveret til AHT20 I2C (SDA/SCL). HX711 er flyttet til
// D6/D7. ESP-IDF console kører på USB-CDC i stedet for UART (se ADR 007).
constexpr int PIN_SOIL_ADC      = 0;   // D0 / GPIO0 / ADC1_CH0
constexpr int PIN_WATER_ADC     = 1;   // D1 / GPIO1 / ADC1_CH1
constexpr int PIN_BUZZER        = 2;   // D2 / GPIO2 (piezo buzzer, LEDC PWM)
constexpr int PIN_FLOAT_SWITCH  = 21;  // D3 / GPIO21
constexpr int PIN_I2C_SDA       = 22;  // D4 / GPIO22 (AHT20)
constexpr int PIN_I2C_SCL       = 23;  // D5 / GPIO23 (AHT20)
constexpr int PIN_HX711_SCK     = 16;  // D6 / GPIO16
constexpr int PIN_HX711_DOUT    = 17;  // D7 / GPIO17
constexpr int PIN_STATUS_LED    = 19;  // D8 / GPIO19 (WS2812)
constexpr int PIN_MANUAL_BUTTON = 20;  // D9 / GPIO20
constexpr int PIN_PUMP_GATE     = 18;  // D10 / GPIO18 (MOSFET PWM)


// =============================================================================
// Shared state
// =============================================================================
struct sensor_state_t {
    uint8_t moisture_pct;
    uint8_t water_level_pct;
    bool float_low;          // true hvis float-switch siger vand tom
    int32_t weight_g;
    float temp_c;            // fra AHT20
    float humidity_pct;      // fra AHT20
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
    // ADC1 init for soil og water pins
    // Pull-up på float switch og button
    // PWM init for pump gate
    // RMT init for WS2812 LED
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

    // 5. Environmental sensor (AHT20 over I2C)
    if (env_sensor_init() != 0) {
        ESP_LOGW(TAG, "AHT20 init failed — VPD-aware dosing disabled");
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
        //   - Læs water level ADC, beregn pct
        //   - Læs float switch
        //   - Læs HX711 (DETECT_WEIGHT/HYBRID modes, hvis available)
        //   - Læs AHT20 hver 60s (env_sensor_read), beregn VPD
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
