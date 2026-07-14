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

## Stack-geometri: Variant A + adaptiv diameter (2026-07)

Cuppen hænger **nedsænket** i reservoiret fra sin flange. Vandet lever i
zonen under cup-bunden (op til overflow-niveau, ADR 009) — ring-gabet er
en TØR servicekanal.

**Adaptivt design:** cup-størrelsen driver ALLE diametre via et **fast
ring_gap på 20mm** — reservoir, electronics base, lid og load cell-platform
skalerer med. Hver størrelse er et **matchende sæt** (reservoir/base
re-printes per størrelse); til gengæld er gabet altid ens, og reservoiret
maksimalt for pyntepotten.

| cup_size | Cup | Reservoir ydre Ø | Kapacitet | Total højde | Pyntepotte (indre) |
|---|---|---|---|---|---|
| S | Ø100×120 | 146 | ~493 ml | ~208mm | ≥ Ø166 |
| M | Ø140×160 | 186 | ~814 ml | ~248mm | ≥ Ø206 |
| L | Ø180×200 | 226 | ~1216 ml | ~288mm | ≥ Ø246 |
| CUSTOM (eksempel) | Ø190×145 | 236 | ~1330 ml | ~233mm | Ø260×230 (Monstera-potte) |

**CUSTOM**: sæt `custom_cup_diameter`/`custom_cup_height` i params.scad frit
efter din pyntepotte — echo-outputtet viser pyntepotte-kravet direkte.

**Centrering + rotations-lås:** 4 tapper på reservoir-rimmen (asymmetriske
vinkler 30/150/210/315°) griber op i lommer i flangens underside. Cuppen
kan kun sidde i ÉN orientering og altid præcist centreret — ring-gabet er
ens hele vejen rundt, og flange-åbningerne flugter altid med reservoirets
features (overflow under refill osv.).

Visualisér med [assembly_check.scad](assembly_check.scad) — view-modes:
`iso|section|top|exploded|reservoir|ebase` (se fil-header). Renders i
[../preview/](../preview/). [stack_variants_preview.scad](stack_variants_preview.scad)
er historisk beslutningsgrundlag (A vs B) og holdes ikke opdateret.

## v1 → v1.1 TODO

Ting der mangler men ikke blokerer for første prototype:

- [ ] Soil sensor mount: integreret holder på cup (eller separat clip-on del)
- [ ] Pump-slange grommet i electronics base top
- [ ] Refill funnel-design (separat top-del der klikker på reservoir)
- [ ] Drip ring på top af plant cup (jævn fordeling af vand)
- [ ] Snap-fit cable gland (alternativ til M12/PG7 metal glands)
- [ ] Hex-pattern dræn i bund (lige nu er det 1 center + 6 ring; hex giver bedre flow)
- [ ] Optional wick-guide tube under center drænhul (holder wick aligned + minimiserer sideways drag)
