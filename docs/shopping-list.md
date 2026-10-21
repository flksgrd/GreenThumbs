# Indkøbsliste — 1× pot/ (Monstera, CUSTOM) + 1× pot-orchid

**Dato:** 2026-10-22 · Priser er vejledende BOM-estimater i DKK, uden fragt og told.
Detaljer og begrundelser: [pot/hardware/bom.csv](../pot/hardware/bom.csv) og
[pot-orchid/preliminary-bom.md](../pot-orchid/preliminary-bom.md).

| | DKK |
|---|---:|
| Bestil nu (moduler, sensorer, strøm, mekanik, filament) | **2701** |
| Kun til stripboard-prototypen | 182 |
| **I alt** | **2883** |
| Valgfrit (ikke med) | 260 |

Haves allerede: 5V USB-C-lader, Apple MagSafe 25W (ladebasen er tegnet til den).

## Ordrer pr. butik (færre forsendelser)

- **The Pi Hut** — XIAO ×3, Pololu U3V40F12 ×2, Qi-modtager ×2, DRV8871
  (tjek lagerstatus; ellers Mouser/Digi-Key for XIAO og DRV8871)
- **Nkon / 18650batteries.dk** — 4× 18650 med loddefaner
- **3djake** — PETG ×3, PLA
- **AliExpress** — resten af elektronikken, sensorer, pumper, kabler, stik
  (2-3 ugers levering → bestil først)
- **Lokalt** — bolte, gummifødder, LECA, EPDM, slange-lod, sump-si
- **Berrybase / Eckstein** — Grove Water Level

## Før du bestiller
- [ ] NKP-DC-S10B: børstet DC (kan vendes), mål ~67×55×41mm, slangestuds
- [ ] KXF-DC-S06: flangens hulafstand (CAD antager 46mm)
- [ ] TP4056-modulet: 5,1kΩ CC-modstande på USB-C (ellers ingen 5V fra C-til-C-ladere)
- [ ] USB-C-forlængerens hun-ende ≤ 12,5×6,5×25mm (lommerne i CAD)
- [ ] Orkidens floats: M8-gevind

## Om sektionen "Kun til stripboard-prototypen"
Skifterne, dioderne og de passive komponenter sidder på printet. På et
færdigt SMD-PCB (KiCad, se [research-noten](research/kicad-round-pcb.md))
loddes de i SMD eller følger med samlingsordren hos fx JLCPCB, så den
sektion er kun nødvendig, hvis prototypen bygges på stripboard først.
Modulerne (boost, lader, H-bro, Qi, XIAO) kan sidde på headers på et
færdigt PCB — om de i stedet skal integreres, afgøres når PCB'et designes.

## Moduler og MCU

| ✓ | Del | Antal | Stk. | I alt | Butik | Til | Note |
|---|---|---:|---:|---:|---|---|---|
| [ ] | Seeed XIAO ESP32-C6 (113991254) | 3 | 80 | 240 | The Pi Hut / Mouser | begge + 1 reserve |  |
| [ ] | Pololu U3V40F12 boost 12V (#4016) | 2 | 110 | 220 | The Pi Hut / RobotShop | begge |  |
| [ ] | TP4056 USB-C-modul m. beskyttelse (DW01A+FS8205A) | 5 | 8 | 40 | AliExpress | begge + 3 reserve | Tjek 5,1kΩ CC-modstande |
| [ ] | Modstand 2,0kΩ SMD 1% (TP4056 R_PROG) | 1 | 5 | 5 | LCSC / Conrad | begge | Pakke; tjek R3's størrelse (0603/0805) |
| [ ] | Qi-modtager 5V ≥600 mA (spole ~46×36mm) | 2 | 70 | 140 | The Pi Hut / AliExpress | begge | pot/: kun uden load cell |
| [ ] | DRV8871 H-bro-breakout (Adafruit 3190) | 1 | 60 | 60 | The Pi Hut / Digi-Key | orkide |  |
| [ ] | AHT20-breakout (I2C 0x38) | 2 | 25 | 50 | AliExpress / Adafruit | begge |  |
| | **Sum** | | | **755** | | | |

## Pumper og sensorer

| ✓ | Del | Antal | Stk. | I alt | Butik | Til | Note |
|---|---|---:|---:|---:|---|---|---|
| [ ] | Kamoer KXF-DC-S06 12V peristaltisk | 1 | 150 | 150 | AliExpress / Robu | pot/ | Tjek flange 46mm c-c |
| [ ] | Kamoer NKP-DC-S10B 12V peristaltisk, børstet DC | 1 | 200 | 200 | AliExpress / Kamoer | orkide | Pris = skøn. Tjek vendbar DC, mål og slangestuds |
| [ ] | Kapacitiv soil moisture v2.0 | 2 | 40 | 80 | AliExpress | pot/ + reserve |  |
| [ ] | Seeed Grove Water Level 10cm (101020635) | 1 | 75 | 75 | Berrybase / Eckstein | pot/ |  |
| [ ] | Mini-float switch, lodret, NO | 3 | 25 | 75 | AliExpress / Conrad | pot/ 1, orkide 2 | Orkide: M8-gevind (beslag Ø8,5) |
| [ ] | XKC-Y25-NPN berøringsfri niveausensor | 1 | 40 | 40 | AliExpress | orkide | Tjek udgangens polaritet |
| [ ] | Passiv piezo-buzzer 12mm | 2 | 5 | 10 | AliExpress | begge |  |
| | **Sum** | | | **630** | | | |

## Strøm og ladning

| ✓ | Del | Antal | Stk. | I alt | Butik | Til | Note |
|---|---|---:|---:|---:|---|---|---|
| [ ] | 18650 m. loddefaner, 3000-3500 mAh (Samsung 35E / LG MJ1) | 4 | 55 | 220 | Nkon / 18650batteries.dk | begge (2 hver) | AliExpress sender sjældent celler |
| [ ] | USB-C-forlænger han→hun (0,5 m + 0,3 m) | 2 | 40 | 80 | AliExpress / Adafruit | pot/ 0,5 m, orkide 0,3 m | Hun-overmold ≤ 12,5×6,5×25mm |
| [ ] | USB-C-støvpropper, silikone, 10-pak | 1 | 20 | 20 | AliExpress | begge |  |
| | **Sum** | | | **320** | | | |

## Kabler, stik og mekanik

| ✓ | Del | Antal | Stk. | I alt | Butik | Til | Note |
|---|---|---:|---:|---:|---|---|---|
| [ ] | Silikoneslange 4×6mm, fødevaregodkendt, 2 m | 1 | 30 | 30 | AliExpress / RS | begge | Tjek NKP'ens studs-Ø |
| [ ] | JST-XH-kit m. crimp-kontakter | 1 | 50 | 50 | AliExpress | begge |  |
| [ ] | Silikonekabel 22AWG rød/sort/gul | 1 | 40 | 40 | AliExpress | begge |  |
| [ ] | Skærmet 4-leder LiYCY 4×0,14mm², 3 m | 1 | 30 | 30 | Conrad / Elfa | pot/ |  |
| [ ] | Trykknap 6×6mm m. hætte | 2 | 3 | 6 | AliExpress / Conrad | begge |  |
| [ ] | M3 heat-set inserts, 50 stk | 1 | 50 | 50 | AliExpress | pot/ |  |
| [ ] | M3-bolte rustfri, assortiment | 1 | 50 | 50 | Byggemarked | pot/ |  |
| [ ] | EPDM-strip / 2mm O-ring-snor, 2 m | 1 | 40 | 40 | VVS / AliExpress | pot/ | CUSTOM: ~0,72 m |
| [ ] | Kabelforskruning M12×1,5 IP68 | 1 | 10 | 10 | Conrad / AliExpress | pot/ |  |
| [ ] | Kabelforskruning M16×1,5 m. 2-huls indsats | 1 | 15 | 15 | Conrad / AliExpress | pot/ |  |
| [ ] | Split-grommet til Ø14 (USB-C-gennemføring) | 1 | 10 | 10 | Conrad | pot/ | Eller silikone |
| [ ] | Slange-lod (rustfrit/keramik) | 1 | 10 | 10 | Akvariebutik | pot/ |  |
| [ ] | Gummifødder ≥5mm, 4 stk | 1 | 20 | 20 | Byggemarked | pot/ | Kun uden load cell |
| [ ] | Sump-si (rustfrit net til Ø6 slange) | 1 | 15 | 15 | Akvariebutik | orkide |  |
| | **Sum** | | | **376** | | | |

## Filament og substrat

| ✓ | Del | Antal | Stk. | I alt | Butik | Til | Note |
|---|---|---:|---:|---:|---|---|---|
| [ ] | PETG 1 kg, opak | 3 | 150 | 450 | 3djake / Prusa | begge | pot/ CUSTOM ~1,7 kg + orkide ~0,6 kg + ladebase ~0,1 kg (massiv) |
| [ ] | PLA 1 kg (prøveprint) | 1 | 120 | 120 | 3djake | begge |  |
| [ ] | LECA 2-3 L | 1 | 50 | 50 | Plantorama | pot/ |  |
| | **Sum** | | | **620** | | | |

## Kun til stripboard-prototypen

| ✓ | Del | Antal | Stk. | I alt | Butik | Til | Note |
|---|---|---:|---:|---:|---|---|---|
| [ ] | Stripboard 7×9cm | 2 | 20 | 40 | Conrad | begge |  |
| [ ] | AO3401A P-MOSFET SOT-23, 10-pak | 1 | 10 | 10 | AliExpress / LCSC | begge (3 bruges) |  |
| [ ] | 2N7002 N-MOSFET SOT-23, 10-pak | 1 | 10 | 10 | AliExpress / LCSC | begge (2 bruges) |  |
| [ ] | SOT-23→DIP-adaptere, 10-pak | 1 | 15 | 15 | AliExpress | begge |  |
| [ ] | 1N5817 Schottky, 10-pak | 1 | 10 | 10 | AliExpress / Mouser | begge |  |
| [ ] | Modstandssortiment E24 1/4W 1% | 1 | 60 | 60 | AliExpress / Conrad | begge | 2,0k / 4,7k / 5,1k / 10k / 100k / 200k |
| [ ] | Kondensatorer: 100-220µF ≥10V, 10µF, 100nF | 1 | 15 | 15 | AliExpress / Conrad | begge |  |
| [ ] | Skrueterminaler 2/3-polet | 4 | 3 | 12 | AliExpress / Conrad | begge |  |
| [ ] | Female pin headers 2,54mm | 2 | 5 | 10 | AliExpress / Conrad | begge |  |
| | **Sum** | | | **182** | | | |

## Valgfrit (ikke med i summen)

| ✓ | Del | Antal | Stk. | I alt | Butik | Til | Note |
|---|---|---:|---:|---:|---|---|---|
| [ ] | HX711 + 5 kg load cell + M4/M5-bolte | 1 | 80 | 80 | AliExpress | pot/ | Monstera kan overstige 5 kg; Qi virker ikke oven på platformen |
| [ ] | TPU 90A 250 g | 1 | 120 | 120 | 3djake | pot/ | Alternativ til EPDM-pakningen |
| [ ] | Wick-snor 4mm | 1 | 20 | 20 | AliExpress | pot/ | Kun til bundvanding (ADR 006) |
| [ ] | Orkide-bark 2 L | 1 | 40 | 40 | Plantorama | orkide | Først ved omplantning (~hvert 2. år) |
| | **Sum** | | | **260** | | | |

