# Plantekrukke Firmware

PlatformIO + ESP-IDF + ESP-Matter SDK projekt for XIAO ESP32-C6.

## Setup (første gang)

### 1. PlatformIO Core

```bash
pip install --break-system-packages platformio
```

Eller via VS Code / Antigravity: install "PlatformIO IDE" extension.

### 2. ESP-Matter SDK

ESP-Matter SDK kommer ikke automatisk med PlatformIO. Den skal klones manuelt:

```bash
# Fra et stabilt sted (ikke i dette repo)
cd ~/
git clone --recursive https://github.com/espressif/esp-matter.git
cd esp-matter
git checkout v1.3  # pin til specifik version, ikke main
./install.sh
```

Tilføj så til din shell profile (`~/.zshrc`):

```bash
export ESP_MATTER_PATH=$HOME/esp-matter
source $ESP_MATTER_PATH/export.sh
```

### 3. ESP-IDF (auto-installeres af PlatformIO)

PlatformIO installerer ESP-IDF 5.1+ automatisk når du første gang kører `pio run`.

## Build & flash

```bash
cd pot/firmware
pio run                    # build
pio run -t upload          # flash via USB-C
pio device monitor         # serial monitor (115200 baud)
```

## First-time Matter pairing

Efter flash, serial monitor printer en QR-kode + setup PIN:

```
Matter device ready.
QR Code:       MT:Y.K9042C00KA0648G00
Manual PIN:    20202021
Discriminator: 3840
```

I Apple Home-app:
1. "Tilføj tilbehør" → "Mere"
2. Scan QR-kode med iPhone-kamera (eller indtast PIN manuelt)
3. Følg setup-wizard

## Unit tests

```bash
pio test -e native_test    # kør native unit tests (ikke på ESP32)
pio test -e greenthumbs_pot  # kør on-target tests (kræver ESP32 tilsluttet)
```

## Folder struktur

```
firmware/
├── platformio.ini          # PlatformIO config
├── sdkconfig.defaults      # ESP-IDF default settings
├── partitions.csv          # Flash partition layout
├── src/
│   ├── main.cpp                # Entry + task spawning + pin assignments
│   ├── pump.cpp / .h           # Pump MOSFET drive + dosering (TODO Fase 1)
│   ├── sensors.cpp / .h        # Soil ADC + water level + float ISR (TODO Fase 1)
│   ├── weight.cpp / .h         # HX711 driver, optional hardware (TODO Fase 1)
│   ├── temp_humidity.cpp / .h  # AHT20 I2C + VPD calc — VPD math virker; I2C TODO
│   ├── profiles.cpp / .h       # Plant profile + NVS storage
│   ├── safety.cpp / .h         # Watchdog + leak detect (TODO Fase 1)
│   └── matter_iface.cpp / .h   # Matter cluster bindings (TODO Fase 1)
├── include/                # Public headers (hvis nogen)
├── lib/                    # Local libraries (genbrug fra shared/firmware-lib)
└── test/                   # Unit tests (native + on-target)
```

## Status

- [x] Repo skeleton + platformio.ini config
- [x] profiles.h struct + profiles.cpp (factory defaults + threshold/dose-logik)
- [x] temp_humidity.h API + VPD math implementation (I2C-driver TODO Fase 1)
- [x] buzzer.h/.cpp skeleton (refill-indikator, ADR 008)
- [x] USB-CDC console configuration (sdkconfig.defaults)
- [x] Audit-fixes: partitions.csv 4MB-layout, platform IDF 5.2+, task stacks
- [x] main.cpp task skeleton
- [ ] Implementér sensors.cpp (Fase 1)
- [ ] Implementér pump.cpp (Fase 1)
- [ ] Implementér weight.cpp (Fase 1)
- [ ] Implementér matter_iface.cpp (Fase 1)
- [ ] First-time Matter pairing test (Fase 1)
- [ ] Unit tests (Fase 1)
- [ ] OTA flow (Fase 4)
