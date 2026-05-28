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
| D1 | GPIO1 | ADC | Water level strip (AOUT) | DFRobot SEN0204 analog |
| D2 | GPIO2 | ADC | (Reserve — DS18B20 vand-temp v2?) | |
| D3 | GPIO21 | GPIO ISR | Float switch | Internal pull-up; LOW = vand tomt |
| D4 | GPIO22 | **I2C SDA** | **AHT20 SDA** | Standard I2C bus til environmental sensor |
| D5 | GPIO23 | **I2C SCL** | **AHT20 SCL** | Standard I2C bus |
| D6 | GPIO16 | GPIO | **HX711 SCK** (clock) | Flyttet fra UART TX — USB-CDC console nu i brug |
| D7 | GPIO17 | GPIO | **HX711 DOUT** (data) | Flyttet fra UART RX |
| D8 | GPIO19 | GPIO | WS2812 LED data | Status indicator |
| D9 | GPIO20 | GPIO | Manuel knap | Internal pull-up; LOW = pressed |
| D10 | GPIO18 | GPIO PWM | Pump MOSFET gate | 0 = pump off, HIGH = pump on. PWM-capable for hastighedskontrol |

**Fri GPIO til v2:** D2 (ADC), plus muligvis SPI hvis I2C-bussen deles med flere devices.

> **Vigtigt ændring fra tidligere wiring:** AHT20 environmental sensor blev tilføjet som standard v1-komponent (se [ADR 007](../../../docs/decisions/007-env-sensor-aht20.md)). Det krævede:
> - HX711 flyttet fra D4/D5 til D6/D7 (frigør I2C-bussen for AHT20)
> - UART TX/RX (D6/D7) er ikke længere i brug; ESP-IDF console er routet til **USB-CDC** via `CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y` i `sdkconfig.defaults`
> - Serial monitor virker stadig — bare via samme USB-C kabel som programmering. På macOS: `/dev/cu.usbmodem*`

## Power rails

```
USB-C 5V/PD ──→ ZY12PDN ──┬──→ 12V rail ──→ Pumpe (via MOSFET drain)
                          │
                          └──→ MP1584 ──→ 5V rail ──→ XIAO 5V pin
                                                    └──→ Sensorer (3.3V via XIAO 3V3-pin)

GND rail: alt deler GND fra ZY12PDN GND-pin.
```

**Vigtig**: Sensorer kører på 3.3V (fra XIAO 3V3-pin), IKKE 5V. Soil sensor, water-level strip, HX711, og AHT20 er alle 3.3V-tolerante (eller har on-board regulator).

## Komplet wiring

```
USB-C Adapter (≥30W PD)
    │ USB-C cable
    ↓
┌──────────────┐
│  ZY12PDN     │
│  PD trigger  │
│  (set 12V)   │
└──────────────┘
    │ 12V output     ┌──────────────┐
    ├────────────────┤   MP1584     │
    │                │   buck conv  │── 5V ──→ XIAO 5V pin
    │                │   12V→5V     │── GND ─→ XIAO GND
    │                └──────────────┘
    │
    │ 12V                                   ┌──── MOSFET drain
    └──────────────────────────────────────→│
                                            │  IRLB8721
    GPIO D10 ──[ 10kΩ pulldown to GND ]─────│  N-channel
                                            │
                                  source ───┴──── GND
                                            │
                                            │ Pump terminal +
                                            ↓
                                       ┌─────────┐
                                       │ Pump 12V│
                                       │  Kamoer │
                                       └─────────┘
                                            │ Pump terminal -
                                            ↓
                                           GND
                                       (+ 1N5819 diode i parallel,
                                        cathode mod +12V, anode mod GND-side)

XIAO ESP32-C6
  3V3 ──→ Soil sensor VCC
        → Water level strip VCC
        → HX711 VCC
        → AHT20 VCC
        → Float switch (en side; anden side til GPIO)

  GND ──→ All sensor GNDs (shared ground)

  D0 (ADC) ──→ Soil sensor AOUT
  D1 (ADC) ──→ Water level strip AOUT
  D3 ──→ Float switch (via 10kΩ pull-up til 3.3V, switch til GND when wet)
  D4 (SDA) ──→ AHT20 SDA   ←─[ 4.7kΩ pull-up til 3.3V ]─
  D5 (SCL) ──→ AHT20 SCL   ←─[ 4.7kΩ pull-up til 3.3V ]─
  D6 ──→ HX711 SCK
  D7 ──→ HX711 DOUT
  D8 ──→ WS2812 DIN
  D9 ──→ Manual button (internal pull-up, switch til GND)
  D10 ──→ MOSFET gate (via 10kΩ pulldown til GND)
```

## AHT20 (environmental sensor) detaljer

```
AHT20 modul (Adafruit 4566 eller AliExpress generic)
  ┌─────────────┐
  │ VCC ──→ 3.3V│
  │ GND ──→ GND │
  │ SDA ──→ D4  │ (med 4.7kΩ pull-up til 3.3V)
  │ SCL ──→ D5  │ (med 4.7kΩ pull-up til 3.3V)
  └─────────────┘
```

**I2C address:** 0x38 (fast)
**Pull-ups:** De fleste AHT20 breakout-boards har integrerede 10kΩ pull-ups på SDA/SCL. Hvis dit board IKKE har dem, tilføj 4.7kΩ resistorer til 3.3V på hver linje.
**Placering:** Mount AHT20 et sted i electronics base hvor luften kan cirkulere — IKKE direkte over MP1584 buck-converter (varm) eller ESP32 (varm). Helst ved siden af en cable gland så ekstern luft kan nå sensoren.

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
2. MOSFET, MP1584, ZY12PDN på samme breadboard
3. AHT20 breakout board direkte på breadboard (lille)
4. Sensorer via JST-XH connectors (laver pigtail kabel: JST → male jumper pins)
5. Pumpe direkte til breadboard 12V rail med skrue-terminaler eller solid wire

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

- Ingen 230V AC i selve pot-elektronikken — USB-C adapter håndterer alt mains-side.
- Pumpe 12V og GPIO 3.3V er på samme GND men galvanisk uadskilte. MOSFET-switching kan injicere støj — placér 100µF elko ved MP1584 input/output, og 10µF tæt på XIAO 5V pin.
- Sensor-kabler op til ~50cm bør være shielded eller twisted pair for at undgå ADC-støj fra pumpe-switching.
- AHT20 I2C-kabler holdes korte (<20cm); ellers tilføj stærkere pull-ups (2.2kΩ).
