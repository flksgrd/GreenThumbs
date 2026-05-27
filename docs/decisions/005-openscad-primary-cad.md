# ADR 005 — OpenSCAD som primær CAD

**Status:** Accepted
**Dato:** 2026-05-27

## Context

Plantekrukken har modulært design med flere størrelser (S/M/L plantebeholdere, 700ml/1500ml reservoirs), og brugeren ønsker at samarbejde med Claude Code om CAD-iterationer. Brugeren har studielicens til Fusion 360 men er åben overfor alternativer.

Tre kandidater:

1. **OpenSCAD** — tekstbaseret, parametrisk, gratis, git-friendly diffs.
2. **Fusion 360** — GUI, kraftfuldt, men binære `.f3d`-filer.
3. **FreeCAD** — open-source GUI med parametrisk pipeline; `.FCStd` er binær men mere git-tolerant.

## Decision

Vi bruger **OpenSCAD som primær CAD-værktøj** for alle 3D-printede dele i projektet. Fusion 360 bevares som backup for komplekse organiske geometrier hvis OpenSCAD bliver upraktisk for en specifik del.

## Consequences

### Positive

- **Claude Code kan redigere CAD direkte**: `.scad` er tekstkode, så jeg kan iterere på designet uden eksport/import-flow.
- **Parametrisk i én fil**: `params.scad` definerer alle dimensioner. Skift `cup_size = "M"` → `cup_size = "L"` → re-eksporter STL → ny størrelse klar.
- **Git-friendly**: meaningful diffs på CAD-ændringer. `+ cup_diameter = 140` er klart hvad der skiftede.
- **Reproducerbar build**: STL kan re-genereres fra `.scad` enhver tid, så vi behøver ikke committe binære STL'er (men kan gøre det for convenience).
- **Genbrug via modules**: fælles geometri (M3-insert holes, gasket-grooves) leves i `shared/cad-lib/` og inkluderes med `use <...>`.

### Negative

- **Stejlere læringskurve** for brugere vant til GUI. Visualisering kræver F5 re-render.
- **Mindre intuitiv for organiske former** (sweeps, fillets, lofts). OpenSCAD er bedst til boxy/CSG-baseret geometri — heldigvis matcher det vores krukke-design.
- **Render-tid** for komplekse modeller (>1 min for F6 full render). For interactive design bruger vi F5 preview.
- **STEP-eksport er begrænset**: hvis vi senere vil sende designet til professionel fabrikation, kræver det Fusion-import først.

### Alternativer overvejet

- **Fusion 360 primær**: forkastet pga. binære filer (umulig diff i git) og kræver eksport-step før Claude Code kan se ændringer.
- **FreeCAD**: mellemting; afvist pga. modnnings-issues i topology naming og at OpenSCAD passer bedre til vores parametriske brug-case.
- **build123d / CadQuery (Python-baseret CAD)**: lovende, men kommunity og dokumentation er mindre. Holdt som "kig på i v2 hvis OpenSCAD-syntax bliver byrdefuld".

## Implementation notes

- Alle dimensioner i `pot/cad/source/params.scad` (single source of truth).
- Hver komponent (plant_cup, reservoir, electronics_base, load_cell_mount) har sin egen `.scad`-fil der `use`r params.
- STL-eksport: `openscad -o pot/cad/stl/reservoir-700ml.stl pot/cad/source/reservoir.scad`. Kan automatiseres via Makefile.
- Naming convention for STL: `<part>-<variant>.stl`, fx `plant-cup-M.stl`, `reservoir-1500ml.stl`.
- Prusa-slicer profiler gemmes som `.3mf` i `pot/cad/prusa-profiles/` med material + layer-settings indlejret.
- Hvis en del bliver for kompleks for OpenSCAD: design i Fusion → eksporter STEP → konverter til STL → læg i `pot/cad/stl/` med en `<part>-source-fusion.md`-fil der dokumenterer hvor source-filen ligger.
