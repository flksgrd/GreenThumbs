# Pot-Orchid — BOM (forskel fra pot/)

**Status:** Foreløbig — design v0 (ADR 011). Grundlaget er
[pot/hardware/bom.csv](../pot/hardware/bom.csv); her står kun hvad der er
anderledes. Pos-numre henviser til pot/-BOM'en.

## Kort svar: ~80% af BOM'en er den samme

Samme dele: XIAO ESP32-C6 (1), PD-trigger (12), buck (13), USB-C-adapter (14),
WS2812 (15), knap (16), JST-kit (17), stripboard (18), silikone-ledning (19),
M3-inserts/-bolte (20, 21), silikoneslange (3), Grove water level (8),
float switch (9), AHT20 (27), buzzer (28), USB-C panel-mount (31),
skærmet kabel (32), PLA til testprint (33).

## Ændret

| pot/-pos | pot/ | Orkide | Hvorfor |
|---|---|---|---|
| 2 | Kamoer KXF-DC (37 ml/min) | **Kamoer KPHM200** (12V 0.7A, 260 ml/min — forhandler-spec) | Fyld/dræn på ~2,5 min i stedet for ~16 min. VERIFICÉR: børstet DC-variant (vendbar), ikke stepper, og mål til pump-mount |
| 4-6 | MOSFET + diode + modstand | **H-bro DRV8871-breakout** (Adafruit 3190 el. lign., 6.5-45V) | Pumpen skal kunne køre baglæns (dræn). IN1 = D10, IN2 = D1 |
| 10, 11 | HX711 + 5kg load cell: OPTIONAL | **PÅKRÆVET** | Soak-trigger (ADR 004) + lager-niveau til refill-feedback. Totalvægt ~3-3,3 kg < 5 kg ✓ |
| 34 | M4/M5-bolte: optional | **Påkrævet** | Load cell-mount |
| 24 | PETG 2 kg (opak) | **1 kg opak + 1 kg KLAR PETG** | Klar: cup ~210g + kammervægge ~240g. Opak: lager ~245g + ebase/låg ~345g + kammergulv ~110g (massiv volumen-estimat) |
| 22 | EPDM-strip til ebase-pakning | EPDM/TPU-**skive** til skaktens krave | Tætner soak-gulvet mod skakten (ebase-pakningen udgår — ebase-toppen er tør) |
| 23, 23b | M12- + M16-glands | **Udgår** | Alt går gennem den tørre skakt; kun USB-C i siden |

## Udgår

| pot/-pos | Del | Hvorfor |
|---|---|---|
| 7 | Soil moisture-sensor | Upålidelig i bark (ADR 004) |
| 26 | Wick | Orkideen vandes ved soak |
| 29 | LECA | Bark i stedet |
| 35 | Gummifødder | Load cell er påkrævet (platformen har egne fødder) |

## Nyt

| Del | Spec | Est. pris | Note |
|---|---|---|---|
| Klar PETG | 1 kg | ~170 DKK | Cup + kammer-vægge |
| Orkide-bark | Fin/medium fyrrebark ~2 L | ~40 DKK | Forbrugsvare; skiftes hvert ~2. år |
| Si til sump-slange | Rustfrit net / lille akvarie-si til Ø6 slange | ~15 DKK | Holder bark-smuld ude af pumpen |
| Stænk-hætte til skakten | Printes (TPU/PETG) | — | TODO i CAD: skaktens top er en åbning ned til elektronikken |
| Underskål | Ø ≥ 180mm | — | Overflow-hullerne drypper udad (kun ved overfyldning/fejl) |

## Åbne punkter før bestilling
- KPHM200: bekræft pris, at det er DC-varianten (vendbar), og fysiske mål.
  ebase_height = 60mm er en placeholder
- DRV8871: strømgrænsen sættes af en modstand (ILIM) — tjek breakout'ens
  værdi mod pumpens 0.7A drift og startstrøm
