# ADR 001 — Peristaltisk pumpe til vanding

**Status:** Accepted
**Dato:** 2026-05-27

## Context

Plantekrukken skal levere præcis vanddosering i området **5–100 ml** (succulenter til Monstera).
Pumpen skal være:
- Stille (krukken står i stuen)
- Pålidelig over uger/måneder uden tilsyn
- Tolerant overfor tør-kørsel (hvis vandreservoir tømmes før software fanger det)
- Hygiejnisk (ingen alge-vækst direkte i pumpen)

## Decision

Vi bruger en **peristaltisk 12V DC pumpe** (Kamoer KPP eller tilsvarende generisk, ~30 ml/min) drevet via N-channel logic-level MOSFET (IRLB8721) fra ESP32-C6 GPIO.

## Consequences

### Positive

- **Selv-primende**: ingen luft-låse i slangen efter længere stilstand.
- **Dry-run tolerant**: pumpen tager ikke skade af at køre tør (i modsætning til submersible pumper hvor rotoren brænder af uden vand-køling).
- **Vand rører ikke pumpe-mekanikken**: kun en silikoneslange. Eliminerer alger, kalk og vandkemiske angreb. Slangen kan udskiftes uden at åbne pumpehuset.
- **Præcis dosering**: ml/sek er lineær over hele driftsområdet, så simpel kalibrering (kør 10 sek, vej output) giver præcise doseringer ned til ~3 ml.
- **Lavt vandtryk**: behøver ingen tryk-regulator eller solenoid-ventil.

### Negative

- **Højere pris**: ~150 DKK vs ~25-50 DKK for en submersible mini-pumpe.
- **Mekanisk slid**: silikoneslangen i pumpehuset slides over tid (500-2000 timers levetid). Skal udskiftes periodisk — typisk hvert 1-2 år ved vores driftscyklus.
- **Lidt mekanisk klik-støj** mens den kører. Acceptabelt ved 100 sek/dag driftstid.

### Alternativer overvejet

- **Submersible mini-pumpe 5V (~25 DKK)**: forkastet pga. dry-run risiko (kritisk for ubevogtet drift) og direkte vandkontakt → alger/kalk.
- **Solenoid-ventil + tyngdekraft-fed reservoir**: forkastet fordi det kræver reservoir over plantens niveau, hvilket modarbejder "kompakt krukke der bor i pyntepotte"-konceptet.

## Implementation notes

- MOSFET-gate har 10kΩ pull-down for at sikre OFF ved boot.
- 1N5819 Schottky flyback-diode over pumpe-terminaler.
- Pumpe-strøm målt med multimeter ved kalibrering (forventet ~300 mA @ 12V).
- Kalibreringskonstant `pump_ml_per_sec` gemmes i NVS efter første opstart.
