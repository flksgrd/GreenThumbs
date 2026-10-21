# DTU-komponentshoppen — hvad kan GreenThumbs bruge?

**Dato:** 2026-10-22
**Kilde:** `dtu_component_shop.csv` (1465 linjer; må bruges til private projekter)
**Konklusion:** Shoppen dækker de passive dele og et par diskrete dele 1:1.
Ingen af de aktive moduler (boost, lader, H-bro, Qi, sensorer) kan erstattes
uden at designet bliver dårligere. Alt er THT → godt til stripboard-
prototypen, mindre relevant for den runde KiCad-PCB (SMD).

## Overblik over shoppen

| Kategori | Antal | Relevans |
|---|---|---|
| Modstande E96 1/4W THT (1Ω-18MΩ) | 600 | **Høj** — alle vores værdier findes |
| Kondensatorer (keramisk, elektrolyt, film) | 138 | **Høj** |
| Logik-IC'er (4000, 74HC/HCT/LS) | 298 | Ingen |
| Lineære IC'er + regulatorer | 59 | Lav (se nedenfor) |
| Transistorer (BJT, MOSFET, TRIAC) | 93 | Lav-middel |
| Dioder (Schottky, TVS, zener, ensretter) | 91 | Middel |
| Stik, terminaler, headers, knapper | 26 | Middel |
| Spoler, LED'er, opto, IR, encodere, relæ | 60 | Ingen |

## Afvejning pr. kandidat

### ✅ Ja — erstatter BOM-dele 1:1 (indført i bom.csv)

| BOM | DTU-del | Pro | Con | Dom |
|---|---|---|---|---|
| 5 Schottky 1N5819 | **1N5817** | Lavere Vf (~0,4V ved 0,6A mod ~0,5V) → mere spændingsmargin til TP4056 fra Qi-modtageren | Kun 20V (1N5819: 40V). Som flyback over 12V-pumpen er 20V stadig nok | **Ja** — bedre til OR-ing, nok til flyback |
| 6, 42 Modstande 10k/100k/200k | E96 THT | Gratis, 1% tolerance (bedre end kulfilm), lige nu | Ingen | **Ja** |
| 40 Gate-driver 2N7002 | **BS170** (TO-92) | THT → ingen SOT-23-adapter; trækker kun P-FET-gaten (~40 µA), så Vgs(th) op til 3,0V er ok | Vgs(th) max 3,0V er tæt på 3,3V GPIO — men ved µA-belastning er det nok | **Ja** |
| 43 Elkoer + keramiske | 220µF 10V / 100µF, 10µF, 100nF | Gratis | Nogle elkoer har ingen spænding i listen → læs mærkningen (≥10V ved batteriet) | **Ja** |
| 16 Knap | Momentary Pushbutton | Gratis | Ukendt størrelse → tjek mod hullet i ebase | **Ja** |
| (ny) 48 | Skrueterminaler 2/3-polet | Pumpe/batteri/boost kan skiftes uden lodning | Fylder mere end JST | **Ja** til prototypen |
| (ny) 49 | Female pin headers | XIAO og moduler sokles → udskiftelige | Byggehøjde +8mm (ebase har 40mm) | **Ja** |

### 🟡 Måske — fallback eller prototype-hjælp

| Til | DTU-del | Pro | Con | Dom |
|---|---|---|---|---|
| 47 R_PROG 2,0kΩ (0603) | 2k THT | Haves nu | Skal loddes som "bodge" på 0603-pads → skrøbelig (sikr med varmlim) | Fallback; SMD-modstanden (5 kr) er pænere |
| TP4056 uden CC-modstande | **5,11k** ×2 | Redder et modul, der ikke lader fra USB-C-ladere | Kræver adgang til CC-pads | Gem til hvis modulet fejler |
| I2C pull-ups | **4,75k** | Hvis en breakout mangler pull-ups | Typisk unødvendig | Fallback |
| 17 JST-XH-kit | Molex-headers 2-8 pin | Gratis, polariseret | Uklart om crimp-kontakterne ("Contact Female") passer; større end XH | Kun hvis kontakterne passer |
| Orkide: H-bro DRV8871 | **L293D** (DIP16) | Haves nu → pumpe-reversering kan testes på breadboard før bestilling; indbyggede dioder | Logikforsyning kræver 4,5-7V (vi har ingen 5V → LM7805 fra 12V); ~2V spændingsfald → pumpen får ~10V; 600 mA/kanal er knapt til NKP's startstrøm; varme i lukket bay | Kun til en tidlig test — **ikke** i det færdige design |

### ❌ Nej — dårligere end det valgte

| Del | Hvorfor ikke |
|---|---|
| P-MOSFET IRF5305 / IRF9530 / IRF9540 (til switch A/B) | Ikke logic-level: Vgs(th) −2 til −4V. Ved et batteri på 3,0-4,2V er de kun delvist tændt (høj Rds, varme) eller slet ikke → AO3401A bevares |
| N-MOSFET IRL530 / IRL640 | Logic-level specificeret ved 4-5V, ikke 3,3V; designet har ingen low-side-switch mere |
| PNP BC557/BC327 som sensor-switch B | Ville virke (15 mA), men giver 0,1-0,25V fald og base-strøm — og vi køber AO3401A ×10 alligevel til switch A |
| L298 | Samme problemer som L293D, større spændingsfald (~2-3V), Multiwatt-hus, eksterne dioder |
| LM7805 / LM2930 / LM317 | Lineære regulatorer brænder batteri af; vi har intet 5V-behov |
| LM2575 / LM2676 | Buck — vi skal **op** fra 3,7V til 12V |
| LM35 | AHT20 måler også luftfugtighed (VPD) |
| DS1307 RTC | Tiden kommer fra Matter/Thread; ekstra strømforbrug |
| MCP3208 ADC, MCP6002 op-amp | ESP32-C6 har ADC; 100nF over batteri-deleren er nok |
| Fotomodstand / BPW34 (lysmåling) | Ingen ledige GPIO i nogen af versionerne, og pyntepotte + blade skygger. Idé til v2 med I2C-lyssensor |
| TVS BZW06-6V4 / 1.5KE7V5 (USB-input) | Clamper over TP4056's absolute max (8V) → begrænset beskyttelse; lav værdi |
| Relæ, optokoblere, LED'er, spoler, encodere, logik-IC'er | Intet behov / ingen ledige pins / strømforbrug |

## Generelle pro/con

- **Pro:** gratis, tilgængeligt nu (ingen 2-3 ugers AliExpress-ventetid) →
  breadboard-prototypen kan startes med det samme for alt undtagen
  modulerne. 1% metalfilm er bedre end de modstande, BOM'en antog.
- **Con:** alt er THT → fylder mere på stripboard og bruges næppe på den runde
  SMD-PCB. Elkoer uden spændingsangivelse skal tjekkes. Datablade følger
  ikke med — værdierne ovenfor er fra standarddatablade for de nævnte typer.

## Stadig nødvendigt at købe
XIAO ESP32-C6, Kamoer-pumper, DRV8871 (orkide), Pololu U3V40F12, TP4056-modul,
2× 18650, AO3401A + SOT-23-adaptere, Qi-modtager, USB-C-forlænger,
sensorer (soil, Grove, AHT20, floats, XKC, HX711/load cell), buzzer, slanger,
filament.
