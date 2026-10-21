# ADR 013 — Batteridrift: 1S2P Li-ion (2× 18650) i begge versioner

**Status:** Accepted
**Dato:** 2026-10-21
**Erstatter:** strømarkitekturen med USB-C PD → 12V → buck (v1-planen) og
3S-forslaget i den oprindelige power-analyse

## Context

Brugeren foretrækker batteridrift til både pot/ og pot-orchid/. Batteri var
udskudt til en senere custom PCB, så der var hverken plads i CAD eller dele i
BOM'en.

Fakta:
- XIAO ESP32-C6 har indbygget Li-ion-lader og batteri-pads; ~15 µA i deep
  sleep; ladestrøm ~100 mA ifølge en sekundær kilde
  ([CNX](https://www.cnx-software.com/2024/05/22/tiny-xiao-esp32c6-wifi-ble-and-802-15-4-iot-board-offers-up-to-16-gpio-pins/),
  [Seeed](https://wiki.seeedstudio.com/pt-br/xiao_esp32c6_getting_started/)).
  Batterispænding måles via 2× 200k spændingsdeler.
- Kun GPIO0-2 kan vække fra deep sleep. Matter over Thread som sleepy device
  (ICD) bruger light sleep, hvor alle GPIO kan vække.
- Der findes ingen publicerede gennemsnitsstrømme for ESP32-C6 som Matter-ICD
  ([Nordic](https://academy.nordicsemi.com/courses/matter-fundamentals/lessons/lesson-4-power-optimization-in-matter/topic/reducing-power-consumption-in-matter/),
  [Silabs](https://docs.silabs.com/matter/2.6.1/matter-overview-guides/ot-icd-end-device))
  → skal måles i Fase 1.

## Decision

**1S2P Li-ion: 2× 18650 i parallel (~3,6V, ~6000 mAh, ~22 Wh) med BMS,
ladet af XIAO'ens indbyggede lader.**

```
  USB-C (5V) ─→ XIAO ESP32-C6 ─(BAT-pads)─→ beskyttelsesprint ─→ 2× 18650
                    │
     BAT+ ──────────┼─→ switch A (P-FET) ─→ boost 12V ─→ pumpe (pot/)
                    │                                └→ H-bro → pumpe (orkide)
                    │                                └→ XKC-sensor (orkide)
     XIAO 3V3 ──────┴─→ switch B (P-FET) ─→ soil + Grove + AHT20 (kun pot/)
```

- **Boost: Pololu U3V40F12** (12V fast, op til ~3,5A input). XL6009 er
  fravalgt: databladet angiver min. 5V input (Rev 1.1) eller 3,6V (Rev 1.0)
  — en Li-ion-celle går ned til 3,0V
  ([XL6009](https://www.mikrocontroller.net/attachment/344020/XL6009.pdf),
  [U3V40F12](https://www.pololu.com/product/4016/specs)). MT3608-moduler
  (2V min.) er et billigere alternativ til pot/'s 3W-pumpe, men deres lille
  spole er for svag til orkidens 5W.
- **Switch A** (AO3401A + 2N7002-driver) afbryder boostens input helt: en
  boost trækker mA i tomgang og sender Vbat − diodefald videre, selv med
  EN lav — pumpen ville sive.
- **Switch B** (kun pot/): soil-sensoren trækker ~5 mA konstant. AHT20
  ligger på samme skinne som Grove-sensoren, fordi de deler I2C (ellers
  fødes den slukkede sensor gennem pull-ups'ene). I orkiden er AHT20 eneste
  I2C-enhed og står altid tændt (µA i hvile).
- **XKC-Y25** kræver 5-24V → fødes fra boostens 12V; den skal kun bruges,
  mens pumpen kører (dræn + verifikation).

Bortfalder: ZY12PDN PD-trigger, MP1584 buck, USB-C PD-adapter (en almindelig
5V USB-C-lader er nok), IRLB8721-MOSFET'en og WS2812-LED'en (trækker strøm
hele tiden og sidder skjult). I pot/ tændes pumpen ved at tænde boosten.

Detaljeret ledningsdiagram: [wiring-diagram.md](../../pot/hardware/breadboard/wiring-diagram.md).

### Pins (ændringer)

| Pin | pot/ | pot-orchid/ |
|---|---|---|
| D0 | Soil ADC (uændret) | **Batteri-ADC** (spændingsdeler) |
| D1 | **Batteri-ADC** (var reserve) | H-bro IN2 |
| D2 | Buzzer | Buzzer |
| D3 | Float switch | XKC "skål tom" |
| D4/D5 | I2C: AHT20 + Grove | I2C: AHT20 |
| D6/D7 | HX711 (optional) | Float lav / float fuld |
| D8 | **Switch B — sensorer** (var WS2812) | **Switch A — boost** |
| D9 | Knap | Knap |
| D10 | **Switch A — boost/pumpe** (var MOSFET) | H-bro IN1 |

Alle 11 GPIO er i brug i begge versioner.

### Driftstid (estimat — MCU-strømmen skal måles)

Antagelser: boost 85% effektivitet, sensorer slukket mellem målinger,
22 Wh × 85% brugbart ≈ 18,4 Wh.

| | MCU 0,1 mA | MCU 0,3 mA | MCU 1 mA |
|---|---|---|---|
| pot/ (Monstera, ~50 ml/dag, KXF 3W) | ~6,5 mdr. | ~5,5 mdr. | ~3,5 mdr. |
| orkide (ugentlig soak, NKP 5W, 2×5 min) | ~4 mdr. | ~3,5 mdr. | ~2,5 mdr. |

### Plads
- pot/: vugge til 2 celler på electronics_base-låget ved siden af pumpe-
  beslaget. Passer i M, L og CUSTOM. **S-sættet er for smalt** (params.scad
  advarer) → 1 celle eller højere ebase.
- pot-orchid/: vugge i bay'ens bund.

## Consequences

### Positive
- Ingen kabel ved planten i 2,5-6 måneder ad gangen
- Simplere strømdel end før (ingen 12V-forsyning, ingen buck)
- Én USB-C-port til både ladning og programmering (XIAO'ens egen)

### Negative
- Langsom ladning (~100 mA → en 6000 mAh-pakke tager >2 døgn). Hurtigere
  med separat TP4056-lader, hvis det bliver et problem
- HomeKit-opdateringer bliver forsinkede (sleepy device); manuel pumpe-
  kommando kan tage sekunder at nå frem
- Refill-bip (ADR 008) kræver at enheden er vågen → refill-tilstand
  startes med knappen
- Li-ion i en lukket boks: brug celler med BMS (over-/underspænding,
  kortslutning)

### Åbne beslutninger
- **Ladestik-placering (brugeren vil tage stilling senere):** USB-C i
  bunden, forlænger til kanten, eller **pogo-pins + 3D-printet ladebase**
  (v2-idé): tårnet løftes ud af pyntepotten og sættes på basen. Pogo-
  pladerne skal kun føre ladespænding (5V via diode), aldrig batteriet
  direkte, så de er ufarlige hvis de står i en pyt. Magneter til
  justering. Afklares før bay/ebase-bunden låses.

## Implementation notes
- BOM: pot/hardware/bom.csv (batteri-rækker) + pot-orchid/preliminary-bom.md
- Firmware: Matter ICD (sleepy) — sæt poll-interval og mål gennemsnits-
  strøm i Fase 1; batterispænding som HomeKit-batteriniveau
