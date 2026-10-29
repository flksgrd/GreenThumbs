# Plantekrukke Firmware

PlatformIO + ESP-IDF + ESP-Matter SDK projekt for ESP32-H2 (Waveshare ESP32-H2-Zero; ADR 014).

## Setup (første gang)

### 1. PlatformIO Core

PlatformIO skal køre på **Python ≤ 3.13**. ESP-IDF 5.5's Python-afhængigheder
(pydantic-core, cryptography) kan ikke bygges på 3.14 — buildet fejler med
`No module named 'idf_component_manager'` eller SIGSEGV i esptool-postinstall.

```bash
pipx install platformio --python python3.13
# eller med uv's Python: --python ~/.local/share/uv/python/cpython-3.13.*/bin/python3.13
```

Eller via VS Code / Antigravity: install "PlatformIO IDE" extension.

### 2. ESP-Matter SDK

ESP-Matter SDK kommer ikke automatisk med PlatformIO. Den skal klones manuelt:

```bash
# Fra et stabilt sted (ikke i dette repo)
cd ~/
git clone --recursive https://github.com/espressif/esp-matter.git
cd esp-matter
git checkout <release>  # pin en release hvis README anbefaler ESP-IDF 5.5.x
                        # (1.6-serien ifølge Espressifs komponent-register) — ikke main
./install.sh
```

Tilføj så til din shell profile (`~/.zshrc`):

```bash
export ESP_MATTER_PATH=$HOME/esp-matter
source $ESP_MATTER_PATH/export.sh
```

### 3. ESP-IDF (auto-installeres af PlatformIO)

PlatformIO installerer ESP-IDF automatisk når du første gang kører `pio run`
(verificeret 2026-10-26: pioarduino 55.03.312-1 → ESP-IDF 5.5.5, target esp32h2;
RAM 3,3%, flash 9,7% af app-slot; første build ~3 min). Den officielle
espressif32-platform understøtter ikke ESP32-H2 (ADR 014).

- `scripts/fix_ot_datetime.py` retter en PlatformIO-fejl, der ellers stopper
  OpenThread-buildet (build-dato med mellemrum i en define)
- Flash er sat til 4MB (ESP32-H2FH4S) i både `platformio.ini` og `sdkconfig.defaults`
- OTA: `partitions.csv` har to app-slots (ota_0/ota_1, 1920 KB hver) + otadata,
  og rollback er slået til. Ny firmware skal kalde
  `esp_ota_mark_app_valid_cancel_rollback()` først når Thread + Matter er oppe
  igen — ellers vender bootloaderen tilbage til den forrige version.
  Opdatering sker som Matter OTA (OTA Requestor i esp-matter) fra en
  `chip-ota-provider-app` på Mac'en; USB-C ved kanten lader kun (ADR 013)
- esp-matter: nyere udgaver anbefaler ESP-IDF 5.5.5 — det vi nu bygger med.
  Brug en esp-matter-version der matcher (ikke v1.3, som hører til 5.2.x)

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
│   ├── pump.cpp / .h           # Boost-switch + pumpe-dosering (TODO Fase 1)
│   ├── sensors.cpp / .h        # Soil ADC + water level + float ISR (TODO Fase 1)
│   ├── weight.cpp / .h         # HX711 driver, optional hardware (TODO Fase 1)
│   ├── temp_humidity.cpp / .h  # SHT41 I2C + VPD calc — SHT4x-CRC/VPD virker; I2C TODO
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
