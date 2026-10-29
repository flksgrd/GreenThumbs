# Pot-Orchid — BOM (forskel fra pot/)

**Status:** Foreløbig — design v1 (ADR 012 + ADR 013). Grundlaget er
[pot/hardware/bom.csv](../pot/hardware/bom.csv); her står kun hvad der er
anderledes. Pos-numre henviser til pot/-BOM'en.

## Samme som pot/

ESP32-H2-Zero (1), silikoneslange (3), flyback-diode (5), USB-C-lader (14),
knap (16), JST-kit (17), breadboard (18), silikone-ledning (19), M3-inserts/
-bolte (20, 21), PETG (24), SHT41 (27), buzzer (28), USB-C-forlænger (31 —
0,3m er nok), PLA til testprint (33), hele batteridelen (36-43 + 47 — TP4056 ved 580 mA, dog kun ét
switch-kredsløb — se nedenfor), Qi-modtager + lader + støvprop (44-46), MAX17048 (50).

## Ændret

| pot/-pos | pot/ | Orkide | Hvorfor |
|---|---|---|---|
| 2 | Kamoer KXF-DC (37 ml/min) | **Kamoer NKP-DC-S10B** — børstet DC, 12V 0,3A, ≥70 ml/min, 67,5×54,5×41mm (forhandler-spec 2026-10-26) | Fyld/dræn ~5,4 min. Børstet DC → vendbar via H-bro ✓ |
| 6 | 10kΩ pulldown | Samme (switch A, GPIO22) | Begge versioner har boost-switchen på GPIO22 |
| 9 | 1 float switch | **2 mini-floats** (lodret, M8-stamme) | Lager lavt + lager fuldt (refill-bip). Beslag i tank.scad: Ø8,5 hul |
| 3 | Silikoneslange 4×6mm | **3×5mm** + lige 3mm-slangesamlere | NKP har ingen studs — pumpeslangen (ID 3 × OD 5) forlænges |
| 24 | PETG 2 kg | **1 kg opak PETG** | Tank ~373g + låg ~58g + bay ~155g + ladebase ~158g ≈ 750g (massiv volumen) |
| 39-42 | 2 switches (pumpe + sensorer) | **1 switch** (boost) | Ingen sensor-skinne: SHT41 er eneste I2C-enhed (80 nA i hvile), XKC fødes fra boostens 12V |

## Udgår

| pot/-pos | Del | Hvorfor |
|---|---|---|
| 7 | Soil moisture-sensor | Upålidelig i bark; triggeren er interval + VPD |
| 8 | Grove water level | Skålens kant styrer soak-dybden mekanisk |
| 10, 11, 34 | HX711 + load cell + bolte | Valgt fra (ADR 012) — målingen nulstilles hver gang potten løftes |
| 22, 23, 23b | Pakning + glands | Tank-gulvet er massivt; alt går gennem den tørre skakt |
| 26 | Wick | Orkideen vandes ved soak |
| 29 | LECA | Bark i dyrkningspotten |
| 30 | Slange-lod | Slangerne ligger i sumpen/ringens bund via kanal |
| 32 | Skærmet kabel | Alle kabler er korte (inde i bay'en + gennem skakten) |
| 35 | Gummifødder | Bay'ens fas løfter porte over evt. pyt (TODO: bekræft) |

## Nyt

| Del | Spec | Est. pris | Note |
|---|---|---|---|
| H-bro | DRV8871-breakout (Adafruit 3190 el. lign., 6,5-45V, 3,6A) | ~60 DKK | Pumpen skal kunne køre baglæns (dræn). IN1 = GPIO10, IN2 = GPIO11 |
| Berøringsfri niveausensor | XKC-Y25-NPN (5-24V, NPN-udgang) | ~40 DKK | "Skål tom": limes op under skålens sump i bay'en, måler gennem tank-gulvet. Fødes fra boostens 12V. VERIFICÉR: udgangens polaritet og at den ser gennem 4mm PETG |
| Orkide-bark | Fin/medium fyrrebark ~2 L | ~40 DKK | Forbrugsvare; skiftes hvert ~2. år |
| Sump-si | Rustfrit net / lille akvarie-si til 3×5mm-slange | ~15 DKK | Holder bark-smuld ude af pumpen |
| Stænk-hætte | Printes (TPU/PETG) | — | TODO i CAD: skaktens top |
| Ladebase | Printes (PETG/PLA), ~100g ved 15% infill | — | `charging_base.scad` — passer til Apple MagSafe 25W (pos 45) |
| Pumpe-vugge | Printes (PETG eller TPU), ~6g + 2 kabelstrips | — | `pump_cradle.scad` — mål motor-Ø og aksehøjde først |

## Pin-allokering (orkide)

ESP32-H2 (ADR 014) — samme på ESP32-H2-Zero og MINI-1-modulet:

| GPIO | Funktion |
|---|---|
| 0 | Buzzer |
| 1 | XKC "skål tom" (NPN, intern pull-up) |
| 2 | Float lav |
| 3 | fri (batteriet måles af MAX17048 på I2C, ADR 016) |
| 4 / 5 | I2C — SHT41 + MAX17048 |
| 10 | H-bro IN1 (fyld) |
| 11 | H-bro IN2 (dræn) |
| 12 | Knap (LP-pin, vækker fra sleep) |
| 22 | Switch A — boost 12V |
| 23 | Float fuld |

## Åbne punkter før bestilling
- NKP-DC-S10B: bekræft børstet DC-variant, strømforbrug og fysiske mål
  (bay_h = 47mm er sat efter forhandler-mål)
- DRV8871: strømgrænsen sættes af ILIM-modstanden — tjek breakout'ens værdi
  mod pumpens drift- og startstrøm
- Pololu U3V40F12 ved 5W: ~1,7A fra batteriet ved 3,5V — inden for spec,
  men mål temperaturen i den lukkede bay under et 5-min fyld
