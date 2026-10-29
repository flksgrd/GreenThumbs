/**
 * @file battery_gauge.cpp
 * @brief MAX17048 driver.
 *
 * STATUS: Skeleton — konverteringerne virker (pure, testet native);
 * I2C-kaldene implementeres i Fase 1 firmware bring-up.
 */

#include "battery_gauge.h"

#ifndef NATIVE_TEST
#include "esp_log.h"
static const char *TAG = "battery";
#endif

float max17048_vcell_v(uint16_t raw)
{
    return raw * 78.125e-6f;
}

float max17048_soc_pct(uint16_t raw)
{
    float pct = raw / 256.0f;
    return pct > 100.0f ? 100.0f : pct;   // kan rapportere lidt over 100 % fuldt opladet
}

int battery_gauge_init(void)
{
#ifdef NATIVE_TEST
    return -1;
#else
    // TODO Fase 1: i2c_master_bus_add_device(MAX17048_I2C_ADDR) på den fælles
    // bus, læs MAX17048_REG_VERSION og tjek at øverste 12 bit = 0x001.
    ESP_LOGW(TAG, "battery_gauge_init: TODO (Fase 1)");
    return -1;
#endif
}

int battery_gauge_read(float *soc_pct, float *vcell_v)
{
#ifdef NATIVE_TEST
    (void)soc_pct; (void)vcell_v;
    return -1;
#else
    // TODO Fase 1: læs 2 bytes fra MAX17048_REG_SOC og MAX17048_REG_VCELL
    // (MSB først) og konvertér med max17048_soc_pct() / max17048_vcell_v().
    (void)soc_pct; (void)vcell_v;
    return -1;
#endif
}
