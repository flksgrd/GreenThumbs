# 🪻 Pot-Orchid — Dedikeret orkide-krukke med soak-tray (v2)

**Status:** Designfase — bygges IKKE i denne iteration. Planlægges parallelt med v1 og vil bygge oven på lessons learned.

Dedikeret variant af plantekrukken designet specifikt til **orkider** (primært Phalaenopsis i bark-medium) og potentielt **store succulenter** der har gavn af ægte soak-watering.

## Hvorfor en separat krukke

Standard `pot/` v1 bruger top-drip via peristaltisk pumpe + drip-ring. Det virker godt for jord-baserede planter, men:

- **Orkide i bark**: bark-medium suger vand bedst ved nedsænkning (10-15 min soak), ikke drip. v1 approksimerer via 3×10s drip-bursts, men det er ikke ægte soaking.
- **Succulenter med tæt rosette** (Echeveria, Sempervivum, kaktus): top-drip kan ramme rosette-centrum → kronrådne. Bottom-watering via soak er sikrere.

Wick-løsningen i v1 dækker fugt-elskere (Peace Lily, African Violet, Calathea) men ikke orkide/succulent — disse vil have **tørre perioder** mellem soak-events, ikke konstant fugt.

→ Se [ADR 006](../docs/decisions/006-bottom-watering-strategies.md) for fuld kontekst.

## Quick reference (udfyldes løbende)

- [design-notes.md](design-notes.md) — løbende design-noter
- [references.md](references.md) — orkide-pleje litteratur, eksisterende designs
- preliminary-bom.md — kommer efter v1-validering

## Concept

```
┌──────────────────────────────┐
│  Lid med refill-tragt        │
├──────────────────────────────┤
│  INNER PLANT CUP             │  ← bark-medium, ikke jord
│   • Større drænhuller        │
│   • Soaker fra bunden via    │
│     tray-overflow            │
├──────────────────────────────┤
│  SOAK TRAY                   │  ← KEY DIFFERENCE
│   • Fyldes via pump (10-15min│
│     med vand op til soak-line│
│   • Drænes via solenoid eller│
│     passiv overflow tilbage  │
│     til reservoir            │
├──────────────────────────────┤
│  RESERVOIR                   │
├──────────────────────────────┤
│  ELECTRONICS BASE            │
│   • + solenoid driver         │
│   • + drain-control logik    │
└──────────────────────────────┘
```

## Forskelle fra pot/ v1

| Aspekt | pot/ v1 | pot-orchid/ v2 |
|---|---|---|
| Vandingsstrategi | Top-drip via drip-ring | Bottom-soak via tray |
| Pumpe-cyklus | Diskret dose 5-100ml | Fyld tray over 5-10 min |
| Drain-mekanisme | Ingen (cup-drænhuller → reservoir) | Solenoid eller passiv overflow |
| Medium | Jord | Bark (default) eller specialiseret kaktusjord |
| Soil-sensor | Capacitiv (relevant) | Måske irrelevant — vægt + tray-vandstand bruges |
| Tray-vandstand sensor | Ikke nødvendig | Ja (extra capacitive eller float) |
| Cup-design | Drænhuller spredt | Stort centralt drænhul + perimeter for tray-tilstrømning |

## Roadmap

- [ ] v1 (pot/) firmware + hardware fungerer end-to-end
- [ ] v1 wick-test: er bottom-watering tilstrækkeligt for fugt-elskere? Bekræfter behov for soak-tray til orkide/succulenter
- [ ] Udfyld design-notes med valg: solenoid-drain vs passiv overflow
- [ ] Beslut: udvider vi til 2 sizes (orkide small + stor succulent)?
- [ ] Skitse soak_tray.scad
- [ ] Foreløbig BOM (genbrug pot/-komponenter)
- [ ] Print + samling
- [ ] Live test med Phalaenopsis

## Genbrug fra pot/

| Komponent | Genbrug | Note |
|---|---|---|
| XIAO ESP32-C6 + ESP-Matter setup | 100% | Samme MCU + firmware base |
| Peristaltisk pumpe + MOSFET | 100% | Samme driver, anden brug (tray-fyld i stedet for drip) |
| HX711 + 5kg load cell | 100% | Vægt-baseret detektion er endnu vigtigere her |
| Float switch + interlock | 100% | Lavt vand i reservoir |
| ZY12PDN + MP1584 strøm | 100% | Samme |
| Plant profile struct | Udvides | Tilføj soak-tid + drain-tid felter |
| OpenSCAD shared moduler | 100% | M3 inserts, gaskets fra shared/cad-lib |

## Nye ting v2 kræver

- **Soak tray** (3D-printet, vandtæt) der omslutter plant cup
- **Solenoid-ventil** (12V, normalt-lukket) til drain — eller passiv overflow design
- **Tray water level sensor** (capacitive strip eller flydende sensor)
- **Firmware**: tilstands-maskine (FILL → SOAK → DRAIN → DRY) med konfigurérbare tider per plante

## License

Same as project root — MIT.
