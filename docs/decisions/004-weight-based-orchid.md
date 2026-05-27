# ADR 004 — Vægt-baseret detektion til orkider og succulenter

**Status:** Accepted
**Dato:** 2026-05-27

## Context

Brugeren ønsker en plantekrukke der kan håndtere flere plantetyper med vidt forskellige vandbehov:

- **Monstera, Pothos** (tropiske, jord-baseret): regelmæssig vanding, kapacitiv soil moisture sensor fungerer godt.
- **Crassula Uvata, Aloe Vera** (succulenter): meget lidt vand, lange tørre perioder. Soil moisture sensor virker, men aflæsningen i kaktus-jord er mindre repræsentativ.
- **Orkide (Phalaenopsis)**: bark-medium, ikke jord. Bark-medium har **ekstrem heterogen struktur** — kapacitiv sensor giver upålidelige værdier afhængigt af kontaktflade. Orkider vandes typisk ved **nedsænkning (soaking)** i 10-15 min, ikke kontinuerlig drip.

Et naïvt design med kun soil moisture sensor + drip pump dækker dårligt orkider og er suboptimalt for succulenter.

## Decision

Vi tilføjer en **HX711 ADC + bar load cell 1kg** under hele krukken. Vægt-fald (i gram fra base-line) bruges som detektion for orkider og succulenter; soil moisture bruges som primær signal for jord-baserede planter.

Profile-struct understøtter tre detection-modes:

```c
typedef enum {
    DETECT_MOISTURE,  // Monstera, Pothos — soil sensor
    DETECT_WEIGHT,    // Orkide — HX711 load cell + soak-cyklus
    DETECT_HYBRID     // Succulent — moisture primær, weight som sanity check
} detection_mode_t;
```

For orkider implementeres en **soak-cyklus**: vægt-fald > threshold → pump i 10 sek → vent 30 sek → gentag 3× → cooldown 7 dage.

## Consequences

### Positive

- **Dækker alle planter brugeren nævnte** (Monstera, Crassula, Aloe, Orkide) — ingen behov for at droppe orkide-support i v1.
- **Vægt-signal er fysisk fundamentalt**: gram er gram, uafhængigt af medie. Eliminerer kalibrering for hver medium-type.
- **Bonus-signal for jord-planter**: vægt kan bruges som sanity check ("krukken føles let → måske er reservoiret tomt selvom water-level sensor siger fuldt").
- **Lave omkostninger**: HX711 ~15 DKK + bar load cell ~50 DKK = 65 DKK ekstra per krukke.

### Negative

- **Mekanisk kompleksitet**: hele krukken skal hvile på en load cell-platform. Krukken kan ikke flyttes uden at re-tare.
- **Temperatur-drift**: HX711 har ~50 ppm/°C drift; ved store temperatur-udsving kan baseline drifte. Mitigation: brugbar tare-knap eksponeret som Matter-attribut i HomeKit.
- **Custom mekanisk design**: kræver en ekstra 3D-printet load cell mount (`load_cell_mount.scad`).
- **Læringskurve på HX711 timing**: bit-banged 2-wire interface, kræver præcis GPIO timing.

### Alternativer overvejet

- **Drop orkide helt**: forkastet — brugeren ønsker bred plante-kompatibilitet.
- **Dedikeret orkide-design uden auto-vand**: forkastet — ville duplikere alt 3D-print arbejde.
- **Capacitive sensor i bark**: forkastet — fundamentalt upålidelig pga. bark-heterogenitet.
- **Vægt-baseret som ENESTE detektion** (også for jord-planter): forkastet — vægt-fald kan komme fra fordampning OG vandtab, sværere at adskille uden ekstra fugtigheds-info. Hybrid er mere robust.

## Implementation notes

- HX711 powered ned via PD-pin når ikke i brug (sparer strøm i Sleepy End Device mode).
- Sample-rate: 1 reading per 10. minut er rigeligt (vandtab er langsom).
- Moving average over 5 samples for at filtrere vibrations-støj (fx hvis nogen rammer krukken).
- Tare-procedure: bruger trykker manuelt knap (eller via HomeKit) når plante er nyligt vandet → gemmer i NVS som baseline.
- Kalibrering: vej 100g og 500g standard-vægt → linær fit til ADC-værdi.
