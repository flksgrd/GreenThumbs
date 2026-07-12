# ADR 009 — Zero-penetration reservoir + fysisk overflow-beskyttelse

**Status:** Accepted
**Dato:** 2026-07-13

## Context

To relaterede problemer blev identificeret efter variant A-implementeringen:

**1. Overfyldnings-risiko (rejst af bruger):** Cuppen har drænhuller i bunden og hænger nedsænket i reservoiret. Overstiger vandstanden cup-bund-niveauet, suger jorden sig mæt gennem hullerne → vandlogging → rodforrådnelse. Den eneste beskyttelse var software (buzzer-beep + HomeKit-visning) — utilstrækkeligt mod en distraheret påfyldning.

**2. Lækage-punkter under vandlinjen (fundet ved gen-inspektion):**
- Water-strip "slotten" skar radialt HELT gennem reservoir-væggen (z=8-58) — åbent hul under vandlinjen
- Pump-porten var et åbent Ø8-hul i reservoir-bunden med en slange igennem — vand siver langs slangen ned mod elektronikken
- Sensor-kabler (soil, strip, float) havde ingen designet vej fra reservoir/cup ned til elektronikken overhovedet

Fælles mønster: enhver gennemføring under vandlinjen er et lækage-punkt der kræver tætning (grommets, glands, O-ringe) som kan fejle over måneder.

## Decision

### A. Zero-penetration princip

**Reservoiret har INGEN gennemføringer under vandlinjen.** Bund og væg er 100% tætte (én solid print). Alle slanger og kabler ruter:

```
[cup/reservoir-features] → op gennem RING-GABET → gennem ÅBNINGER I CUP-FLANGEN
  → ned UDVENDIGT langs reservoiret → ind i ebase via SIDE-GLANDS
```

Konkret vinkel-allokering (set oppefra, håndhævet af rotations-indexering):

| Vinkel | Flange | Reservoir | Ebase (side) |
|---|---|---|---|
| 0° | — | Water-strip guide-ribber (indvendig) | PG7 gland: USB-C |
| 45° | — | — | Drænhul (fail-safe) |
| 90° | Kabel-slids (åben mod kant) | Float-klips i bund | PG7 gland: sensor-kabler |
| 180° | Slange-åbning Ø14 | — | PG9 gland: 2× Ø6 slanger |
| 270° | Refill-åbning | **Overflow-hul** | — |
| 315° | Index-notch (underside) | Index-tap (rim) | — |

- **Water-strip**: holdes af to printede guide-ribber på indervæggen (additivt — intet hul). Kabel op gennem ring-gab.
- **Float switch**: sidder i en print-integreret klips-ring i bunden. Float-kabler er vandtætte; kablet går op gennem vandet/ring-gabet.
- **Pumpe-slanger**: sugeslangen hænger ned i vand-zonen gennem ring-gabet (vægtet ende); trykslangen går op samme vej og ind i cup-toppens side-hul. Begge passerer flangens Ø14-åbning og løber udvendigt ned til ebase's PG9-gland.
- **Rotations-indexering**: tap på reservoir-rim (315°) + notch i flange-underside sikrer at alle åbninger altid flugter.

### B. Fysisk overflow-beskyttelse

**Overflow-hul (Ø5) i reservoir-væggen ved 270°, 8mm under cup-bund-niveau.** Fyldes der forbi, løber overskuddet ud i pyntepotten i stedet for op i jorden. Placeringen lodret under refill-åbningen betyder at overløb ses ØJEBLIKKELIGT mens man hælder.

Konsekvens for kapacitet: max-fill = overflow-niveau → ~814 ml (var ~1018 ved cup-bund-niveau). Stadig 2-3 ugers Monstera-forbrug.

Suppleret af:
- **LECA-lag** (2-3cm lerkugler) i cup-bunden — bryder kapillær kontakt selv ved kortvarig vandkontakt (assembly-guide)
- **Buzzer-tærskler (ADR 008)** relativt til overflow-niveau: 100% = overflow, dobbelt-beep ved 95%
- **Kalibrering**: `adc_full` for water-strip måles ved overflow-niveau — entydigt fysisk referencepunkt

## Consequences

### Positive

- **Nul tætnings-punkter under vand**: lækage-risikoen for elektronikken reduceres fra "flere gaskets skal holde i årevis" til "PETG-printet skal være vandtæt" (kontrollerbart med 3 perimeters + vandtest)
- **Fysisk (ikke software-) beskyttelse mod overfyldning** — virker også ved firmware-crash, sensor-fejl, eller ignoreret buzzer
- **Øjeblikkelig refill-feedback**: overløb ses ved påfyldningshullet
- **Simplere samling**: ingen grommets/møtrikker under vandlinjen; float klipses bare i
- **Entydig sensor-kalibrering**: 100% = overflow-niveau

### Negative

- **Synlige slanger/kabler i ring-gabet og udvendigt** ned til ebase — skjules af pyntepotten, men mindre "integreret" look
- **Kapacitet reduceret ~20%** (814 vs 1018 ml)
- **Overløb ender i pyntepotten** — brugeren skal tømme den ved gentagen overfyldning (acceptabelt: det ER fejl-signalet)
- **Flangen er nu funktionelt kritisk** (åbninger + indexering) — mistes/knækkes den, virker ruteringen ikke
- **Sugeslangen hænger frit** i vand-zonen — kræver en lille vægt/sinker på enden (tilføjet BOM-note)

### Alternativer overvejet

- **Tætnede bund-gennemføringer** (grommets/glands under vandlinjen): forkastet — flere fejlpunkter, sværere samling, og PG-glands i en 3mm printet bund er upålidelige over tid.
- **Tør kabel-skakt integreret i reservoir-væggen** (lodret lukket kanal): elegant men kompleks print-geometri (lange lukkede hulrum = support-problemer), og løser ikke float/strip-montering. Kan genovervejes i v2 custom-design.
- **Kun software-beskyttelse mod overfyldning**: forkastet — utilstrækkeligt, jf. context.

## Implementation notes

- CAD: `reservoir.scad` (overflow, ribber, float-klips, index-tap), `plant_cup.scad` (flange-åbninger, index-notch), `electronics_base.scad` (lukket top, 3 side-glands), `params.scad` (vinkel-allokering dokumenteret i header-kommentar)
- Firmware: refill-detection (ADR 008) skal bruge overflow-relateret skala; `adc_full` kalibreres ved overflow-niveau
- BOM: PG9-gland til slanger (pos 23 udvidet), LECA, slange-sinker
