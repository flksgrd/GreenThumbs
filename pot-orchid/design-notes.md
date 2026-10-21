# Pot-Orchid Design Notes

**Status:** Design v0 (2026-10-21). Konceptet er besluttet i
[ADR 011](../docs/decisions/011-orchid-flood-and-drain.md); dette dokument
holder de åbne punkter og lessons learned.

> **Historik:** Noterne fra maj/juni beskrev en separat soak-tray med
> magnetventil eller passivt overløb og en piezo-pumpe. De blev skrevet før
> ADR 009 (zero-penetration) og ADR 010 (scalloped cup) og er erstattet af
> ADR 011. Piezo-pumpen (9 ml/min) er fravalgt: ~655 ml soak-volumen ville
> tage over en time at fylde. Se git-historikken for den oprindelige tekst.

---

## Beslutninger (2026-10-21)

| Spørgsmål | Valg |
|---|---|
| Ind/ud af soak-kammeret | Vendbar peristaltisk pumpe (forlæns fyld, baglæns dræn) |
| Pumpe | Kamoer KPHM200 ~260 ml/min (fyld/dræn ~2,5 min) |
| Potte-størrelse | 12cm Phalaenopsis → cup Ø132 × 115 |
| Cup | Klar PETG (rødder får lys, rodsundhed kan ses) |

## Kildegrundlag

- Soak-tid: kilderne spænder fra max 5 min til ~20 min → `soak_hold_s` er en
  profil-parameter (default 600s). Husk at rødderne også er våde under fyld
  og dræn (~2,5 min hver vej).
- Fuld drænage er afgørende; nedbrudt bark holder for meget vand i bunden →
  rodråd ([AOS](https://secure.aos.org/media/Content-Images/PDFs/GrowingtheBestPhalaenopsisPart_2.pdf)).
  Skift bark ca. hvert 2. år.
- Klare potter: flertallet af avlere i Taiwan/Holland (AOS).
- Prior art: [MakerWorld automatic orchid watering](https://makerworld.com/en/models/380211-15cm-automatic-orchid-watering-system)
  (akvariepumpe + drænhuller + niveausensor, 2 min soak).

---

## Åbne punkter (næste iterationer)

### Mekanik
- [ ] **Pumpe-mount** i `ebase_orchid.scad`: kræver KPHM200's faktiske mål.
      `ebase_height = 60` er en placeholder.
- [ ] **Stænk-hætte** på skaktens top: skakten er en åben vej ned til
      elektronikken. Hætte med slidser til slanger/kabler (TPU).
- [ ] **Bark der flyder:** frisk bark kan løfte sig, når der fyldes nedefra
      (forum-erfaring med LECA). Rødderne holder normalt barken; overvej et
      let net/gitter i cup-toppen hvis det sker.
- [ ] **Grove-printpladen** stikker ~6mm op over flangen ved 90° (pladen er
      133mm). OK funktionelt (kablet går ud der), men synligt.
- [ ] **Load cell-platform:** pot/'s `load_cell_mount.scad` er parametreret
      til pot/'s mål — skal have orkidens Ø170 (kopier eller generalisér via
      shared/cad-lib/).
- [ ] **Underskål:** begge overflow-huller drypper udad.
- [ ] **Klar PETG-print:** test indstillinger for gennemsigtighed (høj temp,
      lav hastighed, ingen infill-mønster i vægge). Filamentskift efter
      kammer-gulvet (opak → klar).
- [ ] **Pakning på skakt-kraven:** test at soak-niveauet holder i 20 min
      (lækage → lager er ufarlig, men sænker soak-niveauet).

### Elektronik / firmware
- [ ] H-bro DRV8871: IN1 = D10 (GPIO18), IN2 = D1 (GPIO1). D0 (soil-ADC)
      er fri i orkide-versionen.
- [ ] `soak_cycle.cpp`: IDLE → FILL → SOAK → DRAIN → VERIFY. Dræn-
      verifikation: Grove-sensoren skal vise tomt kammer inden timeout,
      ellers alarm (buzzer + HomeKit) — rødder i vand er den farligste fejl.
- [ ] Profil-struct: `soak_hold_s` + fyld-dybde erstatter v1's
      `soak_seconds`/`soak_repeats`/`soak_pause_seconds` til orkide.
- [ ] Refill-feedback til buzzeren fra load cell'en (lageret har ingen
      Grove-sensor). Vægtstigning under påfyldning → bip pr. 25%.
- [ ] Load cell-baseline tages efter fuld dræn (intern flytning af vand
      ændrer ikke totalvægten).

### Verifikation før print
- [ ] Kollisionstest (udført 2026-10-21): cup passer kun i 0°; skakt, Grove-
      plade og cup går fri af hinanden ✓
- [ ] Mål faktisk soak-volumen med rigtig bark (beregningen antager 55%
      porøsitet)

---

## Lessons learned fra pot/

*Endnu intet — pot/ er ikke bygget.*

Relevant at måle i pot/ først:
- Load cell-præcision på små vægttab over en uge (termisk drift)
- Grove-sensorens pålidelighed i kontinuerligt vand
- Pakning/tæthed på PETG-print
