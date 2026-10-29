# Indkøbslister

Delt i to: **orkiden først** (selvstændig liste — pakker der rækker til begge
ligger her), derefter **pot/** med kun det der skal købes ekstra. Priser er
vejledende BOM-estimater i DKK, uden fragt og told. Detaljer:
[pot/hardware/bom.csv](../pot/hardware/bom.csv) og
[pot-orchid/preliminary-bom.md](../pot-orchid/preliminary-bom.md).

| | Orkide | pot/ (Monstera) |
|---|---:|---:|
| Bestil | **1466** | **1210** |
| Kun til breadboard-test (før PCB) | 180 | 0 |
| **I alt** | **1646** | **1210** |
| Valgfrit (ikke med) | 40 | 220 |

Plus én gang til begge: **HomePod mini ~800 DKK** (afsnit 0).

Haves allerede: 5V USB-C-lader, Apple MagSafe 25W (orkidens ladebase er tegnet til den).
Forudsat i skuffen: kabelstrips ≤3,6mm (2 til pumpe-vuggen), lim / tynd dobbeltklæbende tape.

**"Breadboard-test"** er det, der skal til for at måle de elektriske ubekendte
før PCB'et (se [wiring-diagram.md](../pot/hardware/breadboard/wiring-diagram.md)).
Der bygges ingen stripboard: næste trin er et carrier-PCB, hvor switches og
passive komponenter loddes i SMD eller følger med samleordren (fx JLCPCB).
Modulerne (boost, lader, H-bro, Qi) kan sidde på headers på et færdigt PCB; MCU'en
bliver dér et ESP32-H2-MINI-1-H4S-modul (samme chip som Zero-boardet, ADR 014).

---

## 0. Fælles — Apple home hub (én gang)

Apple Home kræver en home hub (HomePod mini, HomePod eller Apple TV) for
at tilføje Matter-enheder; HomePod mini er også Thread border router
([Apple](https://support.apple.com/102557)). Tredjeparts border routere
(fx GL.iNet GL-S20) kan ikke være home hub.

| ✓   | Del                | Antal | Stk. | I alt | Butik                      | Note                                                                       |
| --- | ------------------ | ----: | ---: | ----: | -------------------------- | -------------------------------------------------------------------------- |
| [ ] | Apple HomePod mini |     1 | 1299 |  1299 | apple.com/dk / forhandlere | Pris = skøn. En "HomePod mini 2" er rygtet til oktober 2026 — tjek før køb |

---

## 1. Orkide (pot-orchid)

**Butikker:** The Pi Hut (ESP32-H2-Zero, Pololu, Qi, DRV8871 — tjek lager) ·
Nkon (celler) · 3djake (filament) · AliExpress (resten — 2-3 ugers levering,
bestil først) · akvariebutik (sump-si) · byggemarked (bolte)

**Før du bestiller:**
- [x] NKP-DC-S10B (bekræftet 2026-10-26): børstet DC → kan vendes, 67,5×54,5×41mm,
      ingen studs → 3×5mm-slange + 3mm-samlere
- [ ] TP4056-modulet: 5,1kΩ CC-modstande på USB-C
- [ ] USB-C-forlængerens hun-ende ≤ 12,5×6,5×25mm (skaktens slids)
- [ ] Floats: M8-gevind
- [ ] Mål din MagSafe-lader (CAD: Ø55,5 × 4,45mm) og dyrkningspotten
      (CAD: top Ø120, bund Ø90, højde 110)

### Moduler og MCU

| ✓   | Del                                                | Antal | Stk. |   I alt | Butik                               | Note                                                                                     | **Fra Bruger**                                                                                                                                       |
| --- | -------------------------------------------------- | ----: | ---: | ------: | ----------------------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| [ ] | ESP32-H2-Zero 3-pak (Ulegqin — Waveshare-kopi)     |     1 |  150 |     150 | AliExpress / Amazon                 | ≈ €20; dækker pot/ + reserve. Tjek ESP32-H2FH4S (4 MB) + Waveshare-pinout. Aflod RGB-LED | Fundet, brand Ulegqin? 3 for 20 Euro                                                                                                                 |
| [ ] | Pololu U3V40F12 boost 12V (#4016)                  |     1 |  110 |     110 | Eckstein / Botland / TME / EXP-Tech | Pololus EU-forhandlere; ~$10 hos Pololu                                                  | Ikke fundet endnu                                                                                                                                    |
| [ ] | TP4056 USB-C-modul m. beskyttelse (DW01A+FS8205A)  |     5 |    8 |      40 | AliExpress                          | Dækker pot/ + reserver. CC: se efter to modstande mærket 512/5K1 ved USB-C               | Kan ikke finde hvor jeg skal tjekke CC-modstande, giver det mening at opgradere til BQ2606 (4.5-12V, 3A) eller en opgraderet TC4056 med (4-8V, 1.2A) |
| [ ] | SMD-modstandssæt (skal indeholde 2,0kΩ til R_PROG) |     1 |    5 |       5 | AliExpress / LCSC                   | Tjek at 2,0k (202/2001) er med og pad-størrelsen på R3                                   | Fundet, et sæt med 1500 SMD-res med 60 forskellige værdier, klart overkill men så har jeg til fremtidige projekter også                              |
| [ ] | Qi-modtager 5V 1A (spole 40×29mm)                  |     1 |   70 |      70 | AliExpress                          | Spolen i bay-lommen (nu 41×30); modul-printet på elektronik-hylden                       | Fundet, 5V 1A, chip er 33x16x1.1mm og spole er 40x29x0.3mm                                                                                           |
| [ ] | DRV8871 H-bro-breakout, ÉN kanal, 6,5-45V          |     1 |   60 |      60 | AliExpress / Adafruit               | OBS: "1,5A 2-kanal" er typisk DRV8833/MX1508 (max ~10V) — virker ikke ved 12V            | Fundet, 1.5A 2 Channel H-Bridge PWM                                                                                                                  |
| [ ] | SHT41-breakout (I2C 0x44, ADR 015) | 1 | 35 | 35 | AliExpress / Adafruit | Afløser AHT20: ±1,8 %RH / ±0,2 °C + varmer. Pris = skøn | Fundet, 15.11x10.41mm, Hvad er forskellen på denne og så f.eks. SHT45/SHT41? |
|     | **Sum**                                            |       |      | **460** |                                     |                                                                                          |                                                                                                                                                      |

### Pumpe og sensorer

| ✓   | Del                                             | Antal | Stk. |   I alt | Butik               | Note                              |
| --- | ----------------------------------------------- | ----: | ---: | ------: | ------------------- | --------------------------------- |
| [ ] | Kamoer NKP-DC-S10B 12V peristaltisk, børstet DC |     1 |  200 |     200 | AliExpress / Kamoer | Pris = skøn. 12V 0,3A, ≥70 ml/min |
| [ ] | Mini-float switch, lodret, M8-gevind            |     2 |   25 |      50 | AliExpress / Conrad | Beslagene har Ø8,5 hul            |
| [ ] | XKC-Y25-NPN berøringsfri niveausensor           |     1 |   40 |      40 | AliExpress          | Tjek udgangens polaritet          |
| [ ] | Passiv piezo-buzzer 12mm                        |     2 |    5 |      10 | AliExpress          | 1 til pot/                        |
|     | **Sum**                                         |       |      | **300** |                     |                                   |

### Strøm og ladning

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | 18650 m. loddefaner, 3000-3500 mAh (Samsung 35E / LG MJ1) | 2 | 55 | 110 | Nkon / 18650batteries.dk | AliExpress sender sjældent celler |
| [ ] | USB-C-forlænger han→hun, 0,3 m | 1 | 40 | 40 | AliExpress / Adafruit | Hun-overmold ≤ 12,5×6,5×25mm |
| [ ] | USB-C-støvpropper, silikone, 10-pak | 1 | 20 | 20 | AliExpress | Dækker også pot/ |
| | **Sum** | | | **170** | | |

### Kabler, stik og mekanik

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | Silikoneslange 3×5mm (ID 3 / OD 5), fødevaregodkendt, 2 m | 1 | 30 | 30 | AliExpress / RS | NKP'ens slangestørrelse |
| [ ] | Lige slangesamler 3mm (barbed), 10-pak | 1 | 15 | 15 | AliExpress | Forlænger pumpeslangen |
| [ ] | JST-XH-kit m. crimp-kontakter | 1 | 50 | 50 | AliExpress | Dækker også pot/ |
| [ ] | Silikonekabel 22AWG rød/sort/gul | 1 | 40 | 40 | AliExpress | Dækker også pot/ |
| [ ] | Trykknap 6×6mm m. hætte | 2 | 3 | 6 | AliExpress / Conrad | 1 til pot/ |
| [ ] | M3 heat-set inserts, 50 stk | 1 | 50 | 50 | AliExpress | Pumpe-beslag; dækker også pot/ |
| [ ] | M3-bolte rustfri, assortiment | 1 | 50 | 50 | Byggemarked | Dækker også pot/ |
| [ ] | Sump-si (rustfrit net til 3×5 slange) | 1 | 15 | 15 | Akvariebutik |  |
| | **Sum** | | | **256** | | |

### Filament

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | PETG 1 kg, opak | 1 | 150 | 150 | 3djake / Prusa | Tank+låg+bay ~0,6 kg + ladebase ~0,27 kg massiv |
| [ ] | PLA 1 kg (prøveprint) | 1 | 120 | 120 | 3djake | Dækker også pot/ |
| | **Sum** | | | **270** | | |

### Breadboard-test (kun før PCB)

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | Breadboard, 830 huller | 1 | 30 | 30 | AliExpress / Conrad | Genbruges til pot/ |
| [ ] | Jumperkabler han-han + han-hun, sæt | 1 | 30 | 30 | AliExpress |  |
| [ ] | AO3401A P-MOSFET SOT-23, 10-pak | 1 | 10 | 10 | AliExpress / LCSC | Orkide bruger 1, pot/ 2 |
| [ ] | 2N7002 N-MOSFET SOT-23, 10-pak | 1 | 10 | 10 | AliExpress / LCSC | Orkide 1, pot/ 1 |
| [ ] | SOT-23→DIP-adaptere, 10-pak | 1 | 15 | 15 | AliExpress | Så MOSFET'erne kan sidde i breadboardet |
| [ ] | 1N5817 Schottky, 10-pak | 1 | 10 | 10 | AliExpress / Mouser | Dækker også pot/ |
| [ ] | Modstandssortiment E24 THT 1/4W 1% | 1 | 60 | 60 | AliExpress / Conrad | THT — SMD-sættet passer ikke i et breadboard |
| [ ] | Kondensatorer: 100-220µF ≥10V, 10µF, 100nF | 1 | 15 | 15 | AliExpress / Conrad | Dækker også pot/ |
| | **Sum** | | | **180** | | |

### Valgfrit (ikke med i summen)

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | Orkide-bark 2 L | 1 | 40 | 40 | Plantorama | Først ved omplantning (~hvert 2. år) |

---

## 2. pot/ (Monstera, CUSTOM-sættet)

Forudsætter at orkide-ordren er købt — rækker med "fra orkide-ordren" koster 0.

**Butikker:** The Pi Hut (ESP32-H2-Zero, Pololu, Qi) · Nkon (celler) · 3djake (PETG) ·
AliExpress · Berrybase/Eckstein (Grove) · Conrad (glands, kabel) · lokalt
(EPDM, LECA, gummifødder, slange-lod)

**Før du bestiller:**
- [ ] KXF-DC-S06: flangens hulafstand (CAD antager 46mm)
- [ ] USB-C-forlængerens hun-ende ≤ 12,5×6,5×25mm (lommen ved flangen)
- [ ] Load cell eller ej (Qi virker ikke oven på platformen; en Monstera
      kan overstige 5 kg)

### Moduler og MCU

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | ESP32-H2-Zero | 1 | — | — | — | fra orkide-ordren (3-pak) |
| [ ] | Pololu U3V40F12 boost 12V (#4016) | 1 | 110 | 110 | The Pi Hut / RobotShop |  |
| [ ] | TP4056-modul + 2,0kΩ R_PROG | 1 | — | — | — | fra orkide-ordren |
| [ ] | Qi-modtager 5V ≥600 mA | 1 | 70 | 70 | The Pi Hut / AliExpress | Kun uden load cell — ellers spring over |
| [ ] | SHT41-breakout (I2C 0x44) | 1 | 35 | 35 | AliExpress / Adafruit | ADR 015 |
| | **Sum** | | | **215** | | |

### Pumpe og sensorer

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | Kamoer KXF-DC-S06 12V peristaltisk | 1 | 150 | 150 | AliExpress / Robu | Tjek flange 46mm c-c |
| [ ] | Kapacitiv soil moisture v2.0 | 2 | 40 | 80 | AliExpress | 1 + reserve |
| [ ] | Seeed Grove Water Level 10cm (101020635) | 1 | 75 | 75 | Berrybase / Eckstein |  |
| [ ] | Mini-float switch, lodret, NO | 1 | 25 | 25 | AliExpress / Conrad | Klipses i reservoirets bund |
| [ ] | Passiv piezo-buzzer | 1 | — | — | — | fra orkide-ordren |
| | **Sum** | | | **330** | | |

### Strøm og ladning

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | 18650 m. loddefaner, 3000-3500 mAh | 2 | 55 | 110 | Nkon / 18650batteries.dk |  |
| [ ] | USB-C-forlænger han→hun, 0,5 m | 1 | 40 | 40 | AliExpress / Adafruit | Hun-overmold ≤ 12,5×6,5×25mm |
| [ ] | USB-C-støvprop | 1 | — | — | — | fra orkide-ordren |
| | **Sum** | | | **150** | | |

### Kabler, stik og mekanik

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | JST-kit, silikonekabel, knap, M3-inserts/-bolte | 1 | — | — | — | fra orkide-ordren |
| [ ] | Silikoneslange 4×6mm, fødevaregodkendt, 2 m | 1 | 30 | 30 | AliExpress / RS | KXF-pumpen (orkiden bruger 3×5) |
| [ ] | Skærmet 4-leder LiYCY 4×0,14mm², 3 m | 1 | 30 | 30 | Conrad / Elfa | Sensor-forlængere |
| [ ] | EPDM-strip / 2mm O-ring-snor, 2 m | 1 | 40 | 40 | VVS / AliExpress | CUSTOM: ~0,72 m |
| [ ] | Kabelforskruning M12×1,5 IP68 | 1 | 10 | 10 | Conrad / AliExpress |  |
| [ ] | Kabelforskruning M16×1,5 m. 2-huls indsats | 1 | 15 | 15 | Conrad / AliExpress |  |
| [ ] | Split-grommet til Ø14 (USB-C-gennemføring) | 1 | 10 | 10 | Conrad | Eller silikone |
| [ ] | Slange-lod (rustfrit/keramik) | 1 | 10 | 10 | Akvariebutik |  |
| [ ] | Gummifødder ≥5mm, 4 stk | 1 | 20 | 20 | Byggemarked | Kun uden load cell |
| | **Sum** | | | **165** | | |

### Filament og substrat

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | PETG 1 kg, opak | 2 | 150 | 300 | 3djake / Prusa | CUSTOM-sættet ~1,7 kg massiv |
| [ ] | PLA | 1 | — | — | — | fra orkide-ordren |
| [ ] | LECA 2-3 L | 1 | 50 | 50 | Plantorama |  |
| | **Sum** | | | **350** | | |

### Breadboard-test (kun før PCB)

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | Breadboard, jumpere, MOSFET'er, adaptere, dioder, modstande, kondensatorer | 1 | — | — | — | fra orkide-ordren |
| | **Sum** | | | **0** | | |

### Valgfrit (ikke med i summen)

| ✓ | Del | Antal | Stk. | I alt | Butik | Note |
|---|---|---:|---:|---:|---|---|
| [ ] | HX711 + 5 kg load cell + M4/M5-bolte | 1 | 80 | 80 | AliExpress | Monstera kan overstige 5 kg; Qi virker ikke oven på platformen |
| [ ] | TPU 90A 250 g | 1 | 120 | 120 | 3djake | Alternativ til EPDM-pakningen |
| [ ] | Wick-snor 4mm | 1 | 20 | 20 | AliExpress | Kun til bundvanding (ADR 006) |
