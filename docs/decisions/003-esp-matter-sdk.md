# ADR 003 — Firmware-stack: PlatformIO + ESP-IDF + ESP-Matter SDK

**Status:** Accepted
**Dato:** 2026-05-27

## Context

Firmware skal:
- Drive sensor-sampling, pumpe-styring, plant-profile logik, og Matter cluster-eksponering.
- Køre på ESP32-C6.
- Være vedligeholdelsesvenlig over tid.
- Tillade brugeren at lære Matter-stacken (eksplicit ønske).

Tre rimelige stacks blev overvejet:

1. **ESPHome** (YAML + lambda C++) — hurtig prototyping, Matter indbygget.
2. **PlatformIO + ESP-IDF + ESP-Matter SDK** (C/C++) — fuld kontrol, mere boilerplate.
3. **Arduino framework + Matter library** — kendt territorium, men umodne Matter-libs.

## Decision

Vi bruger **PlatformIO som build-system, ESP-IDF som framework, og Espressifs officielle ESP-Matter SDK** som Matter-stack. Sproget er C/C++ (matcher brugerens præferencer i `~/.claude/CLAUDE.md`).

## Consequences

### Positive

- **Fuld kontrol over Matter-stacken**: vi kan implementere custom clusters (fx "plant care" cluster for soil moisture targets), justere endpoint-strukturen, og finetune Thread Sleepy End Device timing.
- **PlatformIO**: bedre IDE-integration (VS Code/Antigravity) end råt ESP-IDF CLI, og let at versionere via `platformio.ini`.
- **Officiel SDK fra Espressif**: følger Matter-specifikationen tæt, opdateres med nye Matter-versioner.
- **Læringsudbytte**: brugeren får hands-on med både Matter-protokollen og FreeRTOS, hvilket var et eksplicit projektmål.
- **C/C++**: matcher brugerens vante sprog; kan dele kode med embedded-projekter i andre repos.

### Negative

- **Mere boilerplate**: Matter device-init kræver ~200 linjer setup-kode vs ~20 linjer i ESPHome YAML.
- **Stejlere læringskurve**: ESP-Matter SDK har ufuldstændig dokumentation. Forvent at læse Espressifs eksempler grundigt.
- **Længere iterations-cyklus**: kompilering tager 1-3 min vs ESPHomes hot-reload.
- **OTA-flow skal bygges manuelt** vs ESPHomes built-in OTA.

### Alternativer overvejet

- **ESPHome**: forkastet fordi brugeren eksplicit ønskede C/C++ + ESP-Matter SDK. ESPHome er stadig en glimrende option for ikke-C/C++ brugere; vi kan altid migrere senere hvis vedligeholdelse bliver byrdefuld.
- **Arduino + Matter**: forkastet — Arduino-Matter libraries er stadig umodne (2026 Q1), og man får ofte ESP-IDF/Arduino mismatches der spilder tid.

## Implementation notes

- `platformio.ini` pinner `framework = espidf` og `platform = espressif32 @ ^6.5.0`.
- `esp-matter` inkluderes som ESP-IDF component via `idf_component.yml`.
- ESP-Matter SDK version pinnes til specifik git-tag (ikke `main`) for reproducerbare builds.
- FreeRTOS-tasks holder Matter event-loop separat fra sensor/control-logik.
- HomeKit-eksponering via standard Matter clusters: `Humidity Sensor`, `Leak Detector`, `On/Off Switch`, `Mode Select`.
