# ADR 011 — Pot-Orchid: to-kammer flood-and-drain med vendbar pumpe

**Status:** Accepted (design v0 — ikke printet)
**Dato:** 2026-10-21
**Erstatter:** soak-tray-konceptet i pot-orchid/design-notes.md (maj/juni),
som var skrevet før ADR 009 (zero-penetration) og ADR 010 (scalloped cup)

## Context

Phalaenopsis i bark skal vandes ved nedsænkning: barken oversvømmes, står
5-20 min og skal derefter drænes HELT, så rødderne ikke står i vand.
Kilderne er uenige om soak-tiden ([UConn](https://homegarden.cahnr.uconn.edu/?p=558):
~20 min; [smartgardenguide](https://smartgardenguide.com/?p=514): max 5 min),
så soak-tiden skal være en profil-parameter.

pot/'s geometri forhindrer bevidst vandet i at nå cup-bunden (kommunikerende
kar → jorden ville drukne). Til orkideen er det netop det vi vil — men kun i
soak-tiden. Det kræver to vandvolumener: et soak-kammer der kan fyldes og
tømmes, og et lager der holder vandet i mellemtiden.

Prior art: [MakerWorld automatic orchid watering system](https://makerworld.com/en/models/380211-15cm-automatic-orchid-watering-system)
pumper vand op med en akvariepumpe, holder niveauet i 2 min med en sensor og
lader vandet løbe ned gennem drænhuller.

## Decision

**To kamre med én vendbar peristaltisk pumpe** (brugervalg 2026-10-21):

```
  ┌══[ FLANGE ]══════════════════┐
  │  ORKIDE-CUP (klar PETG)      │  bark + rødder; bund-huller + side-slidser
  │  ~~~~~~~ max soak ~~~~~~~~~~ │← overflow-hul UDAD (fysisk loft)
  │  SOAK-KAMMER (klar PETG)     │  fyldes/tømmes af pumpen; gulv hælder
  ╞═════ gulv (opak) ═══ sump ═══╡    mod sumpen
  │  LAGER (opak PETG)  ~~~~~~~  │← overflow-hul UDAD; float switch i bund
  │        ║ tør skakt ║         │  skakten: fra ebase op over max soak
  ╞════════╩═══════════╩═════════╡
  │  ELECTRONICS BASE + pumpe    │
  └──────────────────────────────┘
       LOAD CELL (påkrævet)
```

- **Fyld:** pumpen kører forlæns (lager → soak-kammer) til Grove-sensoren
  viser soak-dybden
- **Soak:** pumpen står stille i `soak_hold_s` (default 600s, profil-parameter)
- **Dræn:** pumpen kører baglæns (soak-sump → lager) til Grove-sensoren
  viser tomt kammer + efterløb
- **Pumpe:** Kamoer KPHM200 (12V 0.7A, 260 ml/min ifølge [forhandleren](https://st.robu.in/?p=1954055)).
  Med ~655 ml soak-volumen tager fyld og dræn ~2,5 min hver vej.
  pot/'s KXF-DC (37 ml/min) ville give >30 min våde rødder; piezo-pumpen
  (9 ml/min) over en time → begge fravalgt til orkide.
- **Driver:** H-bro (DRV8871) i stedet for MOSFET — en børstet DC-pumpe
  vender retning ved ompoling. IN1 = D10, IN2 = D1 (frigjort i BOM-rettelsen).
- **Cup + kammer i klar PETG:** Phalaenopsis-rødder laver fotosyntese;
  [AOS](https://secure.aos.org/media/Content-Images/PDFs/GrowingtheBestPhalaenopsisPart_2.pdf)
  rapporterer at flertallet af avlere i Taiwan/Holland bruger klare potter.
  Kammer-GULVET printes opakt (filamentskift), så lys ikke når lageret.

### Zero-penetration (ADR 009) bevaret — via en tør skakt

Lageret har ingen gennemføringer under vandlinjen ud mod elektronik eller
omgivelser. Slanger og kabler går gennem en **tør skakt**: et rør der er en
del af lager-printet, åbent ned i electronics base og med top 20mm OVER max
soak-niveau. Vand kan kun komme ind fra toppen.

Interne gennemføringer mellem soak-kammer og lager er tilladt — en lækage
dér flytter blot vand fra kammer til lager (dræn-retningen):
- Skakten går gennem soak-gulvet. Gulvet hviler på en krave på skakten med
  en pakning (EPDM/TPU) — uden den ville spalten (0,3mm om Ø20) dræne
  kammeret på under et minut.
- Påfyldnings-røret er en del af soak-kammer-printet og munder direkte ud i
  lageret.

### Fysiske lofter (ADR 009-princippet)

- **Soak-kammer:** overflow-hul UDAD ved max soak-niveau → selv en pumpe-
  runaway kan ikke oversvømme cuppen højere end soak_depth.
- **Lager:** overflow-hul UDAD under kraven → lageret kan aldrig fyldes så
  højt at vand løber tilbage op i soak-kammeret.

### Orientering og centrering

Som ADR 010: scalloped cup med 3 kanaler (90° sensor, 180° skakt, 270°
påfyldning). Skakten står fast i lageret og er nøglen — kollisionstest:
cuppen passer kun i 0°; 90°/180°/270° kolliderer med skakten.

### Sensorer — samme dele som pot/, ny placering

| Sensor | pot/ | pot-orchid/ |
|---|---|---|
| Grove water level (I2C) | Reservoir (refill-feedback) | **Soak-kammer**: styrer fyld-dybde og bekræfter fuld dræn |
| Float switch | Reservoir-bund | **Lager-bund** (low-water) |
| HX711 + load cell | Optional | **Påkrævet**: soak-trigger (vægttab = barken tørrer, ADR 004) OG lager-niveau/refill-feedback til buzzeren |
| Soil moisture | Primær | **Udgår** (upålidelig i bark) |
| AHT20 | Standard | Standard (orkideer vil have 50-70% RH — nyttigt i HomeKit) |

Load cell'en måler totalvægt, så intern flytning mellem kamrene ændrer den
ikke. Baseline tages efter fuld dræn; vægttab derefter = fordampning +
transpiration (overvejende barken der tørrer).

## Consequences

### Positive
- Ægte soak med præcis, software-styret soak-tid (profil-parameter)
- Ingen ventiler, ingen små huller der kan stoppe til af bark-smuld
- Rødderne kan aldrig stå i vand pga. en fejl: dræn verificeres af Grove-
  sensoren, og max-niveauet er fysisk begrænset
- Genbruger pot/'s MCU, sensorer, strømdel og firmware-skelet

### Negative
- Høj stak: ~266mm (+33mm load cell). Display-vase, ikke til at gemme i en
  pyntepotte — klar cup giver kun mening hvis lys når rødderne
- Overflow-huller drypper udad → stå på en underskål (sker kun ved
  overfyldning eller firmware-fejl)
- Større, dyrere pumpe + H-bro; ebase er højere (60mm) end i pot/
- Skaktens top er en åbning ned til elektronikken — kræver stænk-hætte
  (TODO) så man ikke hælder vand i den forkerte kanal

### Alternativer overvejet
- **Fyld-og-hold med drænhuller (MakerWorld-princip):** simpel elektronik,
  men kræver akvariepumpe (tåler ikke tørløb, strider mod ADR 001) og små
  huller der stopper til.
- **Magnetventil til dræn:** ekstra del + hul under vandlinjen + fejlrisiko
  (sidder den fast lukket, står rødderne i vand).
- **Bell-siphon:** passiv, men kræver langt højere flow end en peristaltisk
  pumpe for at starte pålideligt.

## Implementation notes

- CAD: `pot-orchid/cad/source/` — `params.scad` (alle mål + beregnet
  soak-volumen, lager-kapacitet, fyldtid), `orchid_cup.scad`,
  `soak_chamber.scad`, `storage.scad`, `ebase_orchid.scad`, `assembly.scad`
  (views: iso | section | soaking | top | exploded)
- Beregnet (12cm Phalaenopsis, cup Ø132×115): soak-volumen ~655 ml,
  lager ~1,2 L (reserve ~550 ml efter én soak ≈ 3-5 ugers forbrug), fyld/dræn
  ~2,5 min hver vej, total højde 266mm
- Firmware (TODO): ny `soak_cycle.cpp` — IDLE → FILL → SOAK → DRAIN → VERIFY.
  Profilen får `soak_hold_s` og fyld-dybde i stedet for v1's
  drip-burst-felter (`soak_seconds`/`soak_repeats`/`soak_pause_seconds`)
- Åbne punkter: se `pot-orchid/design-notes.md`
