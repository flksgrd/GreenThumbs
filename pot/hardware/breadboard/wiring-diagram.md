# Wiring Diagram — Plantekrukke + Orkide (ESP32-H2-Zero prototype)

**Single source of truth** for pin-mapping mellem firmware og hardware. Hvis du ændrer pin-assignment her, opdater også `pot/firmware/src/main.cpp` PIN_* konstanter.

## Waveshare ESP32-H2-Zero pinout (ADR 014)

```
                    USB-C
        5V ─┤                ├─ GPIO24  TX  (ROM-log — bruges ikke)
       GND ─┤                ├─ GPIO23  RX
       3V3 ─┤  [RST] [BOOT]  ├─ GPIO25  (strapping — bruges ikke)
     GPIO0 ─┤                ├─ GPIO22
     GPIO1 ─┤ ADC1_CH0       ├─ GPIO14  (XTAL_32K — reserveret)
     GPIO2 ─┤ ADC1_CH1       ├─ GPIO13  (XTAL_32K — reserveret)
     GPIO3 ─┤ ADC1_CH2       ├─ GPIO12  LP
     GPIO4 ─┤ ADC1_CH3       ├─ GPIO11  LP
     GPIO5 ─┤ ADC1_CH4       ├─ GPIO10  LP
            └────────────────┘
   Pads på bagsiden: GPIO26/27 (USB D−/D+), GPIO9 (BOOT), GPIO8 (LOG)
```

Kilde: [Waveshare-pinout](https://docs.waveshare.com/ESP32-H2-Zero) +
[ESP32-H2-datablad](https://documentation.espressif.com/esp32-h2_datasheet_en.pdf) kap. 2-3.

- **ADC:** GPIO1-5 (ADC1_CH0-4)
- **Strapping:** GPIO8, GPIO9, GPIO25 → bruges ikke
- **LP-pins (GPIO8-14):** virker i alle sleep-modes → knappen sidder her, så
  den kan vække enheden
- **GPIO13/14:** 32 kHz-krystal på det færdige PCB (Thread-søvn) → holdes fri,
  så pin-mappingen er ens på Zero og MINI-1-modulet
- **GPIO2-5** er JTAG-pins, men rene indgange ved reset (JTAG går via USB)
- **GPIO23/24 (UART0)** har pull-up ved reset; GPIO24 sender bootloaderens log
- **Brugbare til os: præcis 11** — GPIO0-5, 10-12, 22, 23
- **Board-RGB-LED'en (WS2812) skal aflodes** — den trækker strøm, også slukket

## Pin allocation

Fælles i begge versioner: buzzer 0, batteri 3, I2C 4/5, knap 12, boost 22.

| GPIO | pot/ | pot-orchid/ | Noter |
|---|---|---|---|
| 0 | Piezo buzzer (LEDC PWM) | Piezo buzzer | ADR 008 |
| 1 | Soil moisture AOUT (ADC1_CH0) | XKC "skål tom" (NPN, intern pull-up) | |
| 2 | Float switch (intern pull-up; LOW = tomt) | Float lav | |
| 3 | fri (ADC1_CH2) | fri | Batteriet måles af MAX17048 på I2C (ADR 016) |
| 4 | I2C SDA (SHT41 + MAX17048 + Grove) | I2C SDA (SHT41 + MAX17048) | |
| 5 | I2C SCL | I2C SCL | |
| 10 | HX711 SCK | H-bro IN1 (fyld) | DRV8871 har pull-downs på IN |
| 11 | HX711 DOUT | H-bro IN2 (dræn) | |
| 12 | **Manuel knap** (intern pull-up) | **Manuel knap** | LP-pin → vækker fra sleep |
| 22 | **Switch A** — boost/pumpe (HIGH = on) | **Switch A** — boost | 10kΩ pulldown → slukket under boot |
| 23 | **Switch B** — sensorer (LOW = on) | Float fuld | Pull-up ved reset → sensorer slukket under boot |

I2C-bussen deles af SHT41 (0x44), MAX17048 (0x36) og Grove water level-sensoren (0x77 + 0x78).
ESP-IDF-konsollen kører på **USB Serial/JTAG** (GPIO26/27) via
`CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y`; på macOS `/dev/cu.usbmodem*`.

## Power rails (batteri — ADR 013)

```
USB-C-forlænger (kanten) ─────────────────────→ TP4056 USB-C ──┐
Qi-modtager 5V ──→ 1N5817 (katode mod TP4056) ──→ TP4056 IN+ ───┤
                                                                ↓
          TP4056-modul (580 mA: R3 = 2,0kΩ) + DW01A/FS8205A-beskyttelse
             B+/B- ──→ 2× 18650 parallelt (1S2P, 3,0-4,2V)
             OUT+/OUT- ──→ systemet (alt herunder; aldrig direkte på cellerne)

OUT+ ──┬──→ 1N5817 ──→ H2-Zero 5V-pin ──→ boardets LDO (ME6217) ──→ 3V3
       │    (dioden forhindrer at USB 5V fødes baglæns ind i batteriet,
       │     hvis Zero'ens USB-C sættes i under programmering)
       ├──→ switch A (P-FET, GPIO22) ──→ boost 12V (Pololu U3V40F12) ──→ pumpe
       └──→ MAX17048 VDD (fuel gauge, 3 µA i hibernate; SDA/SCL på I2C-bussen)

H2-Zero 3V3 ──→ switch B (P-FET, GPIO23) ──→ sensor-skinne: soil, Grove, SHT41
         └──→ HX711 (power-down via SCK), float switch (intern pull-up)
```

**Hvorfor skifte boostens input?** En boost-converter trækker mA i tomgang og
sender Vbat − diodefald videre, selv når den er "disabled" via EN — pumpen
ville sive. Switch A afbryder den helt.

**Hvorfor skifte sensorerne?** Soil-sensoren trækker ~5 mA konstant. SHT41
ligger på samme skinne som Grove-sensoren, fordi de deler I2C: hvis kun den
ene var slukket, ville pull-ups'ene føde den gennem SDA/SCL.

Sensorer kører på 3.3V (fra Zero'ens 3V3-pin), IKKE batterispænding.

**Lav-batteri:** dioden (~0,3V) + LDO'en betyder at 3V3 falder under
ESP32-H2's minimum (3,0V) ved ~3,3-3,4V batteri. Firmwaren advarer ved 3,5V.
På det færdige PCB (MINI-1-modul) erstattes dioden af en ideel-diode/
power-path, så hele cellens kapacitet kan bruges.

## Komplet wiring

```
Switch A — high-side, pumpe (Vbat > 3.3V → kræver N-FET-driver)

  OUT+ ──┬──────────── source ┐
         │                    │ AO3401A (P-FET)
       100kΩ          gate ───┤
         │             │      │ drain ──→ U3V40F12 VIN ──→ 12V ──→ pumpe +
         └─────────────┘                 U3V40F12 GND ──→ GND     pumpe − ──→ GND
                       │                 (1N5817 over pumpen: katode mod +)
                 2N7002 drain
  GPIO22 ──[10kΩ til GND]── 2N7002 gate
                 2N7002 source ──→ GND

Switch B — high-side, sensorer (source = 3V3 = GPIO-niveau → direkte drev)

  3V3 ──┬──── source ┐
      100kΩ          │ AO3401A
        │    gate ───┤
  GPIO23 ┴────┘       │ drain ──→ sensor-skinne (3V3_SW)

ESP32-H2-Zero (pot/)
  3V3_SW ──→ Soil sensor VCC
          → Grove water level VCC (3.3V)
          → SHT41 VCC
  3V3 ────→ HX711 VCC (power-down mellem målinger)
          → Float switch (en side; anden side til GPIO)

  GND ──→ All sensor GNDs (shared ground)

  GPIO0 ──→ Piezo buzzer
  GPIO1 (ADC) ──→ Soil sensor AOUT
  GPIO2 ──→ Float switch (intern pull-up, switch til GND when wet)
  GPIO3 ──→ (fri)
  GPIO4 (SDA) ──→ SHT41 + Grove SDA  (pull-ups på breakouts → 3V3_SW)
  GPIO5 (SCL) ──→ SHT41 + Grove SCL
  GPIO10 ──→ HX711 SCK
  GPIO11 ──→ HX711 DOUT
  GPIO12 ──→ Manual button (internal pull-up, switch til GND)
  GPIO22 ──→ Switch A driver (HIGH = pumpe on)
  GPIO23 ──→ Switch B gate (LOW = sensorer on)
```

**Firmware-rækkefølge ved måling:** GPIO23 LOW → vent ~5 ms (SHT41 opstart, max 1 ms + Grove) →
init I2C → mål → sæt SDA/SCL til input → GPIO23 HIGH. Bussen må ikke drives,
mens skinnen er slukket.

## SHT41 (environmental sensor) detaljer — ADR 015

```
SHT41-breakout (Adafruit 5776 eller generisk "GY-SHT41")
  ┌───────────────┐
  │ VCC ──→ 3V3_SW │ (pot/: switch B; orkide: 3V3 — 80 nA i hvile)
  │ GND ──→ GND    │
  │ SDA ──→ GPIO4  │ (pull-up til samme forsyning som VCC)
  │ SCL ──→ GPIO5  │
  └───────────────┘
```

**I2C-adresse:** 0x44 (SHT41-AD1B) — ingen konflikt med Grove (0x77/0x78).
**Måling:** kommando 0xFD → vent 10 ms → læs 6 bytes (T + CRC, RH + CRC).
CRC-8 poly 0x31, init 0xFF ([Sensirion SHT4x-datablad](https://cdn.sparkfun.com/assets/d/5/f/d/6/SHT40_Datasheet.pdf)).
**Varmer:** 0x39 = 200 mW i 1 s + måling. Bruges til at genoprette sensoren
efter lang tid ved høj luftfugtighed — max 5% duty cycle.
**Pull-ups:** De fleste breakouts har 10kΩ. Mangler de, tilføj 4.7kΩ.
**Placering:** et sted i bay/ebase hvor luften kan cirkulere — IKKE over
boost-converteren eller TP4056 (varme under pumpning/ladning).

## MAX17048 (batteriniveau) detaljer — ADR 016

```
MAX17048-breakout (fx Adafruit 5580)
  ┌────────────────┐
  │ VDD/BAT+ ──→ TP4056 OUT+ │ (forsynes og måler direkte fra cellen)
  │ GND      ──→ GND         │
  │ SDA      ──→ GPIO4       │ (fælles bus)
  │ SCL      ──→ GPIO5       │
  └────────────────┘
```

**I2C-adresse:** 0x36. **Registre:** VCELL 0x02 (78,125 µV/LSB), SOC 0x04
(1/256 %/LSB). **Skriv aldrig MODE.EnSleep = 1:** i pot/ slukkes bussens
pull-ups sammen med sensor-skinnen, og med EnSleep sat ville lave SDA/SCL
(> 2,5 s) stoppe målingen. Breakoutets egne pull-ups (hvis det har dem)
skal gå til 3V3_SW, ikke til batteriet.

## Water level-sensor (Seeed Grove 10cm) detaljer

Deler I2C-bussen med SHT41 — ingen ekstra GPIO.

```
Grove Water Level Sensor 10cm (101020635) — 4-pin Grove-stik
  ┌─────────────┐
  │ VCC ──→ 3V3_SW│ (switch B)
  │ GND ──→ GND │
  │ SDA ──→ GPIO4 │ (samme bus som SHT41)
  │ SCL ──→ GPIO5 │
  └─────────────┘
```

**I2C adresser:** 0x77 (nederste 8 pads) + 0x78 (øverste 12 pads) — ingen konflikt med SHT41 (0x44).
**Kabel:** sensoren sidder i reservoiret (270°); kablet løber op ad refill-kanalen, over flangen og ned udvendigt til M12-glanden ved 90° — ca. 0.5-0.6m. Brug skærmet 4-leder kabel. Bliver bussen ustabil på den længde: sænk I2C-clock til 50 kHz eller stram pull-ups til 2.2kΩ.

## HX711 detaljer

```
HX711 modul
  ┌─────────────┐
  │ VCC ──→ 3.3V│
  │ GND ──→ GND │
  │ DT  ──→ GPIO11│ (DOUT — data line, ESP læser herfra)
  │ SCK ──→ GPIO10│ (clock — ESP styrer)
  │             │
  │ E+ ──→ Load cell rød   │
  │ E- ──→ Load cell sort  │
  │ A+ ──→ Load cell hvid  │ (eller grøn afhængig af model)
  │ A- ──→ Load cell grøn  │ (eller hvid)
  └─────────────┘
```

Hvis load cell-aflæsning er negativ ved positiv vægt: swap A+ og A- ledninger.

## Float switch wiring

Float switch er normalt NO (Normally Open) når op (vand tilstede), CLOSED når nede (vand tom).

```
Float switch wire 1 ──→ GPIO2
Float switch wire 2 ──→ GND
GPIO2 har INTERNAL pull-up enabled in firmware
→ Switch closed (vand tom) = GPIO LOW = ISR triggered
→ Switch open (vand tilstede) = GPIO HIGH = OK
```

## Breadboard-test (før PCB)

Ingen stripboard: de elektriske ubekendte måles på breadboard, og derefter
går vi direkte til et første carrier-PCB (moduler på headers, switches og
passive komponenter på printet) — langtidstesten i potten sker med det.

1. ESP32-H2-Zero på breadboardet (aflod RGB-LED'en først)
2. Switch A + B (AO3401A/2N7002 på SOT-23-adaptere) og boost-modulet
   — test først med laboratorieforsyning 3,7V i stedet for cellerne
3. SHT41-breakout direkte på breadboardet
4. Sensorer via jumperkabler (JST-pigtails først når PCB'et er klar)
5. Pumpe til boostens 12V-udgang

**Hvad breadboardet skal afklare (påvirker PCB-skemaet):**
- [ ] Hvilestrøm for hele systemet som Matter-ICD (mål: < 1 mA i snit),
      inkl. Zero-boardets LDO — afgør om PCB'et skal have power-path
- [ ] Pumpens startstrøm gennem boost og TP4056/DW01 (udløser beskyttelsen?)
- [ ] XKC: ser den vand gennem 4mm PETG, og hvilken polaritet har udgangen?
- [ ] Qi-ladning gennem 1,2mm gulv på MagSafe-laderen (strøm, varme)
- [ ] Støj på batteri-/soil-ADC og I2C, mens pumpen kører
- [ ] MAX17048: VCELL mod multimeter (datablad: ±7,5 mV ved 3,6 V) og SOC plausibel

For v2 custom PCB (senere): KiCad schematic baseret på dette diagram. Allerede planlagt i `pot/hardware/schematic/`.

## Console / debug

Console output (`ESP_LOGI`, printf, etc.) går via **USB-CDC** (samme USB-C kabel som programmering). På macOS:
```bash
# Find serial port
ls /dev/cu.usbmodem*

# Open monitor
pio device monitor
```

Hvis du vil bruge UART i stedet (fx ekstern USB-UART-konverter): sæt `CONFIG_ESP_CONSOLE_UART_DEFAULT=y` i sdkconfig.defaults. UART0 sidder på GPIO23/24 — GPIO23 er switch B (pot/) / float fuld (orkide), så det kræver et kompromis.

## ESD/safety notes

- Ingen 230V AC — USB-C-laderen håndterer alt mains-side.
- Li-ion: brug altid beskyttelsesprintet (over-/underspænding, kortslutning). Celler med loddefaner — lod aldrig direkte på en celle uden.
- Pumpe 12V og GPIO 3.3V er på samme GND. Boost-start trækker en strømspids fra batteriet — placér 100µF elko ved boostens input og 10µF ved Zero'ens 5V-pin.
- Sensor-kabler op til ~50cm bør være shielded eller twisted pair for at undgå ADC-støj fra pumpe-switching.
- I2C-kabler til SHT41 holdes korte (<20cm); ellers tilføj stærkere pull-ups (2.2kΩ).
