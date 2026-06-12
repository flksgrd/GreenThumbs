# OpenSCAD CAD Source

Parametriske 3D-modeller for plantekrukken. Alle dimensioner styres fra `params.scad`.

## Workflow

**For at se og rendere geometri:** Åbn én af part-filerne (ikke `params.scad`).

| Fil | Hvad det renderer |
|---|---|
| [params.scad](params.scad) | Ingen geometri — kun variable + echo til console. Åbn for at *redigere* dimensioner. |
| [plant_cup.scad](plant_cup.scad) | Skifteligt indre kop (jord + plante). Størrelse styret via `cup_size`. |
| [reservoir.scad](reservoir.scad) | Vand-beholder med sensor-slots + pump-port + refill-notch. |
| [electronics_base.scad](electronics_base.scad) | Vandtæt elektronik-kammer + aftageligt låg (renderes side-by-side). Lid har **dual-footprint pump-mount**: Kamoer KPP (2× M3, 46mm c-c) eller Bartels BP7 piezo + driver (4× M3, 24mm kvadrat) — se [piezo-research](../../../docs/research/piezo-components.md). |
| [load_cell_mount.scad](load_cell_mount.scad) | Vægt-platform (lower plate + upper plate + load cell visualisering). |

## Skift plantestørrelse

1. Åbn `params.scad` i din editor (VS Code, Antigravity, eller OpenSCAD).
2. Ændr `cup_size = "M"` → `"S"` eller `"L"`.
3. Gem filen.
4. Åbn `plant_cup.scad` i OpenSCAD.
5. **F5** for preview, **F6** for full render, **File → Export → Export as STL**.

**Tip:** I OpenSCAD, aktivér `Design → Automatic Reload and Preview`. Så genindlæses `plant_cup.scad` automatisk når du ændrer `params.scad` i et andet program.

## Eksportér alle STL'er fra kommandolinje

```bash
cd pot/cad/source
OPENSCAD=/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD

# Plant cups i alle 3 størrelser
for size in S M L; do
    $OPENSCAD -D "cup_size=\"$size\"" -o ../stl/plant-cup-$size.stl plant_cup.scad
done

# Reservoirs i begge volumer
for vol in 700 1500; do
    $OPENSCAD -D "reservoir_volume_ml=$vol" -o ../stl/reservoir-${vol}ml.stl reservoir.scad
done

# Electronics base + lid
$OPENSCAD -o ../stl/electronics-base.stl electronics_base.scad
# (Lid renderes sammen med base; manuel split for nu)

# Load cell mount
$OPENSCAD -o ../stl/load-cell-mount.stl load_cell_mount.scad
```

## Print-strategi

1. **Validér først i PLA** (billigt, hurtigt). Tjek dimensioner, snap-fits, hulplaceringer.
2. **Iterér** — typisk 2-3 print-runs før alle mål er rigtige.
3. **Endelig print i PETG** for vand-kontakt dele (plant_cup, reservoir, electronics_base).
4. **Load cell mount + lid** kan blive i PLA (ingen vand-kontakt).

## Wick installation (bottom-watering for African Violet, Peace Lily, Calathea)

For planter der foretrækker bottom-watering installeres en cotton/nylon-wick gennem center-drænhullet:

1. Tag ~15cm 4mm flettet bomulds- eller nylon-snor.
2. Inden plant cup fyldes med jord: træd snoren gennem center-drænhullet (det centrale 4mm hul i hex-mønstret).
3. Lad 6-8cm gå op i jord-zonen og 6-8cm hænge ned.
4. Læg lidt jord under wick'en så den holdes på plads.
5. Fyld resten af jorden om wick'en — kompakt let.
6. Når cup placeres i reservoir, skal den nedhængende ende dyppe i vandet.

Ingen CAD-ændring nødvendig — eksisterende 4mm center drænhul er rigeligt for 4mm snor. Se [ADR 006](../../../docs/decisions/006-bottom-watering-strategies.md) og [plant-profiles.md](../../../docs/plant-profiles.md) for hvilke profiler der bruger wick.

## Stack-geometri: Variant A (besluttet 2026-06)

Cuppen hænger **nedsænket** i reservoiret fra sin universal-flange (Ø202,
ens for alle cup-størrelser). Vandet lever i 40mm-zonen under cup-bunden +
ringen omkring cuppen. Kapacitet ~1018 ml uanset cup-størrelse.

| cup_size | Cup | Reservoir-højde | Total stak (m. ebase+lid) |
|---|---|---|---|
| S | Ø100×120 | 159mm | ~208mm |
| M | Ø140×160 | 199mm | ~248mm |
| L | Ø160×200 | 239mm | ~288mm |

Bemærk: L-cup er Ø160 (ikke 180) — der skal altid være ≥10mm ring-gap til
pumpe-slange, water-strip og refill. Slangen ruter: ebase → reservoir-bund
port (x=85, i ring-gabet) → op gennem ringen → flange-hul (180°) → cup-top
side-hul. Refill: gennem flange-åbningen ved 270° direkte ned i ringen.

Verificér samlingen visuelt med [assembly_check.scad](assembly_check.scad)
(halv-snit af cup+reservoir+vand). Render: [preview](../preview/stack-variant-A-assembly.png).
[stack_variants_preview.scad](stack_variants_preview.scad) er det historiske
beslutningsgrundlag (A vs B) og holdes ikke opdateret.

## v1 → v1.1 TODO

Ting der mangler men ikke blokerer for første prototype:

- [ ] Soil sensor mount: integreret holder på cup (eller separat clip-on del)
- [ ] Pump-slange grommet i electronics base top
- [ ] Refill funnel-design (separat top-del der klikker på reservoir)
- [ ] Drip ring på top af plant cup (jævn fordeling af vand)
- [ ] Snap-fit cable gland (alternativ til M12/PG7 metal glands)
- [ ] Hex-pattern dræn i bund (lige nu er det 1 center + 6 ring; hex giver bedre flow)
- [ ] Optional wick-guide tube under center drænhul (holder wick aligned + minimiserer sideways drag)
