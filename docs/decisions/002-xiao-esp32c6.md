# ADR 002 — XIAO ESP32-C6 som MCU

**Status:** Accepted
**Dato:** 2026-05-27

## Context

Plantekrukken skal:
- Tale **Matter over Thread** med Apple HomeKit (via HomePod/Apple TV som Thread Border Router).
- Have **WiFi-fallback** for setup og diagnostik.
- Køre **lavt strømforbrug** så batteri-drift bliver muligt i v2.
- Have nok GPIO til 4 sensorer + pumpe-driver + status-LED + manuel knap.
- Være fysisk **lille** så den passer i krukkens elektronik-base.

## Decision

Vi bruger **Seeed Studio XIAO ESP32-C6** som MCU både til prototype-fase (breadboard) og til endelig integration. Castellated edges tillader direkte lodning på custom PCB i v2 uden re-design.

## Consequences

### Positive

- **Native Thread + Matter + WiFi + BLE 5** i én chip — ESP32-C6 er Espressifs første Thread-capable SoC.
- **USB-C indbygget**: ingen ekstern programmer; flash + monitor via samme kabel som strømforsyning.
- **Kompakt 21×17.5mm** — passer i lille elektronik-kammer uden at dominere PCB-layoutet.
- **Castellated edges** + standard 0.1" pinout giver fleksibilitet: breadboard for prototype, direct-mount for produktion.
- **Tilstrækkelige GPIO**: 11 brugbare pins. Vores brug: 2 ADC (soil + water) + 2 GPIO (HX711) + 1 GPIO (float ISR) + 1 GPIO PWM (pumpe) + 1 GPIO (LED) + 1 GPIO (knap) = 8 pins, 3 til overs.
- **Bredt economy**: ~80 DKK fra flere distributører (Mouser, Digi-Key, Elektor).

### Negative

- **Nyere chip** (2024): ESP-IDF support er stabilt men ESP-Matter SDK på C6 har stadig nogle rough edges. Dokumentation til Thread Sleepy End Device på C6 er ikke perfekt.
- **Færre Thread-eksempler i wild** end nRF52840 — community-resources er mindre.
- **ADC-præcision** er begrænset (12-bit ENOB ~10-11) — fint til vores ratio-baserede moisture-målinger, men ikke til hi-precision ADC-arbejde.

### Alternativer overvejet

- **ESP32-C6-DevKitC-1** (Espressif official): mere robust til prototyping, men 3x større fysisk. Forkastet pga. størrelse.
- **Nordic nRF52840** (fx Adafruit Feather): bedre Thread-modenhed, men mangler WiFi og kræver separat programmer. Forkastet pga. WiFi-mangel + større barrier til entry for hobbyist.
- **ESP32-H2** (Thread+BLE only, ingen WiFi): forkastet — WiFi-fallback til diagnostik er værdifuldt.

## Implementation notes

- Pin-mapping dokumenteret i [../../pot/hardware/breadboard/wiring-diagram.md](../../pot/hardware/breadboard/wiring-diagram.md).
- ESP-Matter SDK pinnes til specifik git-tag i `platformio.ini` for at undgå breaking changes.
- Power-budget i [main plan sektion 8](../../.claude/plans/...) viser at C6 i Sleepy End Device mode gør batteri-drift realistisk for v2.
