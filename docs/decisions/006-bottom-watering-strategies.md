# ADR 006 — Bottom-watering strategier: wick i v1, soak-tray i pot-orchid (v2)

**Status:** Accepted
**Dato:** 2026-05-27

## Context

Nogle planter har naturlig præference for at blive vandet nedefra:

- **Stærk præference** (top-vanding skader): African Violet, Gloxinia, Begonia Rex, Cyclamen, Streptocarpus — fuzzy/tykke blade rådner ved vand-kontakt.
- **Foretrækker bottom-watering**: Orkide (bark-medium suger bedre ved nedsænkning), succulenter med tæt rosette (Echeveria, Sempervivum, Haworthia, kaktus), Snake plant, Pilea peperomioides, Air plants.
- **Top-vanding fungerer fint**: Monstera, Pothos, Philodendron, Peace Lily, Spider plant, Ficus, ZZ plant, Calathea.

Vores nuværende v1-design (top-drip via drip-ring) er ideelt for "top-vanding fungerer fint"-kategorien, men suboptimalt for resten. Specifikt:

- `succulent`-profil top-drypper på 15ml/3 dage — Aloe tolererer det, men Echeveria/Sempervivum kan rådne i kronen
- `orchid_phalaenopsis`-profil bruger 3×10s drip-bursts som approximation af soaking — det er ikke ægte soaking (nedsænkning i 10-15 min)

## Decision

Vi tilføjer to bottom-watering strategier i to faser:

### v1 (denne iteration): Wick-metoden

**Cotton/nylon-snor passerer gennem center-drænhullet i plant_cup, hængende fra jord ned i reservoir-vandet.** Capillær virkning trækker vand op til jorden 24/7 — passivt, ingen pumpe-aktion nødvendig.

- Wick = 4mm flettet bomulds- eller nylon-snor, 10-15cm lang
- 5-7cm i jorden (helt op til soil-overfladen), 5-7cm i reservoir-vandet
- Tilbehør i BOM, ingen CAD-ændringer — wick går gennem eksisterende 4mm center drænhul

**Pumpen er stadig aktiv** — den fylder soil-side hurtigt ved akut tørke (kompenserer for langsom wick-tilførsel), og kan også droppe drip-vanding helt for planter der KUN skal have bottom-watering (sæt `dose_ml = 0` i custom profil).

### v2: Dedikeret pot-orchid med soak-tray

For orkider (og potentielt store succulenter) laves en **separat krukke-variant** i `pot-orchid/` mappen med:

- Ekstra tray omkring plant cup der kan oversvømmes via pumpen
- 10-15 min soak-cyklus → derefter tømning via solenoid-ventil eller passiv overflow
- Mimicker manuel orkide-soaking præcist

Bygges IKKE i v1. Planlægges parallelt i `pot-orchid/` mens v1 valideres.

## Consequences

### Positive

- **Bredere plantestøtte i v1**: African Violet, Calathea, Peace Lily og fugt-elskere kan nu håndteres godt med wick.
- **Lavt cost/kompleksitet**: wick koster ~20 DKK for et 2m batch, ingen hardware/firmware ændring.
- **Bagudkompatibel**: brugere kan vælge at IKKE bruge wick — designet fungerer som før.
- **Klart upgrade-path**: pot-orchid er separat track, ikke kompromis i v1-design.

### Negative

- **Wick = konstant tilstedeværende fugt**: succulenter (der vil have tørre perioder) skal IKKE bruge wick. Brugeren skal vide hvilke planter passer.
- **Wick-rengøring**: efter måneder/år samler wick aflejringer og bør skiftes (~årligt).
- **Soil moisture sensor reading med wick**: jorden er typisk fugtigere når wick er installeret. Profilernes `target_min_pct` skal eventuelt justeres op (~10% point).

### Alternativer overvejet

- **Wick som default i alle planter**: forkastet — succulenter/orkide vil ikke have konstant fugt; wick er opt-in.
- **Soak-tray i v1**: forkastet — kræver solenoid + ekstra tray + drain-logik. Bevarer v1-scope simpelt; flyttes til pot-orchid v2.
- **Sub-irrigation (cup nedsænket i reservoir)**: forkastet — kræver redesign af cup/reservoir-relations. Wick giver samme effekt med mindre ændring.

## Implementation notes

### Wick installation (v1)

1. Vælg ~15cm flettet cotton- eller nylon-snor (4mm tykkelse).
2. Inden plant cup fyldes med jord: træd wick gennem center-drænhullet. 6-8cm går op i jord-zonen, 6-8cm hænger ned.
3. Læg lidt jord under wick i cup bunden så den ikke flytter sig.
4. Fyld resten af jorden om wick'en.
5. Når cup placeres i reservoir, skal wick-enden hænge ned i vandet (ikke kileknækket).

### Profile-tilpasning ved wick-brug

For planter med wick:

- Hæv `target_min_pct` med +5 til +10 (jorden er konstant fugtigere)
- Hæv `cooldown_min` betydeligt (pumpen behøver kun supplere ved akut tørke)
- For ren bottom-watering: sæt `dose_ml = 0` (kun wick, ingen pump-drip)

Dokumenteres i [plant-profiles.md](../plant-profiles.md) per relevant profil.

### Pot-orchid (v2) planlægning

Se [../../pot-orchid/](../../pot-orchid/) for løbende design-noter. Bygges først efter v1 er valideret.
