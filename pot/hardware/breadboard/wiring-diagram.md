# Wiring Diagram — Plantekrukke v1 Breadboard Prototype

**Single source of truth** for pin-mapping mellem firmware og hardware. Hvis du ændrer pin-assignment her, opdater også `pot/firmware/src/main.cpp` pin-konstanter.

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

## Pin allocation

| XIAO pin | GPIO | Function | Tilslutning | Notes |
|----------|------|----------|-------------|-------|
| D0 | GPIO0 | ADC | Soil moisture sensor (AOUT) | Bruges af profil-system, kalibreres dry/wet |
| D1 | GPIO1 | ADC | Water level strip (AOUT) | DFRobot SEN0204 analog |
| D2 | GPIO2 | ADC | (Reserve — temperatur-sensor v2?) | |
| D3 | GPIO21 | GPIO ISR | Float switch | Internal pull-up; LOW = vand tomt |
| D4 | GPIO22 | GPIO | HX711 SCK (clock) | Bit-banged 2-wire |
| D5 | GPIO23 | GPIO | HX711 DOUT (data) | Bit-banged 2-wire |
| D6 | GPIO16 | UART TX | UART debug | Reserveret til serial monitor |
| D7 | GPIO17 | UART RX | UART debug | Reserveret til serial monitor |
| D8 | GPIO19 | GPIO | WS2812 LED data | Status indicator |
| D9 | GPIO20 | GPIO | Manuel knap | Internal pull-up; LOW = pressed |
| D10 | GPIO18 | GPIO PWM | Pump MOSFET gate | 0 = pump off, HIGH = pump on. PWM-capable for hastighedskontrol |

**Fri GPIO til v2:** D2 (ADC), evt. SDA/SCL hvis I2C-sensorer tilføjes.

## Power rails

```
USB-C 5V/PD ──→ ZY12PDN ──┬──→ 12V rail ──→ Pumpe (via MOSFET drain)
                          │
                          └──→ MP1584 ──→ 5V rail ──→ XIAO 5V pin
                                                    └──→ Sensorer (3.3V via XIAO 3V3-pin)

GND rail: alt deler GND fra ZY12PDN GND-pin.
```

**Vigtig**: Sensorer kører på 3.3V (fra XIAO 3V3-pin), IKKE 5V. Soil sensor og water-level strip er 3.3V-tolerante; HX711 modul ofte 5V-mærket men ESP32-C6 GPIO er 3.3V-only.

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
        → Float switch (en side; anden side til GPIO)

  GND ──→ All sensor GNDs (shared ground)

  D0 (ADC) ──→ Soil sensor AOUT
  D1 (ADC) ──→ Water level strip AOUT
  D3 ──→ Float switch (via 10kΩ pull-up til 3.3V, switch til GND when wet)
  D4 ──→ HX711 SCK
  D5 ──→ HX711 DOUT
  D8 ──→ WS2812 DIN
  D9 ──→ Manual button (internal pull-up, switch til GND)
  D10 ──→ MOSFET gate (via 10kΩ pulldown til GND)
```

## HX711 detaljer

```
HX711 modul
  ┌─────────────┐
  │ VCC ──→ 3.3V│
  │ GND ──→ GND │
  │ DT  ──→ D5  │ (DOUT — data line, ESP læser herfra)
  │ SCK ──→ D4  │ (clock — ESP styrer)
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
3. Sensorer via JST-XH connectors (laver pigtail kabel: JST → male jumper pins)
4. Pumpe direkte til breadboard 12V rail med skrue-terminaler eller solid wire

For v2 custom PCB (senere): KiCad schematic baseret på dette diagram. Allerede planlagt i `pot/hardware/schematic/`.

## ESD/safety notes

- Ingen 230V AC i selve pot-elektronikken — USB-C adapter håndterer alt mains-side.
- Pumpe 12V og GPIO 3.3V er på samme GND men galvanisk uadskilte. MOSFET-switching kan injicere støj — placér 100µF elko ved MP1584 input/output, og 10µF tæt på XIAO 5V pin.
- Sensor-kabler op til ~50cm bør være shielded eller twisted pair for at undgå ADC-støj fra pumpe-switching.
