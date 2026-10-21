# 🪻 Pot-Orchid — automatisk soak-vanding til orkideer

**Status:** Design v0 (oktober 2026) — CAD for alle dele + koncept besluttet
([ADR 011](../docs/decisions/011-orchid-flood-and-drain.md)). Intet printet.

Dedikeret variant til **Phalaenopsis i bark**. I stedet for pot/'s top-drip
oversvømmes barken nedefra i 5-20 min og tømmes derefter helt — som når man
sætter en orkide i blød i vasken, bare automatisk.

## Sådan virker den

```
  ┌══[ FLANGE ]══════════════════┐
  │  ORKIDE-CUP (klar PETG)      │  bark + rødder; bund-huller + side-slidser
  │  ~~~~~~~ max soak ~~~~~~~~~~ │← overflow-hul udad (fysisk loft)
  │  SOAK-KAMMER (klar PETG)     │  fyldes og tømmes af pumpen
  ╞═════ gulv (opak) ═══ sump ═══╡
  │  LAGER (opak PETG)  ~~~~~~~  │← overflow-hul udad; float switch i bund
  │        ║ tør skakt ║         │  slanger + kabler går her
  ╞════════╩═══════════╩═════════╡
  │  ELECTRONICS BASE + pumpe    │
  └──────────────────────────────┘
       LOAD CELL (påkrævet)
```

1. **Trigger:** load cell'en ser at barken har tabt nok vægt siden sidste soak
2. **Fyld:** pumpen kører forlæns, lager → soak-kammer (~2,5 min, 260 ml/min)
3. **Soak:** står i `soak_hold_s` (default 10 min)
4. **Dræn:** pumpen kører baglæns, sump → lager, indtil Grove-sensoren viser
   tomt kammer

| Beregnet (12cm Phalaenopsis) | |
|---|---|
| Cup | Ø132 × 115mm (klar PETG) |
| Soak-volumen | ~655 ml |
| Lager | ~1,2 L (~550 ml reserve ≈ 3-5 uger mellem påfyldning) |
| Fyld / dræn | ~2,5 min hver vej |
| Total højde | 266mm (+33mm load cell) |
| Base-diameter | Ø170mm (bred for stabilitet med høj blomsterstængel) |

## Filer

- [cad/source/](cad/source/) — OpenSCAD: `params.scad`, `orchid_cup.scad`,
  `soak_chamber.scad`, `storage.scad`, `ebase_orchid.scad`, `assembly.scad`
- [cad/preview/](cad/preview/) — renders: iso, snit i hvile, snit under soak,
  top, eksploderet
- [preliminary-bom.md](preliminary-bom.md) — hvad der adskiller BOM'en fra pot/
- [design-notes.md](design-notes.md) — åbne punkter og næste skridt
- [references.md](references.md) — kilder og prior art

## Genbrug fra pot/

MCU, strømdel, AHT20, Grove water level, float switch, buzzer, HX711 + load
cell, firmware-skelet og Matter-opsætning genbruges. Nyt: større vendbar
pumpe (Kamoer KPHM200) med H-bro (DRV8871), klar PETG, tør skakt i stedet for
side-glands. Se [preliminary-bom.md](preliminary-bom.md).

## License

Same as project root — MIT.
