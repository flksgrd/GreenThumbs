# Foreløbig BOM — Tower (v2)

**Status:** Estimat baseret på pot-erfaring + standard hydroponic-komponenter. Refineres når v1 (pot) er bygget.

## Genbrug fra pot

| Komponent | Antal | Note |
|---|---|---|
| XIAO ESP32-C6 | 1 | Samme MCU |
| MOSFET IRLB8721 + diode + resistor | 1 sæt | Samme driver |
| ZY12PDN PD-trigger | 1 | Eller dedikeret 12V adapter |
| MP1584 buck 12V→5V | 1 | Samme |
| WS2812 LED | 1 | Status |
| Tactile button | 1 | Manual control |
| Float switch | 1 | Low-water cutoff |
| Wires, JST connectors, fasteners | - | Genbrug |

## Tower-specifikke

| # | Komponent | Specifikation | Pris (DKK) | Leverandør | Notes |
|---|---|---|---|---|---|
| 1 | Submersible aquarium pumpe | Eheim CompactON 300 (12V) eller equivalent | ~250 | Akvarium-butik DK / AliExpress | 300 L/h, ultra stille |
| 2 | Net cups 2" (5cm) | Pakke 10-20 stk | ~50 | AliExpress | Standard hydroponic |
| 3 | LECA / clay pebbles | 5 L pose | ~80 | Plantorama, OBI | Substrat |
| 4 | Rockwool starter cubes | 20 stk | ~50 | Hydroponics butik | Til kimplanter |
| 5 | Silikoneslange 8mm ID | 1m, til distribution top | ~30 | AliExpress | Større end pot |
| 6 | T-stykker + L-stykker 8mm | Sæt | ~30 | VVS-butik / AliExpress | Plumbing |
| 7 | Capacitive water level strip (lang) | 10-15cm version | ~120 | DFRobot / AliExpress | Større reservoir = længere strip |
| 8 | Transparent acryl-vindue | 50x150mm, 3mm tykt | ~40 | Lokal byggemarked | Til vand-inspektion |
| 9 | DS18B20 temperatur-sensor (vandtæt) | 1-wire | ~30 | AliExpress | Vandtemperatur monitoring |
| 10 | PETG filament (transparent option) | 1kg | ~180 | 3djake.dk | Til vand-vindue del? eller separat acryl |
| 11 | Plant nutrients | General Hydroponics Flora 3-part 500ml sæt | ~250 | Hydroponic-butik | Til de første måneder |
| 12 | M5 vægmonterings-skruer + plugs | Sæt | ~50 | Byggemarked | Skal bære tower-vægt (~5-8 kg våd) |
| 13 | pH testpapir eller meter (manuel) | Strip pakke | ~30 | Hydroponic-butik | v2 starter manuel |
| 14 | EC meter (manuel, optional) | Handheld | ~150 | AliExpress | Optional v2 |

**Optional grow lights (besluttes senere):**

| # | Komponent | Specifikation | Pris (DKK) | Notes |
|---|---|---|---|---|
| L1 | LED grow strip 12V | Full-spectrum, IP65 | ~200/m | 1-2m per tower |
| L2 | LED driver / MOSFET | 12V, PWM dimming | ~50 | Samme topologi som pump driver |

**Estimeret total (uden optional grow lights, ekskl. genbrug fra pot):** ~1200-1500 DKK

## Notes

- Submersible pumpe er den væsentligste ny-investering. Eheim er high-end (ekstremt stille) men generic 12V kan også prøves først.
- Hydroponic nutrient er en løbende driftsomkostning (~50 DKK/måned ved aktiv brug af 5-7 plant slots).
- Transparent acryl-vindue → integreres i reservoir-print som rektangulær udskæring med klemmer for skift.
- Vægmontering: tower er våd ≈ 5-8 kg når full reservoir. M5-skruer i mur-plugs er minimum; gips-vægge kræver krydsfiner-bagplade først.

## Refineres efter v1

Nye items kan dukke op når v1 er bygget:

- Specifik pumpe-model (med datablade for støj-test)
- Antal net cups (afhænger af besluttet tower-størrelse)
- Grow lights ja/nej baseret på placerings-test
- pH-automatik ja/nej (afhænger af om manuel monitoring føles bøvlet)
