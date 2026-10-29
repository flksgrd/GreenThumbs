# ADR 016 — MAX17048 fuel gauge i stedet for spændingsdeler

**Status:** Accepted
**Dato:** 2026-10-29
**Erstatter:** batteri-ADC'en med 2× 200 kΩ deler (ADR 013 / ADR 014)

## Context

HomeKit viser batteriniveau i %. En spændingsdeler på en ADC-pin giver kun
cellespændingen, og Li-ion-spænding er en dårlig målestok for kapacitet:
kurven er flad i midten og falder, mens pumpen kører. Deleren trækker
desuden ~10 µA konstant (4,2 V / 400 kΩ).

MAX17048 ([datablad](https://cdn.sparkfun.com/assets/b/b/2/c/b/MAX17048.pdf)):
- ModelGauge: SOC uden strømmålemodstand; VCELL ±7,5 mV ved 3,6 V
- 23 µA aktiv, **3 µA hibernate** (vælges automatisk ved lav belastning)
- I2C 0x36; VCELL (0x02) 78,125 µV/LSB, SOC (0x04) 1/256 %/LSB
- VDD forbindes til cellens plus; SDA/SCL tåler op til 6 V

## Decision

**MAX17048-breakout på den fælles I2C-bus i begge versioner.** VDD fra
TP4056 OUT+. GPIO3 bliver fri.

pot/'s I2C-bus mister sine pull-ups, når sensor-skinnen er slukket. Det er
ufarligt: MAX17048 går kun i sleep ved lave SDA/SCL, hvis `MODE.EnSleep = 1`
— den skal firmwaren aldrig sætte. Måleren bliver ved med at følge
batteriet, og firmwaren læser den, når skinnen alligevel er tændt.

## Consequences
- Rigtig batteriprocent i HomeKit (Power Source-cluster) + cellespænding
- ~3 µA i stedet for ~10 µA konstant
- GPIO3 fri i begge versioner; I2C-adresser: MAX17048 0x36, SHT41 0x44,
  Grove 0x77/0x78 — ingen konflikter
- Firmware: `battery_gauge.*` — konverteringerne er testet native;
  I2C-kaldene implementeres i Fase 1
- ~40 DKK ekstra pr. enhed (skøn)
