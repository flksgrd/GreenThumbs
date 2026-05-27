# 🌿 Vægmonteret Hydroponic Tower (v2)

**Status:** Designfase — bygges IKKE i denne iteration. Opdateres løbende mens vi lærer fra plantekrukke-prototypen (`pot/`).

Hydroponic vægmonteret tower til **krydderurter** (basilikum, mynte, persille, koriander) og **leafy greens** (salat, spinat, grønkål).

## Hvorfor først nu (efter pot)

Tower og pot deler:
- **MCU-platform**: XIAO ESP32-C6 + ESP-Matter SDK
- **Pumpe-driver-arkitektur**: MOSFET-style switching
- **Sensor-stack** (delvist): water level + float switch
- **Firmware-skelet**: FreeRTOS-task arkitektur, NVS-baseret config

Ved at bygge pot først, validerer vi al elektronik + firmware. Tower bliver så primært en **mekanisk + plumbing-udfordring** med velkendt elektronik.

## Quick reference

- [design-notes.md](design-notes.md) — **løbende design-noter** (opdateres mens vi lærer fra pot)
- [preliminary-bom.md](preliminary-bom.md) — foreløbig komponentliste
- [references.md](references.md) — inspirations-designs, links, papers

## Concept

```
┌─────────────────────────┐  ← Vægbeslag
│  Plant slot 1 (top)    │  ← Krydderurter i net cups
├─────────────────────────┤
│  Plant slot 2          │  ← Vand recirkuleres ned
├─────────────────────────┤
│  Plant slot 3          │
├─────────────────────────┤
│  Plant slot 4          │
├─────────────────────────┤
│  Plant slot 5 (bottom) │
├─────────────────────────┤
│  RESERVOIR + PUMP      │  ← Submersible aquarium pumpe
│  (synlig vandlinje)    │  ← Transparent "vindue"
│  + Water level sensor  │
└─────────────────────────┘
   ↑
   Strøm via stikkontakt / lampeudtag
```

## Forskelle fra pot

| Aspekt | Pot (v1) | Tower (v2) |
|---|---|---|
| Vandingsstrategi | Drip via peristaltisk | Continuous recirculation |
| Pumpe-type | Peristaltisk 12V | Submersible aquarium (5V eller 12V) |
| Medium | Jord | LECA/clay pebbles eller rockwool |
| Plante-detektion | Soil moisture + vægt | N/A (vand altid tilstede; tjek pH/EC) |
| Reservoir | 700-1500 ml | 2-4 L (mindre genopfyldnings-frekvens) |
| Strøm | USB-C kablet | AC stikkontakt (større pumpe) |
| Storage | Compact under pot | Hele bottom-segmentet |

## Roadmap

- [ ] v1 (pot) firmware fungerer ende-til-ende
- [ ] Udfyld design-notes.md med erfaringer fra pot-byg
- [ ] Beslut: NFT (Nutrient Film Technique) vs DWC (Deep Water Culture) vs vertical drip
- [ ] Skitse tower-design (5-7 plante-slots?)
- [ ] LED grow lights? (krydderurter klarer sig i vindueslys; salat behøver mere)
- [ ] pH + EC monitoring (basic eller skip i v2?)
- [ ] Foreløbig BOM
- [ ] OpenSCAD-design af tower-segmenter
- [ ] PETG-print + samling
- [ ] Live test med basilikum + mynte

## License

Same as project root — MIT.
