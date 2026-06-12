# Systemarkitektur — GreenThumbs Plantekrukke v1

## Overordnet billede

```
+-----------------------------------------------------------------+
|                    APPLE HOMEKIT (iPhone/iPad)                  |
+-----------------------------------------------------------------+
                              ↕
                  (Matter over Thread)
                              ↕
+-----------------------------------------------------------------+
|     HomePod mini / Apple TV 4K (Thread Border Router)           |
+-----------------------------------------------------------------+
                              ↕
                  (Thread mesh, 802.15.4)
                              ↕
+=================================================================+
|             SMART PLANTEKRUKKE — BASE STATION                   |
|                                                                 |
|   USB-C PD adapter (≥30W)                                       |
|        ↓                                                         |
|   ZY12PDN PD trigger (12V)                                      |
|        ├──→ MOSFET (IRLB8721) ──→ Peristaltisk pumpe 12V        |
|        └──→ MP1584 buck (12V→5V) ──→ XIAO ESP32-C6              |
|                                          │                       |
|                                          ├── ADC0: soil moisture │
|                                          ├── ADC1: water level   │
|                                          ├── GPIO ISR: float     │
|                                          ├── I2C: AHT20          │ (temp + RH)
|                                          ├── GPIO: HX711 SCK/DT  │ (optional)
|                                          ├── GPIO: status LED    │
|                                          ├── GPIO: manual btn    │
|                                          └── GPIO PWM: pump      │
+=================================================================+
```

## Fysisk stack (top → bund)

```
STACK VARIANT A (besluttet 2026-06): cup hænger NEDSÆNKET i reservoiret.

┌══════════[ FLANGE Ø202 ]══════════┐ ← universal-flange hviler på rim;
│  ↓ refill-åbning (270°)           │   refill-åbning + slange-hul i flangen
│ ┌───────────────────────┐         │
│ │  INNER PLANT CUP      │ ←ring-  │ ← skiftelig S(Ø100)/M(Ø140)/L(Ø160)
│ │   • jord              │  gap    │   hænger nedsænket i reservoiret
│ │   • soil sensor       │ (slange │
│ │   • drænhuller i bund │  + strip│ ← water level strip i ring-zonen
│ │   • wick gn. center   │  her)   │
│ └─────────┬─────────────┘         │
│   VAND-ZONE (40mm, ~1018 ml)      │ ← float switch i bund, under cup
╞═══════════════════════════════════╡
│  ELECTRONICS BASE (vandtæt)       │
│   • XIAO ESP32-C6 + AHT20 + buzzer│
│   • MOSFET + buck-converter       │
│   • Pumpe på lid (dual footprint: │
│     Kamoer KPP eller BP7 piezo)   │
│   • O-ring/EPDM gasket på top     │
├───────────────────────────────────┤
│  LOAD CELL platform (OPTIONAL)    │ ← kun for orkide / power-user
│   • HX711 ADC + bar load cell 5kg │
│   • Skip for store planter — brug │
│     rubber feet på lid i stedet   │
└───────────────────────────────────┘

Total stak-højde: S ~208mm, M ~248mm, L ~288mm (+ ~33mm med load cell).
Passer i pyntepotter Ø ≥ 21cm.
```

## Vandstrøm

```
Reservoir vand-zone (under cup)
     │
     ↓ Sugeslange ned gennem pump-port (x=85, i ring-gabet) til pumpe
     │
     ↓ Peristaltisk pumpe i electronics base (drevet via MOSFET, 12V)
     │
     ↓ Trykslange op gennem samme ring-gab → gennem flange-hullet (180°)
     │
     ↓ Ind i cup-toppens side-hul → dripper på jord-overfladen
     │
     ↓ Jord → plantens rødder
     │
     ↓ Overskud drypper gennem cup-drænhuller → tilbage i vand-zonen
       (lille intern recirkulation; acceptabelt — jordmængden i dryppet
        er minimal, og wick-planter trækker alligevel direkte fra zonen)
```

**Wick-flow (ADR 006):** for bottom-watering planter hænger en bomulds-wick
fra cup'ens center-drænhul direkte ned i vand-zonen (20-50mm afstand) —
kontinuert kapillær-vanding uden pumpe.

## Software-arkitektur

```
┌─────────────────────────────────────────────────────────┐
│                    main.cpp                             │
│   app_main() — init NVS, sensors, Matter, start tasks   │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼─────────────────────┐
        ↓                   ↓                     ↓
┌─────────────┐    ┌──────────────┐    ┌──────────────┐
│ sensor_task │    │ control_task │    │ matter_task  │
│             │    │              │    │              │
│ Sample alle │←──→│ Eval profile │←──→│ Matter event │
│ sensorer    │    │ → pump?      │    │ loop +       │
│ hver 30s    │    │              │    │ clusters     │
└─────────────┘    └──────────────┘    └──────────────┘
        ↑                   ↑                     ↑
        └───────────────────┼─────────────────────┘
                            ↓
                   ┌────────────────┐
                   │  safety_task   │
                   │ Watchdog +     │
                   │ float ISR +    │
                   │ leak detect    │
                   └────────────────┘
```

**Shared state** mellem tasks via FreeRTOS mutexes:
- `sensor_state_t` (latest soil/water/weight readings)
- `plant_profile_t` (aktiv profil fra NVS)
- `pump_state_t` (last_pump_time, cumulative_ml_today)

**Communication mellem ESP32 og HomeKit:**

| Software-koncept | Matter cluster | HomeKit-visning |
|---|---|---|
| Soil moisture % | Humidity Sensor (endpoint 1) | "Jord-fugtighed: 42%" |
| Water reservoir % | Humidity Sensor (endpoint 2) | "Vandstand: 78%" |
| Float low (binær) | Leak Detector | "Vandalarm: OK" / "Tom" |
| Manuel pump | On/Off Switch | Knap der auto-slukker efter 3 sek |
| Profile-vælger | Mode Select | Dropdown: Monstera / Pothos / Peace Lily / African Violet / Succulent / Orkide / Custom |
| Rumtemperatur (AHT20) | Temperature Sensor (endpoint 3) | "Stuetemperatur: 22.4°C" |
| Luftfugtighed (AHT20) | Humidity Sensor (endpoint 3) | "Luftfugtighed: 47%" |
| Weight (gram, hvis HX711 tilstede) | Custom cluster (v2) | "Plante-vægt: 1248g" |

**VPD-aware dose-modifikator:** Når AHT20 er tilstede, justerer firmware automatisk `dose_ml` baseret på Vapor Pressure Deficit (rum-tørhed × temperatur). Ved tørt indeklima (vinter med radiator) får planten mere vand per cyklus; ved fugtigt klima reduceres dosen. Se [ADR 007](decisions/007-env-sensor-aht20.md).

## Load cell-placering: bivirkninger

Load cell sidder i bunden af stakken — under electronics base — af tre årsager:

1. **Vandslangen krydser ingen flex-joint.** Pump-output går fra reservoir gennem electronics base op til plant cup. Hvis cellen lå mellem reservoir og cup (eller mellem electronics base og reservoir), ville den stive silikoneslange spænde over flex-jointen og påføre en uforudsigelig kraft (~50g, hvilket drukner vores 10-100g signal for orkide).
2. **HX711-wiring er kortest.** ADC-modulet sidder i electronics base. Cell-til-ADC kablet behøver kun krydse ét vandtæt grommet — direkte ned i electronics base bund.
3. **Mekanisk stabilitet.** Rigid stak ovenpå én flex-joint er stabil. Flex-joint midt i stakken giver vippe-risiko, især med tunge planter.

Dette giver to bivirkninger der skal kompenseres i firmware/build:

### Pumpe-vibrationer påvirker måling

Pumpen sidder i electronics base, direkte over load cell platformen. Vibrationer fra pumpe-drift forplanter sig ned i cellen.

**Mitigation:**
- Firmware bruger 5-sample moving average på HX711-readings.
- **Sample ALDRIG mens pumpen kører.** Tilføj `if (pump_active) skip_weight_sample;` i sensor_task.
- Vent minimum 30 sek efter pump stop før første nye weight sample (mekaniske oscillationer dør ud).

### Termisk drift fra elektronik

ESP32-C6 + MP1584 buck-converter genererer ~1-2W varme. Varmen vandrer gennem electronics base bund → ind i load_cell_mount upper plate → påvirker HX711-aflæsning (~50 ppm/°C drift = ~0.5g per grad ved 5kg fuldskala — ikke meget, men akkumuleres over et døgn med vekslende rumtemp).

**Mitigation:**
- Læg en 2-3mm rubber-pad mellem electronics_base_lid og load_cell_mount upper plate som termisk isolation.
- Re-tare via HomeKit-knap ved sæson-skifte eller tydelig drift.
- Sample baseline-vægt om natten (lavest temperatur-gradient) hvis høj præcision er kritisk.

## Sikkerheds-architecture

Multi-layer defense mod uheld:

1. **Hardware**: Float switch i reservoir-bund. Hvis vand tomt → ISR sætter `pump_disabled_hw = true`. Software kan ikke override.
2. **Firmware**: Watchdog task tjekker at sensor-data ikke er stuck. Hvis stuck > 5 min → reboot.
3. **Logic**: Cooldown mellem doseringer (min `cooldown_min` per profil). Forhindrer over-watering.
4. **Daglig cap**: Max `daily_ml_cap` per profil. Forhindrer runaway-vanding.
5. **Manuel override**: knap på krukken + HomeKit-switch til at trig en pump-cyklus (med safety-checks).
6. **Leak detection**: hvis vægt falder hurtigere end forventet → mistænkt lækage → disable pump + alert.

## Repo-navigation

- [pot/](../pot/) — alt v1 (firmware, hardware, CAD)
- [tower/](../tower/) — v2 planlægning (kun docs)
- [shared/](../shared/) — genbrugbar kode/CAD mellem v1 og v2
- [docs/decisions/](decisions/) — ADR'er der dokumenterer hvorfor
- [docs/plant-profiles.md](plant-profiles.md) — profil-bibliotek
- [docs/calibration.md](calibration.md) — kalibreringsprocedure
