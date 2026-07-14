# ADR 010 — Scalloped cup med service-kanaler (erstatter ring-gab)

**Status:** Accepted
**Dato:** 2026-07-14
**Erstatter delvist:** ADR 009's ring-gab-rutering (zero-penetration princippet består uændret)

## Context

Efter det adaptive diameter-redesign (fast ring_gap = 20mm) påpegede brugeren
at det koncentriske ring-gab er spild: i M-størrelsen ofres ~40% af det indre
tværsnit (10.053 mm² ring mod 15.394 mm² cup) til hvad der overvejende er tom
luft — kun tre smalle zoner bruges reelt (slanger, kabler, refill/strip).
Planten er ligeglad med om dens jord er perfekt cirkulær.

Brugerens forslag: gør cuppen ikke-cirkulær med lodrette kanaler til hver
funktion, og lad kanalernes asymmetri sikre korrekt orientering.

## Decision

**Cuppen fylder næsten hele reservoir-åbningen (1mm kant-clearance) og har
3 lodrette SERVICE-KANALER — konkave cirkel-udskæringer i kanten, centreret
på cup-omkredsen, med hver sin funktion og bevidst forskellige størrelser:**

| Vinkel | Kanal | Ø | Indhold |
|---|---|---|---|
| 90° | Kabel-kanal | 16 | Soil/strip/float-kabler (op til flangen, ned udvendigt til PG7-gland) |
| 180° | Slange-kanal | 18 | Suge- + trykslange (Ø6); trykslangens dyse-hul sidder i kanal-fladen nær cup-toppen |
| 270° | Refill-kanal | 28 | Påfyldning (vandkande-tud) + water-strip med guide-ribber på reservoir-væggen |

Kanalerne fortsætter op gennem flangen (klippet til reservoir-åbningen så
påfyldt vand kun kan lande i reservoiret). Implementeret som 2D-profil
(`circle - kanaler`) ekstruderet; hulrummet er samme profil offset
`cup_wall` indad — vægtykkelsen følger dermed kanal-konturen.

### Orientering og centrering — gratis

- **Rotations-lås:** water-strip-ribberne på reservoir-indervæggen (ved
  270°, nu i FULD højde) spænder ~26mm — de kan kun passere gennem
  refill-kanalen (Ø28). Kabel- (16) og slange-kanalen (18) er for smalle.
  Cuppen kan derfor fysisk kun sænkes ned i ÉN rotation.
- **Centrering:** 1mm kant-clearance — cuppen kan maksimalt forskydes 2mm.
- Rim-tapperne + flange-lommerne fra forrige iteration er FJERNET
  (overflødige).

## Consequences

### Positive

- **Maksimalt jordvolumen:** kanalerne koster ~700-900 mm² mod ring-gabets
  ~10.000 mm². Brugerens Monstera-potte (indre Ø260): cup vokser fra Ø190
  til Ø230 = +46% jord-areal.
- **Mindre fodaftryk for samme plante:** M-sæt er nu ydre Ø148 (var Ø186).
- **Orientering + centrering uden ekstra features** (tapper/lommer droppet).
- **Zero-penetration består:** kanalerne er stadig tørre servicekanaler over
  vandlinjen; reservoiret er stadig uden gennemføringer.
- Matcher brugerens skitse 1:1.

### Negative

- **Kapacitet per cup-størrelse falder** (reservoir-fodaftryk følger nu
  cuppen): S ~261 ml, M ~507 ml, L ~832 ml, CUSTOM-eksempel ~1353 ml.
  Kompenseres ved at vælge cuppen så stor som pyntepotten tillader (hele
  pointen), eller ved at øge `water_zone_h` (40 → fx 55mm giver +47%
  kapacitet for +15mm højde).
- **Refill-åbningen er mindre** end vandkande-venlige Ø18+ i gamle design?
  Nej — refill-kanalen er Ø28, større end før. OK.
- Cup-print er marginalt mere komplekst (konkave flader) — men lodrette
  vægge, ingen support.
- Strip-ribber i fuld højde bruger lidt mere filament.

### Alternativer overvejet

- **Koncentrisk ring-gab (forrige design):** forkastet — 40% arealspild.
- **Kanaler som lukkede rør i cup-væggen:** tættere, men kabler med stik
  kan ikke trækkes igennem, og print kræver support i lukkede kanaler.
  Åbne konkave kanaler er tilgængelige fra siden ved montering.
- **4. kanal til water-strip separat:** unødvendig — strippen deler
  refill-kanalen (den er vandtæt og måler netop vand; påfyldnings-strøm
  forbi den er uproblematisk).

## Implementation notes

- `params.scad`: `channel_{cable,hose,refill}_{angle,d}`, `cup_clearance=1`;
  `ring_gap`, `rim_tab_*`, `hose_pass_*`, `refill_opening_*`, `cable_slot_w`
  fjernet
- `plant_cup.scad`: 2D-profil-arkitektur (`cup_profile_2d()` +
  `channel_cutouts_2d()`), flange med klippede kanal-udskæringer
- `reservoir.scad`: strip-ribber flyttet 0° → 270° og forlænget til fuld
  højde (rotations-lås); rim-tapper fjernet
- Ebase-glands uændret (90°/180° matcher kanalerne lodret)
- Størrelser (ydre Ø / kapacitet / total højde): S 108/261ml/208 —
  M 148/507ml/248 — L 188/832ml/288 — CUSTOM(Ø230-cup) 238/1353ml/233
