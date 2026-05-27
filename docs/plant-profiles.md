# Planteprofiler

Hver profil definerer vandstrategi for en bestemt plantetype. Profilerne er kompilerede ind som factory-defaults i firmware (`profiles.h`) og kan tweakes per-krukke via HomeKit Mode Select cluster.

## Hardware-konfiguration

Krukken kan bygges i to varianter afhængigt af hvilke planter du vil have:

| Variant | Hardware | Profiler der virker | Typisk brug |
|---|---|---|---|
| **Standard** (uden load cell) | Soil moisture + water level + float | `monstera`, `pothos`, `peace_lily`, `succulent` | Alle jord-baserede planter |
| **Med vægt** (HX711 + 5kg load cell + load_cell_mount print) | + HX711 | Alle ovenstående + `orchid_phalaenopsis` | Tilføjer orkide-support |

→ Se [ADR 004](decisions/004-weight-based-orchid.md) for begrundelse.

## Detection modes

```c
typedef enum {
    DETECT_MOISTURE = 0,  // soil sensor → primær signal (alle jord-planter)
    DETECT_WEIGHT,        // HX711 load cell → primær signal (orkide kun)
    DETECT_HYBRID,        // moisture + weight som sanity check (advanced, custom)
} detection_mode_t;
```

## Profil-struct

```c
typedef struct {
    char name[16];
    detection_mode_t mode;

    // Soil moisture (DETECT_MOISTURE, DETECT_HYBRID)
    uint16_t adc_dry;            // sensor i luft
    uint16_t adc_wet;            // sensor i vand
    uint8_t target_min_pct;      // pump trigger threshold
    uint8_t target_max_pct;      // pump stop threshold

    // Weight (DETECT_WEIGHT, DETECT_HYBRID)
    int32_t weight_baseline_g;   // tara-vægt sat ved init
    int32_t weight_dry_delta_g;  // gram tabt før vanding (negativt tal)

    // Pump-styring (alle modes)
    uint16_t dose_ml;            // ml per cyklus
    uint16_t cooldown_min;       // min minutter mellem doseringer
    uint16_t daily_ml_cap;       // max ml per døgn (safety)

    // Orkide soak-cyklus (kun DETECT_WEIGHT)
    uint16_t soak_seconds;       // pump i X sek per soak-burst
    uint8_t soak_repeats;        // antal bursts per cyklus
    uint16_t soak_pause_seconds; // pause mellem bursts
} plant_profile_t;
```

## Predefinerede profiler

### `monstera`

Tropisk, jord-baseret. Foretrækker fugtig men ikke våd jord. Vejer typisk 3-10+ kg som voksen — **kører ikke på load cell**, bruger kun moisture sensor.

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_MOISTURE` |
| `target_min_pct` | 35% |
| `target_max_pct` | 55% |
| `dose_ml` | 50 |
| `cooldown_min` | 360 (6h) |
| `daily_ml_cap` | 100 |
| Hardware krav | Soil moisture sensor |

### `pothos`

Tropisk, jord-baseret. Mere tørke-tolerant end Monstera.

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_MOISTURE` |
| `target_min_pct` | 30% |
| `target_max_pct` | 50% |
| `dose_ml` | 30 |
| `cooldown_min` | 720 (12h) |
| `daily_ml_cap` | 60 |
| Hardware krav | Soil moisture sensor |

### `peace_lily`

Tropisk, jord-baseret. Sensitiv overfor under-vanding (hænger ved tørke).

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_MOISTURE` |
| `target_min_pct` | 40% |
| `target_max_pct` | 60% |
| `dose_ml` | 40 |
| `cooldown_min` | 480 (8h) |
| `daily_ml_cap` | 100 |
| Hardware krav | Soil moisture sensor |

### `succulent`

Crassula, Aloe Vera, Echeveria. Meget lidt vand. Moisture sensor virker fint i kaktus-jord.

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_MOISTURE` |
| `target_min_pct` | 10% |
| `target_max_pct` | 20% |
| `dose_ml` | 15 |
| `cooldown_min` | 4320 (72h = 3 dage) |
| `daily_ml_cap` | 15 |
| Hardware krav | Soil moisture sensor |

> **Advanced:** Hvis du har load cell installeret, kan du bruge `custom` profil med `mode = DETECT_HYBRID` og `weight_dry_delta_g = -50` for ekstra safety (vand kun hvis BÅDE jord er tør OG vægt er faldet).

### `orchid_phalaenopsis`

Bark-medium, soaking-vanding. **Kræver load cell** — soil moisture sensor er upålidelig i bark.

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_WEIGHT` |
| `weight_dry_delta_g` | -80g (relativ til baseline) |
| `soak_seconds` | 10 |
| `soak_repeats` | 3 |
| `soak_pause_seconds` | 30 |
| `cooldown_min` | 10080 (7 dage) |
| `daily_ml_cap` | 100 |
| Hardware krav | **HX711 + 5kg load cell + load_cell_mount platform** |

Soak-flow: når vægt-fald > 80g triggers, pump i 10s → pause 30s → pump i 10s → pause 30s → pump i 10s → cooldown 7 dage.

> **Hvis hardware mangler:** firmware detekterer at HX711 ikke svarer → status-LED gul → HomeKit Mode Select rapporterer fejl → pumpe disables. Skift til en `DETECT_MOISTURE`-profil eller installer load cell.

### `custom`

Alle felter brugerredigerbare via HomeKit. Default sættes til konservative værdier.

| Parameter | Default |
|---|---|
| `mode` | `DETECT_MOISTURE` |
| `target_min_pct` | 25% |
| `target_max_pct` | 45% |
| `dose_ml` | 25 |
| `cooldown_min` | 720 |
| `daily_ml_cap` | 50 |
| Hardware krav | Afhænger af valgt mode |

## Vælg din plante

Find din plantes generelle kategori og brug den nærmeste profil:

| Din plante er… | Brug profil |
|---|---|
| Stor jord-baseret tropisk (Monstera, Strelitzia, Ficus) | `monstera` |
| Mellem jord-baseret tropisk (Pothos, Philodendron, Calathea) | `pothos` |
| Sensitiv tropisk der hænger ved tørke (Peace Lily, Begonia) | `peace_lily` |
| Succulent / kaktus | `succulent` |
| Orkide i bark-medium | `orchid_phalaenopsis` |
| Andet / kender ikke krav | `custom` (start konservativt, juster) |

## Tilføj din egen plante

1. Mål en standard-vanding for planten manuelt (vej hvor meget vand du normalt giver).
2. Sæt `dose_ml` til ~1/3 af det (auto-vand giver mindre, oftere).
3. Brug `peace_lily`/`monstera` som startpunkt for tropiske, `succulent` for kaktus-familien.
4. Observer i HomeKit-app i 1-2 uger; juster `target_min_pct` op hvis planten ser tør ud, eller `cooldown_min` op hvis jorden er for våd.

## Kalibreringsnoter

- **Soil sensor `adc_dry` / `adc_wet`**: kalibreres per sensor-eksemplar (ikke per plante). Se [calibration.md](calibration.md).
- **Weight baseline** (kun DETECT_WEIGHT/HYBRID): sættes per krukke + plante via HomeKit "Tare"-knap når planten er nyligt vandet.
- Profiler er **udgangspunkter, ikke fakta**. Observer din specifikke plante og juster.
