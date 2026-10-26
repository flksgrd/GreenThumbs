# ADR 012 — Pot-Orchid v1: dyrkningspotte i skål, lager-ring, selvnivellerende soak

**Status:** Accepted (design v1 — ikke printet)
**Dato:** 2026-10-21
**Erstatter:** geometrien i ADR 011 (v0). Princippet fra ADR 011 — vendbar
peristaltisk pumpe, fyld → soak → dræn — videreføres.

## Context

Brugeren afklarede efter v0:
- Orkideen står i en **pyntepotte** (ikke fremme) → klar PETG er unødvendig;
  rødderne må undvære fotosyntese
- Planten skal **blive i sin medfølgende 12cm dyrkningspotte** og stå i en
  skål med høje sider — vi designer et tårn med en skål ovenpå
- Det er OK at løfte planten op for at fylde vand på
- Pyntepotten (målt med målebånd 2026-10-26, ±~3mm): Ø210 ved åbningen,
  160mm ned til en afsats der går 20mm ind, derunder en udhulet bund
  Ø160 × 28mm → 188mm indvendig dybde i alt
- Trigger: **interval justeret med VPD** (ingen load cell)
- Batteri (ADR 013)

v0's stak (lager under kammeret, Ø170, 266mm høj) kan ikke være i denne
pyntepotte: ~18,5cm indvendig højde minus 11cm potte giver kun ~7cm under
potten til både lager og elektronik.

## Decision

```
   ┌ ring-låg ─┐   ┌─ dyrkningspotte ─┐   ┌ ring-låg ┐
   │  LAGER-   │   │     (bark)       │   │  RING    │
   │  RING     │ ~~│~~ skål-kant ~~~~ │~~ │          │  ← soak-loft
   │ ~~~~~~~~  │  S K Å L (konisk)    │   │ ~~~~~~~~ │
   ╞═══════════╧══════════════════════╧═══╧══════════╡  ← tank-gulv (4mm massivt)
   │  BAY: 2× 18650, pumpe, XIAO, H-bro, boost       │
   └──╲                                           ╱──┘  ← 45° skulder (fri af afsatsen)
       │   FOD Ø152 i pyntepottens udhulede bund  │
       └──────────────────────────────────────────┘
```

- **Skål** (konisk, følger pottens taper med 4mm spalte) i midten; **lager-ring**
  rundt om; **bay** til elektronik + batteri i bunden. Tårnet er Ø180, og
  pottens top sidder ~25mm under pyntepottens kant.
- **Fod (2026-10-26):** bay'ens nederste 30mm er Ø152 og står i den udhulede
  bund; en 45°-skulder går fri af afsatsen. Stod tårnet på afsatsen, ville
  pottens top stikke 3mm op over kanten. Foden centrerer også tårnet.
- **Layout i foden:** pumpen i midten, en 18650 på hver side, Qi-spolen
  off-center mod +y (≥13mm til metal). Med spolen i midten ville pumpen
  række til r≈100mm — foden har 73,5 indvendigt. Derfor har ladebasen en
  nøgle, der låser tårnets rotation.
- **Selvnivellerende soak:** skålens kant (68mm over pottens bund ≈ 62% af
  potten) ligger lavere end ringens ydervæg. Pumpen fylder skålen fra ringen;
  overskud løber over kanten tilbage i ringen. Firmwaren skal bare køre
  pumpen længe nok — soak-dybden er sat af geometrien og kan ikke blive
  dybere, heller ikke ved en firmware-fejl.
- **Ringens max-niveau** (overløb udad + "fuld"-float) ligger 6mm under
  skålens kant → lageret kan aldrig løbe tilbage i skålen.
- **Påfyldning:** gennem hullet i ring-låget (planten bliver stående), eller
  løft planten og hæld i skålen — det løber over i ringen.
- **Tør skakt i ringen** (som v0): fra bay'en op til over ringens max.
  Slange A går fra skaktens top under låget, over skålens kant og ned i
  slange-kanalen til sumpen; slange B går ned i ringen. Ingen huller under
  vandlinjen mod elektronikken.
- **Pumpe:** Kamoer NKP-DC-S10B — forhandlerens specifikation (2026-10-26):
  børstet DC-motor (vendbar ved ompoling), 12V 0,3A (3,6W), ≥70 ml/min,
  67,5×54,5×41mm, ~100g. Ingen slangestuds: pumpeslangen er silikone
  ID 3 × OD 5mm og forlænges med 3mm-slangesamlere. KPHM200 fra v0 er
  droppet (ukendte mål, 10W). Med ~376 ml soak-volumen tager fyld og dræn
  ~5,4 min hver vej → rødderne er våde ~11 min + hold-tid.

### Sensorer — alle uden huller

| Sensor | Placering | Formål |
|---|---|---|
| XKC-Y25 berøringsfri (NPN) | Limet op under skålens sump, inde i bay'en; måler gennem tank-gulvet | **Skål tom** efter dræn — den sikkerhedskritiske sensor |
| Mini-float | Beslag på ringens ydervæg, lavt | Lager lavt → HomeKit-varsel |
| Mini-float | Beslag på ringens ydervæg, højt | Lager fuldt → refill-bip (ADR 008) |
| AHT20 | Bay | VPD → soak-interval + rumklima i HomeKit |

Ingen sensor i barken, ingen load cell, ingen Grove-sensor (den graduerede
måling er unødvendig, når skålens kant styrer dybden).

### Trigger

Soak hver `interval_days` (default 7 —
[AOS](https://secure.aos.org/media/Content-Images/PDFs/Phalaenopsis_novice.pdf):
én vanding om ugen er typisk nok i bark), skaleret med VPD: kortere i tør/varm
luft, længere i kølig/fugtig. Intervallet kan ændres i HomeKit.

## Consequences

### Positive
- Passer i den valgte pyntepotte (Ø180 tårn, potte 2cm under kanten)
- Ingen omplantning — standard dyrkningspotte, bark bliver hvor den er
- Soak-dybden er mekanisk; firmware-fejl kan ikke drukne rødderne dybere
- Færre dele end v0: ingen klar PETG, ingen load cell, ingen Grove, ingen
  specialkrukke
- Ét opakt filament, ~600g PETG (massiv volumen)
- Påfyldning uden at løfte planten

### Negative
- Soak-dybden ændres kun ved at ændre `soak_depth` og printe tanken om
- Ring-overløb drypper ned i pyntepotten (kun ved overfyldning — "fuld"-
  floaten bipper først). Bay'en står i bunden, så porte i bay'en skal sidde
  over en evt. pyt
- Pyntepottens mål er fra produktsiden — skal måles før print
- Dyrkningspottens mål (top Ø120, bund Ø90, højde 110) er antaget — skal
  måles (`pot_*` i params.scad)

### Alternativer overvejet
- **Lager under skålen (v0-stak):** for højt til pyntepotten.
- **Lager-ring med skål-overløb ved soak-niveau (weir):** begrænser ringen
  til under soak-niveau → kun ~540 ml lager, mindre end én soak + reserve.
  Skål-kanten som loft giver plads til ~900 ml.
- **Load cell som trigger:** valgt fra af brugeren (højde, kalibrering, og
  målingen nulstilles hver gang potten løftes).

## Implementation notes

- CAD: `pot-orchid/cad/source/` — `params.scad`, `tank.scad`, `lid.scad`,
  `bay.scad`, `charging_base.scad`, `assembly.scad` (views iso | section |
  soaking | top | exploded | base | charging)
- Beregnet: soak ~376 ml, lager ~880 ml efter USB-C-skakten (ADR 013)
  (reserve ~500 ml ≈ 3-5 uger), fyld/dræn ~5,4 min, højde til låg 133mm,
  pottens top 163mm over fodens bund = 25mm under pyntepottens kant
- Verificeret (2026-10-26): alle dele manifold; tårnet kolliderer ikke med
  den målte pyntepotte (inkl. afsatsen); pumpe, celler, Qi-spole og XKC
  går fri af hinanden og af bay'en; tårnet passer kun i ladebasen i én
  rotation
- Firmware (TODO): `soak_cycle.cpp` — FILL (forlæns i fast tid + margin) →
  SOAK (`soak_hold_s`, default 300s) → DRAIN (baglæns til "skål tom" +
  efterløb) → VERIFY (alarm hvis skålen ikke er tom inden timeout)
