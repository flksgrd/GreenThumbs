# Planteprofiler

Hver profil definerer vandstrategi for en bestemt plantetype. Profilerne er kompilerede ind som factory-defaults i firmware (`profiles.h`) og kan tweakes per-krukke via HomeKit Mode Select cluster.

## Detection modes

```c
typedef enum {
    DETECT_MOISTURE,  // soil sensor → primær signal
    DETECT_WEIGHT,    // HX711 load cell → primær signal
    DETECT_HYBRID     // moisture + weight som sanity check
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

    // Pump-styring
    uint16_t dose_ml;            // ml per cyklus
    uint16_t cooldown_min;       // min minutter mellem doseringer
    uint16_t daily_ml_cap;       // max ml per døgn (safety)

    // Special: orkide soak-cyklus
    uint16_t soak_seconds;       // pump i X sek per soak-burst
    uint8_t soak_repeats;        // antal bursts per cyklus
    uint16_t soak_pause_seconds; // pause mellem bursts
} plant_profile_t;
```

## Predefinerede profiler

### `monstera`

Tropisk, jord-baseret. Foretrækker fugtig men ikke våd jord.

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_MOISTURE` |
| `target_min_pct` | 35% |
| `target_max_pct` | 55% |
| `dose_ml` | 50 |
| `cooldown_min` | 360 (6h) |
| `daily_ml_cap` | 100 |

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

### `succulent`

Crassula, Aloe Vera, Echeveria. Meget lidt vand. Hybrid-mode for ekstra safety.

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_HYBRID` |
| `target_min_pct` | 10% |
| `target_max_pct` | 20% |
| `weight_dry_delta_g` | -50g (relativ til baseline) |
| `dose_ml` | 15 |
| `cooldown_min` | 4320 (72h = 3 dage) |
| `daily_ml_cap` | 15 |

### `orchid_phalaenopsis`

Bark-medium, soaking-vanding. Vægt er eneste pålidelige signal.

| Parameter | Værdi |
|---|---|
| `mode` | `DETECT_WEIGHT` |
| `weight_dry_delta_g` | -80g |
| `soak_seconds` | 10 |
| `soak_repeats` | 3 |
| `soak_pause_seconds` | 30 |
| `cooldown_min` | 10080 (7 dage) |
| `daily_ml_cap` | 100 |

Soak-flow: når vægt-fald > 80g triggers, pump i 10s → pause 30s → pump i 10s → pause 30s → pump i 10s → cooldown 7 dage.

### `custom`

Alle felter brugerredigerbare via HomeKit. Default sættes til konservative værdier (lavt dose, lang cooldown).

| Parameter | Default |
|---|---|
| `mode` | `DETECT_MOISTURE` |
| `target_min_pct` | 25% |
| `target_max_pct` | 45% |
| `dose_ml` | 25 |
| `cooldown_min` | 720 |
| `daily_ml_cap` | 50 |

## Tilføj din egen plante

1. Mål en standard-vanding for planten manuelt (vej hvor meget vand du normalt giver).
2. Sæt `dose_ml` til ~1/3 af det (auto-vand giver mindre, oftere).
3. Brug `peace_lily`/`monstera` som startpunkt for tropiske, `succulent` for kaktus-familien.
4. Observer i HomeKit-app i 1-2 uger; juster `target_min_pct` op hvis planten ser tør ud, eller `cooldown_min` op hvis jorden er for våd.

## Kalibreringsnoter

- **Soil sensor `adc_dry` / `adc_wet`**: kalibreres per sensor-eksemplar (ikke per plante). Se [calibration.md](calibration.md).
- **Weight baseline**: sættes per krukke + plante via HomeKit "Tare"-knap når planten er nyligt vandet.
- Profiler er **udgangspunkter, ikke fakta**. Observer din specifikke plante og juster.
