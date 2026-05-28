# 🌱 GreenThumbs

DIY auto-vandings-system til hjemmeplanter med Apple HomeKit-integration via Matter over Thread.

## Status

| Komponent | Status | Note |
|---|---|---|
| **v1: Smart Plantekrukke** | 🟡 Planlægning færdig, bygges nu | Modulær 3D-printet selvvandende krukke (med valgfri wick til bottom-watering) |
| **v2a: Pot-Orchid** | ⚪ Designfase only | Dedikeret orkide-krukke med soak-tray |
| **v2b: Vægmonteret Tower** | ⚪ Designfase only | Hydroponic til krydderurter/leafy greens |

## Oversigt

To designs til forskellige behov:

### 🪴 Smart Plantekrukke (v1 — denne iteration)

En modulær 3D-printet krukke der lever inde i en pyntepotte:

- **Plug-and-play planteprofiler**: Monstera, Pothos, Peace Lily, African Violet, Succulent, Orkide
- **Modulær sensor-stack**: kapacitiv jord-fugtighed + vandstand + float-switch som basis. **Optional**: HX711 + 5kg load cell tilføjer vægt-detektion (krævet for orkide-bark; ikke nødvendigt for jord-planter)
- **Bottom-watering option (v1 wick)**: bomulds-snor gennem center-drænhul → continuous capillary watering for African Violet, Peace Lily, Calathea og lignende fugt-elskere
- **Stille peristaltisk pumpe**: præcis dosering 5–100 ml, selv-primende, dry-run tolerant
- **Modulær størrelse**: skiftelig plantebeholder (S/M/L) — én reservoir + elektronik-base passer alle
- **Apple HomeKit** via Matter over Thread fra dag 1 (HomePod/Apple TV som Thread Border Router)
- **Strøm**: USB-C kablet i v1. Batteri-feasibility analyseret — realistisk i v2 med 3S 18650 + Sleepy End Device (~5-6 mdrs runtime)

→ Se [pot/](pot/) for byggeguide, hardware, firmware og CAD.

### 🪻 Pot-Orchid med Soak-Tray (v2a — kun planlægning)

Dedikeret orkide-krukke der mimicker manuel orkide-soaking: tray omkring plant cup oversvømmes via pump i 10-15 min, drænes derefter via solenoid eller passiv overflow tilbage til reservoir. Genbruger v1-elektronik 100%.

→ Se [pot-orchid/design-notes.md](pot-orchid/design-notes.md) for løbende planlægning.

### 🌿 Vægmonteret Hydroponic Tower (v2b — kun planlægning)

Vægophængt tower til krydderurter (basilikum, mynte, persille, koriander) og leafy greens (salat, spinat).
Deler MCU + firmware-platform med plantekrukken.

→ Se [tower/design-notes.md](tower/design-notes.md) for løbende planlægning.

## Quick reference

- **Komponentliste / BOM**: [pot/hardware/bom.csv](pot/hardware/bom.csv)
- **Wiring-diagram**: [pot/hardware/breadboard/wiring-diagram.md](pot/hardware/breadboard/wiring-diagram.md)
- **Planteprofiler**: [docs/plant-profiles.md](docs/plant-profiles.md)
- **Arkitektur**: [docs/architecture.md](docs/architecture.md)
- **Designbeslutninger (ADR)**: [docs/decisions/](docs/decisions/)
- **Kalibrering**: [docs/calibration.md](docs/calibration.md)

## Tech stack

- **MCU**: Seeed Studio XIAO ESP32-C6 (Thread + WiFi + BLE + Matter)
- **Firmware**: PlatformIO + ESP-IDF + ESP-Matter SDK (C/C++)
- **CAD**: OpenSCAD (parametrisk, git-friendly)
- **3D print**: PETG til vand-kontakt dele, Prusa XL
- **Smart home**: Matter over Thread → Apple HomeKit

## Roadmap

- [x] Plan + arkitektur + BOM
- [ ] Bestil komponenter (AliExpress leadtime ~2-3 uger)
- [ ] Fase 1: Firmware bring-up på breadboard
- [ ] Fase 2: Mekanisk prototype i PLA → PETG
- [ ] Fase 3: Integration + 7-dages live-test
- [ ] Fase 4: Polish + assembly guide + OTA
- [ ] Fase 5: v2 tower-planlægning detaljeret

## License

MIT (software) — se [LICENSE](LICENSE). Hardware-design under overvejelse (CERN-OHL-S).
