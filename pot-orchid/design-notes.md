# Pot-Orchid Design Notes

**Status:** Design v1 (2026-10-21). Konceptet er besluttet i
[ADR 012](../docs/decisions/012-orchid-v1-nursery-pot-ring-tank.md) og
[ADR 013](../docs/decisions/013-battery-1s2p.md) (batteri); dette dokument
holder de åbne punkter.

> **Historik:** v0 ([ADR 011](../docs/decisions/011-orchid-flood-and-drain.md))
> var en 266mm høj stak med klar cup, soak-kammer over lager og påkrævet
> load cell — for høj til en pyntepotte. Før det (maj/juni) en soak-tray med
> magnetventil og piezo-pumpe. Se git-historikken.

---

## Beslutninger (2026-10-21)

| Spørgsmål | Valg |
|---|---|
| Potte | Planten bliver i sin 12cm dyrkningspotte |
| Placering | I pyntepotte (indv. Ø210, maks. potte Ø190) → opak PETG |
| Soak-dybde | Mekanisk: skålens kant (68mm over pottens bund) |
| Lager | Ring rundt om skålen (~880 ml) |
| Pumpe | Kamoer NKP-DC-S10B, vendbar via H-bro (~5 min hver vej) |
| Trigger | Interval (7 dage) justeret med VPD |
| Sensorer | XKC berøringsfri under skålen, 2 mini-floats i ringen, AHT20 |
| Strøm | 1S2P 18650 (ADR 013) |
| Ladning | USB-C i toppen (skakt ved 60°) + Qi midt i bunden |
| Lys til rødderne / grow-light | Nej — vokselys kræver konstant strøm (v2 med kabel, hvis ønsket) |

## Kildegrundlag

- Interval: én vanding om ugen er typisk nok i bark
  ([AOS novice](https://secure.aos.org/media/Content-Images/PDFs/Phalaenopsis_novice.pdf)).
- Soak-tid: kilderne spænder fra max 5 min til ~20 min → `soak_hold_s` er en
  profil-parameter (default 300s). Rødderne er også våde under fyld og dræn
  (~5 min hver vej), så samlet ~15 min.
- Fuld drænage er afgørende; nedbrudt bark holder for meget vand →
  rodråd ([AOS](https://secure.aos.org/media/Content-Images/PDFs/GrowingtheBestPhalaenopsisPart_2.pdf)).
  Skift bark ca. hvert 2. år.
- Prior art: [MakerWorld automatic orchid watering](https://makerworld.com/en/models/380211-15cm-automatic-orchid-watering-system)
  (akvariepumpe + drænhuller + niveausensor, 2 min soak).

---

## Åbne punkter (næste iterationer)

### Mål før print
- [ ] **Dyrkningspotten:** top-Ø, bund-Ø, højde (`pot_*` i params.scad —
      nu antaget 120/90/110). Skålen følger pottens taper med 4mm spalte.
- [ ] **Pyntepotten:** indvendig højde og bundens bue (nu anslået 185mm og
      r15). Bay'ens 45°-fas skal gå fri af buen.

### Mekanik
- [ ] **Pumpe-mount i bay'en:** kræver NKP'ens faktiske mål (forhandler:
      ~67×55×41mm). `bay_h = 47` er sat efter den.
- [x] **Ladning (ADR 013, besluttet 2026-10-21):** USB-C-hun-ende i toppen
      af en tør skakt ved 60° (flugter med ring-låget) + Qi-spole i en lomme
      midt i bay-gulvet. Pogo fravalgt (blottede kontakter i en våd pyntepotte).
- [x] **Ladebase** (`charging_base.scad`, 2026-10-21): Ø189 × 15mm, konisk
      sæde til bay'ens 45°-fas (±0,5mm), lomme til Apple MagSafe 25W (A2580),
      laderen stikker 0,1mm op så tårnet hviler på den. Kabel-kanal radialt
      ud, åben nedad under kanten. ~265g massiv (~100g ved 15% infill, skøn).
- [ ] **MagSafe-mål:** Ø55,5 × 4,45mm er fra en teardown — mål din egen og
      kablets aflastning (`magsafe_*` i params.scad) før print.
- [ ] **Test Qi-modtager på MagSafe:** MagSafe lader Qi-enheder (uden
      magnetisk hold — basen centrerer i stedet). Vi skal kun bruge ~3W.
- [ ] **USB-C-forlængerens hun-ende:** mål overmolden (`usbc_body_*`) — slidsen
      i skaktens top er sat til 12,5×6,5mm + tolerance. Limes nedefra.
- [ ] **Stænk-hætte** på skaktens top: åbning ned til elektronikken
      (under ring-låget, men påfyldning sker 110° derfra).
- [ ] **Sump-si:** net over slange A's ende, så bark-smuld ikke når pumpen.
- [ ] **Bark der flyder:** frisk bark kan løfte sig ved fyld nedefra.
      Dyrkningspotten holder barken; overvej et let net i toppen hvis det sker.
- [ ] **Overløb fra ringen** drypper ned i pyntepotten (kun ved over-
      fyldning). Porte i bay'en skal sidde over en evt. pyt.
- [ ] **XKC-sensoren:** test at den kan se vand gennem 4mm PETG + 1,5mm
      sump (datablad: op til ~20mm ikke-metal). Limes eller klipses op.

### Elektronik / firmware
- [ ] H-bro DRV8871: IN1 = D10, IN2 = D1. Batteri-ADC på D0, boost-switch D8
      (ADR 013). Qi-modtager → 1N5819 → TP4056 IN+.
- [ ] `soak_cycle.cpp`: IDLE → FILL (fast tid + margin; overskud løber
      tilbage) → SOAK → DRAIN (til "skål tom" + efterløb) → VERIFY.
      Skålen skal være tom inden timeout, ellers alarm (buzzer + HomeKit) —
      rødder i vand er den farligste fejl.
- [ ] Interval-trigger med VPD-skalering i `profiles.cpp` (orkide-profil:
      `interval_days`, `soak_hold_s`).
- [ ] Refill-bip: "fuld"-floaten (ADR 008-princip, men binær: ét bip når
      ringen er fuld).
- [ ] Matter: batteriniveau, "lager lavt", sidste soak-tidspunkt, manuel soak.

### Verifikation (udført 2026-10-21)
- [x] Alle dele manifold
- [x] Kollisioner: potte/tank, potte/låg, låg/tank, tank/bay — ingen
- [x] Intet uden for Ø190
- [ ] Mål faktisk soak-volumen med rigtig bark (beregningen antager 55%
      porøsitet)

---

## Lessons learned fra pot/

*Endnu intet — pot/ er ikke bygget.* Relevant at måle i pot/ først:
- MCU-strøm som Matter-ICD (afgør batteritiden for begge versioner)
- Tæthed på PETG-print (tank-gulvet er barrieren mod elektronikken)
