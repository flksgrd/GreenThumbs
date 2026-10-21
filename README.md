# 🌱 GreenThumbs

DIY auto-vandings-system til hjemmeplanter med Apple HomeKit-integration via Matter over Thread.

## Status

| Komponent | Status | Note |
|---|---|---|
| **v1: Smart Plantekrukke** | 🟡 Planlægning færdig, bygges nu | Modulær 3D-printet selvvandende krukke (med valgfri wick til bottom-watering) |
| **v2a: Pot-Orchid** | 🟡 Design v1 (CAD, ADR 012) | Orkide i dyrkningspotte i en pyntepotte: fyld → soak → dræn |
| **v2b: Vægmonteret Tower** | ⚪ Designfase only | Hydroponic til krydderurter/leafy greens |

## Oversigt

To designs til forskellige behov:

### 🪴 Smart Plantekrukke (v1 — denne iteration)

En modulær 3D-printet krukke der lever inde i en pyntepotte:

- **Plug-and-play planteprofiler**: Monstera, Pothos, Peace Lily, African Violet, Succulent, Orkide
- **Modulær sensor-stack**: kapacitiv jord-fugtighed + vandstand + float-switch + AHT20 (temp + RH) som basis. **Optional**: HX711 + 5kg load cell tilføjer vægt-detektion
- **VPD-aware vanding**: AHT20 measurer rum-klima og firmware skalerer dose dynamisk baseret på Vapor Pressure Deficit — mere vand i tør radiator-vinter, mindre i fugtigt klima
- **Bottom-watering option (v1 wick)**: bomulds-snor gennem center-drænhul → continuous capillary watering for African Violet, Peace Lily, Calathea og lignende fugt-elskere
- **Stille peristaltisk pumpe**: præcis dosering 5–100 ml, selv-primende, dry-run tolerant
- **Modulær størrelse**: skiftelig plantebeholder (S/M/L) — én reservoir + elektronik-base passer alle
- **Apple HomeKit** via Matter over Thread fra dag 1 (HomePod/Apple TV som Thread Border Router)
- **Strøm**: batteri — 2× 18650 (1S2P) ladet via USB-C, Matter sleepy device, estimeret ~3,5-6,5 mdr. pr. opladning ([ADR 013](docs/decisions/013-battery-1s2p.md))

→ Se [pot/](pot/) for byggeguide, hardware, firmware og CAD.

### 🪻 Pot-Orchid med automatisk soak (v2a — design v1)

Et Ø180 tårn der står i en pyntepotte. Orkideen bliver i sin 12cm dyrkningspotte og står i en skål; en vendbar peristaltisk pumpe fylder skålen fra en lager-ring rundt om, holder soak-tiden og pumper vandet tilbage. Skålens kant er et mekanisk loft for soak-dybden. Trigger: interval justeret med VPD — ingen sensor i barken. Samme batteri som v1.

→ Se [pot-orchid/README.md](pot-orchid/README.md) og [ADR 012](docs/decisions/012-orchid-v1-nursery-pot-ring-tank.md).

### 🌿 Vægmonteret Hydroponic Tower (v2b — kun planlægning)

Vægophængt tower til krydderurter (basilikum, mynte, persille, koriander) og leafy greens (salat, spinat).
Deler MCU + firmware-platform med plantekrukken.

→ Se [tower/design-notes.md](tower/design-notes.md) for løbende planlægning.

## Quick reference

- **Komponentliste / BOM**: [pot/hardware/bom.csv](pot/hardware/bom.csv)
- **Indkøbsliste (begge versioner)**: [docs/shopping-list.md](docs/shopping-list.md)
- **Wiring-diagram**: [pot/hardware/breadboard/wiring-diagram.md](pot/hardware/breadboard/wiring-diagram.md)
- **Planteprofiler**: [docs/plant-profiles.md](docs/plant-profiles.md)
- **Arkitektur**: [docs/architecture.md](docs/architecture.md)
- **Designbeslutninger (ADR)**: [docs/decisions/](docs/decisions/)
- **Research-noter**: [docs/research/](docs/research/) (KiCad rund PCB, piezo-komponenter, DTU-komponentshop)
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
