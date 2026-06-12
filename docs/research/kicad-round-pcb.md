# Research: KiCad til custom rund PCB (v2)

**Status:** Research-note — implementeres i v2 (custom PCB-fase). Skrevet 2026-06-12.

## Konklusion (TL;DR)

Rund PCB er **fuldt understøttet i KiCad** uden plugins eller tricks. Workflowet er modent, og vi kan genbruge geometri direkte fra vores OpenSCAD-design så PCB'en passer perfekt i electronics_base. Ingen merpris hos prototype-fabrikanter.

## Hvordan: rund board-outline i KiCad

Board-omridset i KiCad defineres af grafiske objekter på **Edge.Cuts**-laget. En lukket form = board-kant; lukkede former INDE i den ydre form = udskæringer (cutouts).

For en cirkulær PCB:
1. PCB Editor → vælg Edge.Cuts-laget
2. "Add graphic circle"-værktøjet → tegn cirkel med præcis diameter
3. Mounting holes: M3-huller placeret så de matcher electronics_base boss-positioner

Krav: omridset skal være en **kontinuert lukket form** (endepunkter skal mødes præcist), ellers fejler DRC/plot.

## DXF-flow fra OpenSCAD (anbefalet)

Vi kan garantere at PCB'en passer i kammeret ved at generere outline fra samme parametriske kilde:

```scad
// pcb_outline.scad — 2D-projektion til DXF-eksport
include <params.scad>

// PCB-diameter: indvendig kammer-radius minus clearance
pcb_clearance = 1.5;
pcb_d = ebase_outer_d - 2 * ebase_wall - 2 * pcb_clearance;

difference() {
    circle(d = pcb_d);
    // M3 mounting holes ved boss-positioner
    for (a = [0, 90, 180, 270])
        rotate([0, 0, a])
            translate([ebase_outer_d / 2 - ebase_wall - 4, 0])
                circle(d = 3.2);
}
```

```bash
openscad -o pcb_outline.dxf pcb_outline.scad
```

I KiCad: File → Import → Graphics → vælg DXF → placér på Edge.Cuts. Mounting holes kan også importeres, eller placeres som footprints (`MountingHole_3.2mm_M3`).

**Fordel:** ændrer vi `ebase_outer_d` i params.scad, re-eksporterer vi DXF og PCB-outline følger med. Single source of truth bevares.

## Kode-defineret KiCad: circuit-synth

Vi har adgang til `circuit-synth` (Python → KiCad skematik/netlist/PCB). Det matcher projektets git-friendly filosofi (ADR 005: OpenSCAD over Fusion af samme grund):

- Skematik defineres i Python → versioneret som kode, meningsfulde diffs
- Genererer KiCad-projektfiler + netlist + BOM
- Claude Code kan redigere kredsløbet direkte

**Vurdering:** Stærk kandidat til v2 PCB-design. Beslutning udskydes til PCB-fasen — men det betyder at vi IKKE behøver tegne skematik manuelt i KiCad GUI.

## v2 PCB design-skitse

| Aspekt | Plan |
|---|---|
| Form | Rund, Ø ≈ 170mm minus clearance (passer ebase indvendigt) |
| Lag | 2-lags (rigeligt til vores lavfrekvente design) |
| MCU | XIAO ESP32-C6 castellated direct-mount (lodde-pads på PCB) |
| Konnektorer | JST-XH langs kanten (soil, water strip, float, HX711, AHT20, buzzer, pumpe) |
| Power | ZY12PDN + MP1584 som moduler (through-hole headers) eller diskret buck on-board |
| Mounting | 4× M3-huller matchende electronics_base bosses |
| Antenne-hensyn | XIAO's antenne skal vende mod kammerets kant, fri for kobber-plane under |

## Produktion

JLCPCB / PCBWay / Aisler håndterer runde boards uden merpris — prisen beregnes af bounding box. 2-lags Ø170mm prototype: ~15-25 USD for 5 stk hos JLCPCB (plus fragt/told).

**OBS:** Ø170mm er stort for en PCB — overvej om PCB'en reelt behøver fylde hele kammeret, eller om en mindre Ø100mm centreret PCB med kabler til kant-monterede komponenter er billigere og enklere.

## Kilder

- [KiCad PCB Editor docs (board outline)](https://docs.kicad.org/9.0/en/pcbnew/pcbnew.html)
- [KiCad forum: How to define the board outline](https://forum.kicad.info/t/how-to-define-the-board-outline-pcb-edge/32166)
- [Wayne and Layne: KiCad PCB edges tutorial](https://www.wayneandlayne.com/blog/2013/02/26/kicad-tutorial-pcb-edges/)
