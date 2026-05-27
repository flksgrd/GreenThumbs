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
|                                          ├── GPIO: HX711 SCK/DT  │
|                                          ├── GPIO: status LED    │
|                                          ├── GPIO: manual btn    │
|                                          └── GPIO PWM: pump      │
+=================================================================+
```

## Fysisk stack (top → bund)

```
┌─────────────────────────────────┐
│  Lid med refill-tragt           │  ← bruger hælder vand her
├─────────────────────────────────┤
│  INNER PLANT CUP                │  ← skiftelig S/M/L
│   • jord                        │
│   • drip-ring på top            │
│   • soil sensor (snap-fit)      │
│   • drænhuller i bund           │
├─────────────────────────────────┤
│  RESERVOIR (700ml/1500ml)       │
│   • water level strip indvendig │
│   • float switch i bund         │
│   • pumpe-output port til side  │
│   • refill-tube til side        │
├─────────────────────────────────┤
│  ELECTRONICS BASE (vandtæt)     │
│   • XIAO ESP32-C6               │
│   • MOSFET + buck-converter     │
│   • Peristaltisk pumpe          │
│   • O-ring/EPDM gasket på top   │
├─────────────────────────────────┤
│  LOAD CELL platform (OPTIONAL)  │  ← kun for orkide / power-user
│   • HX711 ADC                   │
│   • Bar load cell 5kg           │
│   • Skip helt for store planter │
│     (Monstera/Peace Lily) — sæt │
│     rubber feet på base i stedet│
└─────────────────────────────────┘
```

## Vandstrøm

```
Reservoir (vand)
     │
     ↓ Peristaltisk pumpe (drevet via MOSFET, 12V)
     │
     ↓ Silikoneslange 4mm ID (gennem vandtæt grommet i electronics base)
     │
     ↓ Op gennem Inner Plant Cup side
     │
     ↓ Drip-ring på top (små huller, fordeler jævnt)
     │
     ↓ Jord → planten rødder
     │
     ↓ (Overflow gennem drænhuller i bund af cup)
     │
     ↓ Tilbage til reservoir? Nej — drænvand opsamles i en lille bund-niche i reservoir
       og fordamper. Ikke recirkulation (vil pulle salte op fra jord).
```

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
| Profile-vælger | Mode Select | Dropdown: Monstera / Pothos / Peace Lily / Succulent / Orkide / Custom |
| Weight (gram, hvis HX711 tilstede) | Custom cluster (v2) | "Plante-vægt: 1248g" |

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
