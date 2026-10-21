# Wiring Diagram — Plantekrukke v1 Breadboard Prototype

**Single source of truth** for pin-mapping mellem firmware og hardware. Hvis du ændrer pin-assignment her, opdater også `pot/firmware/src/main.cpp` PIN_* konstanter.

## XIAO ESP32-C6 pinout reference

```
                ┌─────────────┐
        TX  D6 ─┤             ├─ D7  RX
        SDA D4 ─┤             ├─ D5  SCL
            D8 ─┤             ├─ D3
            D9 ─┤             ├─ D10
            5V ─┤             ├─ 3V3
           GND ─┤             ├─ D2  (ADC2)
            D0 ─┤             ├─ D1  (ADC1)
          (ADC0)              
                │   USB-C     │
                └─────────────┘
```

ADC-capable: D0 (ADC1_CH0), D1 (ADC1_CH1), D2 (ADC1_CH2)
Total brugbare GPIO: 11

## Pin allocation (v1 med AHT20)

| XIAO pin | GPIO | Function | Tilslutning | Notes |
|----------|------|----------|-------------|-------|
| D0 | GPIO0 | ADC | Soil moisture sensor (AOUT) | Bruges af profil-system, kalibreres dry/wet |
| D1 | GPIO1 | ADC | **Batteri-spænding** | 2× 200kΩ deler fra BAT+ (ADR 013) |
| D2 | GPIO2 | GPIO PWM | **Piezo buzzer** (passiv, LEDC-drevet) | Refill-indikator + fejl-signaler. Se ADR 008 |
| D3 | GPIO21 | GPIO ISR | Float switch | Internal pull-up; LOW = vand tomt |
| D4 | GPIO22 | **I2C SDA** | **AHT20 SDA** | Standard I2C bus til environmental sensor |
| D5 | GPIO23 | **I2C SCL** | **AHT20 SCL** | Standard I2C bus |
| D6 | GPIO16 | GPIO | **HX711 SCK** (clock) | Flyttet fra UART TX — USB-CDC console nu i brug |
| D7 | GPIO17 | GPIO | **HX711 DOUT** (data) | Flyttet fra UART RX |
| D8 | GPIO19 | GPIO | **Sensor-skinne** (switch B) | LOW = sensorer tændt (P-FET gate). Soil + Grove + AHT20 slukkes mellem målinger |
| D9 | GPIO20 | GPIO | Manuel knap | Internal pull-up; LOW = pressed |
| D10 | GPIO18 | GPIO | **Pumpe** (switch A → boost) | HIGH = boost + pumpe tændt. 10kΩ pulldown → slukket under boot |

**Ingen frie GPIO** (WS2812 er droppet, D1/D8 bruges til batteri — ADR 013). I2C-bussen (D4/D5) deles af AHT20 (0x38) og Grove water level-sensoren (0x77 + 0x78) — flere I2C-devices kan tilføjes uden at bruge pins.

> **Vigtigt ændring fra tidligere wiring:** AHT20 environmental sensor blev tilføjet som standard v1-komponent (se [ADR 007](../../../docs/decisions/007-env-sensor-aht20.md)). Det krævede:
> - HX711 flyttet fra D4/D5 til D6/D7 (frigør I2C-bussen for AHT20)
> - UART TX/RX (D6/D7) er ikke længere i brug; ESP-IDF console er routet til **USB-CDC** via `CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y` i `sdkconfig.defaults`
> - Serial monitor virker stadig — bare via samme USB-C kabel som programmering. På macOS: `/dev/cu.usbmodem*`

## Power rails (batteri — ADR 013)

```
USB-C-forlænger (kanten) ───────────────────→ XIAO USB-C ──┐
Qi-modtager 5V ──→ 1N5819 (katode mod XIAO) ──→ XIAO 5V-pin ─┤
                                                            ↓
              XIAO ESP32-C6 (indbygget Li-ion-lader, 100 mA, BAT+/BAT- pads)
                 │
              1S-beskyttelsesprint (DW01A + FS8205A)
                 │
              2× 18650 parallelt (1S2P, 3,0-4,2V)

BAT+ ──┬──→ switch A (P-FET, D10) ──→ boost 12V (Pololu U3V40F12) ──→ pumpe
       └──→ 200k ─┬─ 200k ──→ GND
                  └──→ D1 (batteri-ADC, 100nF til GND)

XIAO 3V3 ──→ switch B (P-FET, D8) ──→ sensor-skinne: soil, Grove, AHT20
         └──→ HX711 (power-down via SCK), float switch (intern pull-up)
```

**Hvorfor skifte boostens input?** En boost-converter trækker mA i tomgang og
sender Vbat − diodefald videre, selv når den er "disabled" via EN — pumpen
ville sive. Switch A afbryder den helt.

**Hvorfor skifte sensorerne?** Soil-sensoren trækker ~5 mA konstant. AHT20
ligger på samme skinne som Grove-sensoren, fordi de deler I2C: hvis kun den
ene var slukket, ville pull-ups'ene føde den gennem SDA/SCL.

Sensorer kører på 3.3V (fra XIAO 3V3-pin), IKKE batterispænding.

## Komplet wiring

```
Switch A — high-side, pumpe (Vbat > 3.3V → kræver N-FET-driver)

  BAT+ ──┬──────────── source ┐
         │                    │ AO3401A (P-FET)
       100kΩ          gate ───┤
         │             │      │ drain ──→ U3V40F12 VIN ──→ 12V ──→ pumpe +
         └─────────────┘                 U3V40F12 GND ──→ GND     pumpe − ──→ GND
                       │                 (1N5819 over pumpen: katode mod +)
                 2N7002 drain
  D10 ──[10kΩ til GND]── 2N7002 gate
                 2N7002 source ──→ GND

Switch B — high-side, sensorer (source = 3V3 = GPIO-niveau → direkte drev)

  3V3 ──┬──── source ┐
      100kΩ          │ AO3401A
        │    gate ───┤
  D8 ───┴────┘       │ drain ──→ sensor-skinne (3V3_SW)

XIAO ESP32-C6
  3V3_SW ──→ Soil sensor VCC
          → Grove water level VCC (3.3V)
          → AHT20 VCC
  3V3 ────→ HX711 VCC (power-down mellem målinger)
          → Float switch (en side; anden side til GPIO)

  GND ──→ All sensor GNDs (shared ground)

  D0 (ADC) ──→ Soil sensor AOUT
  D1 (ADC) ──→ Batteri-deler (midtpunkt)
  D2 ──→ Piezo buzzer
  D3 ──→ Float switch (intern pull-up, switch til GND when wet)
  D4 (SDA) ──→ AHT20 + Grove SDA  (pull-ups på breakouts → 3V3_SW)
  D5 (SCL) ──→ AHT20 + Grove SCL
  D6 ──→ HX711 SCK
  D7 ──→ HX711 DOUT
  D8 ──→ Switch B gate (LOW = sensorer on)
  D9 ──→ Manual button (internal pull-up, switch til GND)
  D10 ──→ Switch A driver (HIGH = pumpe on)
```

**Firmware-rækkefølge ved måling:** D8 LOW → vent ~50 ms (AHT20 opstart) →
init I2C → mål → sæt SDA/SCL til input → D8 HIGH. Bussen må ikke drives,
mens skinnen er slukket.

## AHT20 (environmental sensor) detaljer

```
AHT20 modul (Adafruit 4566 eller AliExpress generic)
  ┌─────────────┐
  │ VCC ──→ 3V3_SW│ (switch B)
  │ GND ──→ GND │
  │ SDA ──→ D4  │ (med 4.7kΩ pull-up til 3V3_SW)
  │ SCL ──→ D5  │ (med 4.7kΩ pull-up til 3V3_SW)
  └─────────────┘
```

**I2C address:** 0x38 (fast)
**Pull-ups:** De fleste AHT20 breakout-boards har integrerede 10kΩ pull-ups på SDA/SCL. Hvis dit board IKKE har dem, tilføj 4.7kΩ resistorer til 3.3V på hver linje.
**Placering:** Mount AHT20 et sted i electronics base hvor luften kan cirkulere — IKKE direkte over boost-converteren (varm under pumpning) eller ESP32. Helst ved siden af en cable gland så ekstern luft kan nå sensoren.

## Water level-sensor (Seeed Grove 10cm) detaljer

Deler I2C-bussen med AHT20 — ingen ekstra GPIO.

```
Grove Water Level Sensor 10cm (101020635) — 4-pin Grove-stik
  ┌─────────────┐
  │ VCC ──→ 3V3_SW│ (switch B)
  │ GND ──→ GND │
  │ SDA ──→ D4  │ (samme bus som AHT20)
  │ SCL ──→ D5  │
  └─────────────┘
```

**I2C adresser:** 0x77 (nederste 8 pads) + 0x78 (øverste 12 pads) — ingen konflikt med AHT20 (0x38).
**Kabel:** sensoren sidder i reservoiret (270°); kablet løber op ad refill-kanalen, over flangen og ned udvendigt til M12-glanden ved 90° — ca. 0.5-0.6m. Brug skærmet 4-leder kabel. Bliver bussen ustabil på den længde: sænk I2C-clock til 50 kHz eller stram pull-ups til 2.2kΩ.

## HX711 detaljer

```
HX711 modul
  ┌─────────────┐
  │ VCC ──→ 3.3V│
  │ GND ──→ GND │
  │ DT  ──→ D7  │ (DOUT — data line, ESP læser herfra)
  │ SCK ──→ D6  │ (clock — ESP styrer)
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
Float switch wire 1 ──→ GPIO D3
Float switch wire 2 ──→ GND
D3 har INTERNAL pull-up enabled in firmware
→ Switch closed (vand tom) = GPIO LOW = ISR triggered
→ Switch open (vand tilstede) = GPIO HIGH = OK
```

## Til prototype-fase

For v1 breadboard:
1. XIAO på 0.1" header → breadboard
2. Switch A + B (AO3401A/2N7002 på SOT-23-adaptere) og boost-modulet på samme breadboard
   — test først med laboratorieforsyning 3,7V i stedet for cellerne
3. AHT20 breakout board direkte på breadboard (lille)
4. Sensorer via JST-XH connectors (laver pigtail kabel: JST → male jumper pins)
5. Pumpe til boostens 12V-udgang med skrue-terminaler
6. Mål hvilestrømmen med alt slukket (mål: < 1 mA i snit som Matter-ICD) — afgør batteritiden

For v2 custom PCB (senere): KiCad schematic baseret på dette diagram. Allerede planlagt i `pot/hardware/schematic/`.

## Console / debug

Console output (`ESP_LOGI`, printf, etc.) går via **USB-CDC** (samme USB-C kabel som programmering). På macOS:
```bash
# Find serial port
ls /dev/cu.usbmodem*

# Open monitor
pio device monitor
```

Hvis du af en eller anden grund vil bruge UART i stedet (fx ekstern USB-UART konverter): sæt `CONFIG_ESP_CONSOLE_UART_DEFAULT=y` i sdkconfig.defaults og flyt HX711 til andre pins (men D2 og D9 er allerede taget — så det kræver kompromis).

## ESD/safety notes

- Ingen 230V AC — USB-C-laderen håndterer alt mains-side.
- Li-ion: brug altid beskyttelsesprintet (over-/underspænding, kortslutning). Celler med loddefaner — lod aldrig direkte på en celle uden.
- Pumpe 12V og GPIO 3.3V er på samme GND. Boost-start trækker en strømspids fra batteriet — placér 100µF elko ved boostens input og 10µF tæt på XIAO'ens BAT-pads.
- Sensor-kabler op til ~50cm bør være shielded eller twisted pair for at undgå ADC-støj fra pumpe-switching.
- AHT20 I2C-kabler holdes korte (<20cm); ellers tilføj stærkere pull-ups (2.2kΩ).
