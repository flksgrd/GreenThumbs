# ADR 004 — Vægt-baseret detektion til orkider (optional hardware)

**Status:** Accepted
**Dato:** 2026-05-27
**Opdateret:** 2026-05-27 — load cell sizing + optional hardware-strategi

## Context

Brugeren ønsker en plantekrukke der kan håndtere flere plantetyper med vidt forskellige vandbehov:

- **Monstera, Pothos, Peace Lily** (tropiske, jord-baseret): regelmæssig vanding, kapacitiv soil moisture sensor fungerer fint. Disse planter kan veje 3-10+ kg når voksne.
- **Crassula Uvata, Aloe Vera** (succulenter): meget lidt vand, lange tørre perioder. Soil moisture sensor virker i kaktus-jord. Typisk 0.5-2 kg.
- **Orkide (Phalaenopsis)**: bark-medium, ikke jord. Bark-medium har **ekstrem heterogen struktur** — kapacitiv sensor giver upålidelige værdier afhængigt af kontaktflade. Orkider vandes typisk ved **nedsænkning (soaking)** i 10-15 min, ikke kontinuerlig drip. Typisk 0.3-1 kg.

Et naïvt design med kun soil moisture sensor + drip pump dækker dårligt orkider. Men *vægt-detektion er kun nødvendig for orkider* — alle jord-baserede planter klarer sig med moisture sensor alene.

## Decision

### Vægt-detektion: kun for orkider, ikke for jord-planter

Vi tilføjer **HX711 ADC + bar load cell 5kg** som **OPTIONAL hardware**. Profilerne styrer hvilke krukker der har brug for det:

- **DETECT_MOISTURE** (Monstera, Pothos, Peace Lily, succulenter): kapacitiv soil sensor er primær og eneste signal. **Ingen load cell nødvendig.** Krukken står direkte på bord eller på rubber feet under electronics base.
- **DETECT_WEIGHT** (Orkide): HX711 + load cell er primær signal. **Load cell er påkrævet.** Krukken hviler på load_cell_mount platform.
- **DETECT_HYBRID** (optional for succulent power-users): begge signaler — moisture primær, weight som sanity check ("hvis jord er dry OG vægt er faldet, så vand"). Load cell krævet hvis valgt.

### Load cell kapacitet: 5kg (ikke 1kg)

1kg løste teknisk orkide-cases (orkide vejer ~1 kg max), men 5kg giver væsentlig safety margin og koster det samme:

- Orkide max ~1 kg
- Succulent (med jord + krukke) ~1-3 kg
- 5kg = 2-5× safety margin → ingen risiko for over-load skade

Bemærk: HX711 24-bit ADC giver ~0.3 mg/LSB ved 5kg fuldskala, hvilket er rigeligt resolution til at detektere vand-tab på 5-50g.

### Hardware-konfiguration per profil

| Plante | Profile | Soil sensor | HX711 + load cell | Cup-størrelse |
|---|---|---|---|---|
| Monstera | `monstera` | ✓ | ✗ (overflødig) | M eller L |
| Pothos | `pothos` | ✓ | ✗ | S, M eller L |
| Peace Lily | `peace_lily` | ✓ | ✗ | M eller L |
| Succulent (Crassula, Aloe) | `succulent` | ✓ | ✗ default, ✓ optional | S eller M |
| Orkide | `orchid_phalaenopsis` | (ignoreres) | ✓ påkrævet | S |
| Custom | `custom` | bruger-config | bruger-config | enhver |

## Consequences

### Positive

- **Lavere build-cost for store planter:** Monstera/Peace Lily-brugere sparer ~65 DKK (HX711 + load cell) og forenkler samling (ingen load_cell_mount print).
- **Mere realistisk vægt-sizing:** 5kg cell håndterer alle relevante use cases uden overload.
- **Modulær arkitektur:** firmware detekterer om HX711 er tilstede ved boot. Hvis ikke → `weight_available = false` flag sættes; profiler der kræver vægt giver advarsel i HomeKit.
- **Skalérbar:** Bruger kan tilføje load cell senere hvis de skifter fra Monstera til orkide.

### Negative

- **Firmware kompleksitet:** to "modes" (with/without weight). HX711-detektion ved boot kræver runtime probe (læs få gange, tjek om værdier ændres).
- **Profilvalg kan fejle:** bruger vælger orkide-profil men har ikke load cell → HomeKit skal vise fejl. Ekstra UX-arbejde.
- **Dokumentation:** brugere skal læse hvilke profiler kræver hvilken hardware.

### Alternativer overvejet

- **Større load cell (10kg) for at dække alle planter:** forkastet — Monstera 5-10kg overloader stadig 10kg load cell over tid; resolution forværres ved at gå større; og store planter behøver ikke vægt-signal pga. moisture sensor virker fint i jord.
- **To krukke-varianter (med/uden load cell):** forkastet til fordel for én modulær design hvor load_cell_mount er optional add-on.
- **Drop orkide-support helt:** forkastet — brugeren ønskede bred plante-kompatibilitet, og orkide-kasen er løsbar med 5kg cell.

## Implementation notes

### Firmware

- HX711 powered ned via SCK held high når ikke i brug (sparer strøm i SED mode).
- Ved boot: prober HX711 ved at læse 3 gange. Hvis værdier identiske eller alle 0x000000/0xFFFFFF → `weight_available = false`.
- Sample-rate: 1 reading per 10 min (vandtab er langsom).
- Moving average over 5 samples for at filtrere vibrations-støj.
- Tare via HomeKit-knap når plante er nyligt vandet → gemmes i NVS som profil-baseline.

### Profile-validering

```c
bool profile_validate(const plant_profile_t *p, bool weight_available) {
    if ((p->mode == DETECT_WEIGHT || p->mode == DETECT_HYBRID) && !weight_available) {
        return false;  // bruger valgte profil der kræver vægt, men hardware mangler
    }
    return true;
}
```

Hvis validering fejler: HomeKit Mode Select cluster reporterer fejl, status-LED bliver gul, og pumpe disables indtil bruger fixer (enten ændrer profil eller installerer load cell).

### Hardware-build

- For Monstera/Peace Lily/store planter: spring `load_cell_mount.scad` over. Tilføj 3-4× stick-on rubber feet (~Ø15mm) til bunden af `electronics_base_lid`.
- For orkide/succulent: print `load_cell_mount.scad` og brug 5kg TAL220 (eller equivalent) med M4-bolte + 2mm spacer-skiver.

### Kalibrering

Samme procedure for 5kg som for 1kg — se [calibration.md](../calibration.md) sektion 5. Brug 1kg standard-vægt (typisk ladestik) som kalibreringsreference.
