# ADR 008 — Refill-indikator via piezo buzzer

**Status:** Accepted
**Dato:** 2026-06-12

## Context

Krukken står inde i en pyntepotte — elektronikken (inkl. WS2812 status-LED) er skjult. Når brugeren fylder reservoiret via refill-åbningen, er der ingen feedback om hvornår det er fuldt. Risiko: overfyldning (vand løber over notch-kanten) eller unødigt hyppige små påfyldninger.

HomeKit-appen viser vandstand, men at stå med en vandkande i én hånd og en iPhone i den anden er dårlig UX. Vi har allerede en kapacitiv water level strip der måler kontinuert — vi mangler kun en lokal feedback-kanal.

## Decision

**Passiv piezo buzzer på D2 (GPIO2), drevet med PWM via ESP32 LEDC.**

Firmware-flow (implementeres i Fase 1):

1. `sensor_task` detekterer **refill-mode**: vandstand stiger >5 procentpoint inden for 10 sek
2. I refill-mode: kort beep ved hver 25%-milepæl (25/50/75%) — stigende tone-pitch med vandstand
3. Ved ≥95%: **dobbelt-beep** = "stop påfyldning"
4. Refill-mode forlades når vandstand har været stabil i 30 sek

Buzzeren genbruges desuden til fejl-signalering:
- Lav buzz (200 Hz, 1 sek) ved profil/hardware-mismatch (fx orkide-profil uden load cell, ADR 004)
- Tre korte beeps ved float-switch low-water alarm (suppleret af HomeKit-notifikation)

## Consequences

### Positive

- **Hands-free refill-UX**: brugeren hælder vand og lytter — ingen app, ingen synskontakt med skjult elektronik
- **Billigt**: ~5 DKK, én GPIO, intet CAD-arbejde (buzzer sidder i electronics base; lyd slipper ud gennem cable gland-åbninger og pyntepotte)
- **Passiv buzzer + PWM** giver tone-kontrol (pitch-stigning = intuitivt "snart fuldt"-signal)
- Genbrugelig fejl-kanal for alle alarm-tilstande

### Negative

- **D2 er ikke længere reserve**: pin-budgettet på XIAO ESP32-C6 er nu 100% allokeret. Næste sensor (fx DS18B20 vand-temp) kræver I2C-expander eller pin-deling.
- Lydstyrke gennem pyntepotte skal valideres i Fase 3 (mitigation: lydhul i electronics base-væg hvis for dæmpet)
- Buzzer-lyd kan være irriterende — derfor KUN aktiv i refill-mode og ved fejl, aldrig periodisk

### Alternativer overvejet

- **LED light pipe** (transparent stav fører WS2812-lys op til synlig kant): lydløs, men kræver CAD-ændring + synligt element. Noteret som v1.1 CAD-TODO i [pot/cad/source/README.md](../../pot/cad/source/README.md) — kan supplere buzzeren senere.
- **Kun HomeKit**: forkastet som primær (dårlig hands-free UX), men fungerer som sekundær kanal.
- **Aktiv buzzer** (fast frekvens, simplere drive): forkastet — passiv giver pitch-variation for samme pris.

## Implementation notes

- Pin: D2 / GPIO2 (PWM-capable via LEDC)
- Driver: LEDC channel, 50% duty, frekvens 1-4 kHz for beeps (resonans for små piezo-discs ligger typisk ~2-4 kHz)
- API i `pot/firmware/src/buzzer.h`: `buzzer_init()`, `buzzer_beep(freq_hz, duration_ms)`, `buzzer_pattern(BUZZ_REFILL_PROGRESS | BUZZ_REFILL_FULL | BUZZ_ERROR | BUZZ_LOW_WATER)`
- Buzzer monteres med lydåbning vendt mod en cable gland / ventilations-åbning
- BOM: position 28, generic 12mm passiv piezo disc/buzzer, AliExpress/Conrad
