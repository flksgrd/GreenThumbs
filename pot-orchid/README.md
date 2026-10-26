# 🪻 Pot-Orchid — automatisk soak-vanding til orkideer

**Status:** Design v1 (oktober 2026) — CAD for alle dele
([ADR 012](../docs/decisions/012-orchid-v1-nursery-pot-ring-tank.md),
batteri: [ADR 013](../docs/decisions/013-battery-1s2p.md)). Intet printet.

Dedikeret variant til **Phalaenopsis i bark**. Orkideen bliver i sin
medfølgende 12cm dyrkningspotte og står i en skål, der fyldes nedefra, står
lidt og tømmes igen — som når man sætter en orkide i blød i vasken, bare
automatisk. Hele tårnet står skjult i en pyntepotte.

## Sådan virker den

```
   ┌ ring-låg ─┐   ┌─ dyrkningspotte ─┐   ┌ ring-låg ┐
   │  LAGER-   │   │     (bark)       │   │  RING    │
   │  RING     │ ~~│~~ skål-kant ~~~~ │~~ │          │  ← soak-loft
   │ ~~~~~~~~  │  S K Å L (konisk)    │   │ ~~~~~~~~ │
   ╞═══════════╧══════════════════════╧═══╧══════════╡  ← tank-gulv (massivt)
   │  BAY: 2× 18650, pumpe, ESP32-H2, H-bro, boost   │
   └─────────────────────────────────────────────────┘
```

1. **Trigger:** hver ~7. dag, justeret med VPD (tør luft → oftere)
2. **Fyld:** pumpen kører forlæns, ring → skål. Skålens kant er loftet —
   overskud løber tilbage i ringen, så dybden er altid den samme
3. **Soak:** står i `soak_hold_s` (default 5 min)
4. **Dræn:** pumpen kører baglæns, sump → ring, indtil den berøringsfri
   sensor under skålen melder tom

| Beregnet (12cm Phalaenopsis) | |
|---|---|
| Tårn | Ø180 × 133mm med fod Ø152 forneden (+ potten → top i 163mm) |
| Pyntepotte (målt) | Ø210, afsats 160mm nede, udhulet bund Ø160×28 → pottens top 25mm under kanten |
| Soak-dybde | 68mm over pottens bund (~62% af potten) |
| Soak-volumen | ~376 ml |
| Lager-ring | ~880 ml (~500 ml reserve ≈ 3-5 uger) |
| Fyld / dræn | ~5,4 min hver vej (Kamoer NKP, ≥70 ml/min, 3,6W) |
| Strøm | 2× 18650 (1S2P), ~3-5 mdr. pr. opladning (estimat) |
| Ladning | USB-C i ring-låget, eller stil tårnet på ladebasen (MagSafe/Qi) — ~12-14 t |
| Filament | ~750g opak PETG massiv inkl. ladebase (mindre med infill) |

Påfyldning: gennem hullet i ring-låget, eller løft planten og hæld i
skålen — det løber over i ringen.

## Filer

- [cad/source/](cad/source/) — OpenSCAD: `params.scad`, `tank.scad`
  (ring + skål + skakt + float-beslag), `lid.scad`, `bay.scad`,
  `charging_base.scad` (ladebase til MagSafe), `assembly.scad`
- [cad/preview/](cad/preview/) — renders: iso, snit i hvile, snit under soak,
  top, eksploderet, Qi i bay'en, ladebase, tårnet på ladebasen
- [preliminary-bom.md](preliminary-bom.md) — hvad der adskiller BOM'en fra pot/
- [design-notes.md](design-notes.md) — åbne punkter og næste skridt
- [references.md](references.md) — kilder og prior art

## Genbrug fra pot/

MCU, batteri/strømdel, AHT20, buzzer, knap, firmware-skelet og Matter-
opsætning. Nyt: vendbar pumpe (Kamoer NKP) med H-bro (DRV8871),
berøringsfri niveausensor under skålen, to mini-floats i ringen. Ingen
load cell, ingen soil- eller Grove-sensor. Se [preliminary-bom.md](preliminary-bom.md).

## License

Same as project root — MIT.
