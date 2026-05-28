# ADR 007 — AHT20 environmental sensor som standard v1-komponent

**Status:** Accepted
**Dato:** 2026-05-27

## Context

Soil moisture sensoren reagerer på *konsekvensen* af tørt klima (jord der hurtigt tørrer ud), men ikke på *årsagen*. Det betyder vi har et **reaktivt** vandingssystem — det vander efter jorden er nået til tørt, ikke før.

For sensitive planter (Peace Lily der hænger ved tørke, African Violet med fuzzy blade) er reaktiv vanding suboptimal. En temperatur- og fugtighedssensor giver flere muligheder:

1. **Predictive watering** — pre-vand før plant stress sker
2. **VPD-baseret dose-justering** — Vapor Pressure Deficit er den fysiologisk korrekte metric for plantens transpirationskrav. Plant transpirerer ~2× mere ved 28°C/30% RH end ved 22°C/50% RH.
3. **Reservoir-fordampningsforecast** — i tørt indeklima fordamper reservoiret hurtigere; advare om refill før det er kritisk
4. **HomeKit value-add** — rumtermometer + hygrometer som biprodukt
5. **Bedre debug-info** — sensor-drift fra temperatur kan korrigeres aktivt i firmware

## Decision

Vi tilføjer **AHT20 temperatur+humidity sensor** som **STANDARD v1-komponent** (ikke optional som load cell).

Begrundelse for "standard" frem for "optional":
- AHT20 er universelt nyttigt for ALLE planter, ikke kun en undergruppe (i modsætning til load cell som kun er nødvendigt for orkide)
- Cost er lav (~25 DKK)
- Pin-budget på XIAO ESP32-C6 tillader det (vi har stadig 1 reserve-pin)
- Pris-billigere at gøre det rigtigt fra start end at tilføje senere (kræver ompositionering af komponenter)

### Pin-rearrangement

AHT20 er ægte I2C (ikke HX711's pseudo-2-wire) og skal helst på SDA/SCL-default pins for at undgå pin-conflict med ESP-IDF I2C-driver. Det betyder HX711 skal flyttes.

Vi udnytter at ESP32-C6 har **native USB Serial/JTAG**: ESP-IDF console kan routes til USB-C i stedet for UART. Det frigør D6/D7 (UART TX/RX) til HX711.

| Pin | Før | Efter |
|---|---|---|
| D4 | HX711 SCK | **AHT20 SDA** |
| D5 | HX711 DOUT | **AHT20 SCL** |
| D6 | UART TX (debug) | **HX711 SCK** |
| D7 | UART RX (debug) | **HX711 DOUT** |
| Console | UART D6/D7 | **USB-CDC** (via `CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y`) |

Se [wiring-diagram.md](../../pot/hardware/breadboard/wiring-diagram.md) for fuld opdateret pin-mapping.

### VPD-aware dose-modifikator (v1.x firmware)

Firmware tilføjer en VPD-baseret skalering af `dose_ml`:

```c
// Tetens formula for saturation vapor pressure (kPa)
float es = 0.611f * expf(17.27f * temp_c / (temp_c + 237.3f));

// Vapor Pressure Deficit
float vpd = es * (1.0f - rh_pct / 100.0f);

// Reference: 22°C / 50% RH ≈ 1.3 kPa (komfortabelt indeklima)
// Skaler dose lineært, clampet til [0.5, 2.0] for sikkerhed
float scale = clamp(vpd / 1.3f, 0.5f, 2.0f);

uint16_t actual_dose_ml = profile.dose_ml * scale;
```

Aktiveres per profil via et `vpd_aware` flag (default `true` for sensitive profiler, `false` for succulenter hvor små doser er kritiske).

## Consequences

### Positive

- **Predictive vanding** mulig — pre-vand ved varm/tør forventning før plant lider
- **VPD-baseret dose** matcher plantens reelle transpirationsbehov
- **Reservoir-fordampning** kan modelleres → bedre refill-prediction
- **Termisk drift-kompensation** af HX711 bliver mulig (temp er nu kendt → korrektion)
- **Ekstra HomeKit-entiteter** (rumtemp + RH) → værdi som klimasensor i hjemmet
- **Negligibel strøm** — AHT20 standby ~2 µA, active ~1.5 mA i 80ms per måling

### Negative

- **+1 komponent** at lodde, +25 DKK i BOM
- **Pin-rearrangement** kræver opdatering af wiring-diagram + firmware konstanter
- **USB-CDC console** i stedet for UART — nyt for nogle udviklere, men ESP32-C6 håndterer det native
- **Firmware kompleksitet** — VPD-aware logik tilføjes til control_task

### Alternativer overvejet

- **BME280** (~40 DKK): tilføjer barometer som vi ikke har brug for. Overkill.
- **SHT41** (~60 DKK): højere præcision (±0.2°C, ±1.5% RH), men marginal benefit for vores brug-case.
- **Skip helt og lave det optional v1.1**: forkastet — bruger valgte eksplicit "gør det ordentligt første gang"; det er billigere og enklere at integrere nu end at tilføje senere.
- **Behold UART, drop manual button eller WS2812 LED**: overvejet, men ESP32-C6 USB-CDC er moden og giver bedre dev-oplevelse end UART.

## Implementation notes

### Hardware

- AHT20 modul (Adafruit, DFRobot, eller AliExpress generic) ~25 DKK
- 4-pin breakout: VCC (3.3V), GND, SDA, SCL
- 4.7kΩ pull-up resistorer på SDA og SCL (inkluderet på de fleste breakout-boards; tjek databladet)
- Placering: et sted i electronics base hvor luften kan cirkulere (ikke direkte over varmegenererende komponenter)

### Firmware

- I2C-driver: ESP-IDF `i2c_master.h` (v5.x API)
- AHT20 address: 0x38
- Måling: trigger 0xAC 0x33 0x00 → vent 80ms → læs 6 bytes (status + 20-bit hum + 20-bit temp + CRC)
- Sample-rate: 1 reading per 60. sek (rum-klima ændres langsomt)
- Se [pot/firmware/src/temp_humidity.h](../../pot/firmware/src/temp_humidity.h) for API.

### USB-CDC console enablement

I `sdkconfig.defaults`:
```
CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y
CONFIG_ESP_CONSOLE_SECONDARY_NONE=y
```

Console-output (ESP_LOGI etc.) vil derefter komme via USB-C portens CDC-interface. På macOS dukker den op som `/dev/cu.usbmodem*`.

### Failure mode

Hvis AHT20 ikke svarer på I2C ved boot: firmware logger warning, sætter `env_sensor_available = false`, og fortsætter med fixed-dose (no VPD adjustment). Brugeren får advarsel i HomeKit men systemet kører videre. Dette giver graceful degradation hvis brugeren bygger uden AHT20.
