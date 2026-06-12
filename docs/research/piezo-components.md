# Research: Piezo-komponenter i GreenThumbs

**Status:** Research-note med konklusioner. Skrevet 2026-06-12.

## Spørgsmålet

Er der noget at hente med piezo-komponenter — strømbesparelse, energi, eller QoL (støj) — i en plantekrukke der står i en bolig?

## 1. Piezo-pumpe (alternativ til peristaltisk)

### Data (Bartels mikropumper, markedets standard)

| Parameter | Bartels BP7 (piezo) | Kamoer KPP (peristaltisk, vores valg) |
|---|---|---|
| Flow (vand) | 0–9 ml/min | ~30 ml/min |
| Effekt | **~50 mW** | ~3.6 W |
| Støj | Nær-lydløs ("low noise level") | Mekanisk klik, hørbart tæt på |
| Levetid | 5000 h | 500–2000 h (slange skiftes) |
| Drive | 250 V peak (kræver driver-modul) | 12V DC direkte (MOSFET) |
| Selvprimende | Ja (op til ~500 mbar) | Ja |
| Pris pumpe | **€57 (~425 DKK)** | ~150 DKK |
| Pris driver | mp-Lowdriver **€67 (~500 DKK)** | ~15 DKK (MOSFET + diode) |
| **Total** | **~925 DKK** | **~165 DKK** |

### Energi-analyse

Pumpe-energi i vores power-budget (Monstera, 50 ml/dag):

- Peristaltisk: 100 sek/dag @ 3.6 W = **0.10 Wh/dag**
- BP7 piezo: 333 sek/dag @ 0.05 W = **0.005 Wh/dag**

Besparelse: 0.095 Wh/dag. Til sammenligning bruger MCU'en 0.15–2.4 Wh/dag afhængig af mode. **Pumpen er allerede den mindste post i budgettet — besparelsen er irrelevant**, selv for batteridrift (forlænger 3S-pack runtime med <2%).

### Støj-analyse

Reel forskel: BP7 er praktisk taget lydløs, peristaltisk har hørbart klik. MEN pumpen kører ~100 sek/dag fordelt på 1-2 events. QoL-gevinsten er marginal for en krukke i stuen — og elektronik-kammeret + pyntepotten dæmper allerede.

**Undtagelse:** Soveværelse-placering hvor selv kortvarig natlig støj er uacceptabel. Her kan firmware i stedet bare time vandingen til dagtimer (gratis løsning).

### Konklusion: FRAVALGT i v1, men mount-forberedt

- 6× pris for marginal gevinst — peristaltisk forbliver v1-valget (ADR 001 står)
- **MEN**: `electronics_base` pump-mount designes med **dual-footprint** så en BP7 + mp-Lowdriver kan eftermonteres uden re-print (premium silent-upgrade)
- **pot-orchid (v2)**: BP7 er reelt interessant dér — soak-tray fyldes langsomt (lav-flow er fint), og præcis dosering + lydløshed passer godt. Noteret i [pot-orchid/design-notes.md](../../pot-orchid/design-notes.md)

## 2. Piezo buzzer (refill-indikator) — VALGT

Passiv piezo buzzer (~5 DKK) drives med PWM fra ESP32 LEDC. Bruges som feedback under reservoir-påfyldning og ved fejl-tilstande. Se [ADR 008](../decisions/008-refill-indicator-piezo.md).

- Strøm: ~10-20 mA kun mens den bipper (sekunder/uge) — negligibelt
- Passiv (PWM-drevet) frem for aktiv: tone-frekvens kan varieres (stigende pitch = stigende vandstand)
- Pin: D2 (GPIO2) — sidste frie GPIO

## 3. Piezo energy harvesting — AFVIST

Idéen: høste energi fra vibrationer (pumpe-drift?) via piezo-elementer.

Realitet: piezo harvesting leverer **µW-niveau** ved kontinuerte vibrationer. Vores pumpe kører 100 sek/dag. Høstet energi: nano-watt-timer. Ikke i nærheden af relevant for noget som helst i systemet. Droppet uden videre analyse.

## Kilder

- [Bartels BP7 hos Darwin Microfluidics](https://darwin-microfluidics.com/products/bartels-bp7-micropump/) (€57, specs)
- [mp-Lowdriver hos Darwin Microfluidics](https://darwin-microfluidics.com/products/mp-lowdriver-controller) (€67)
- [Bartels mp6/BP7 datasheet](https://bartels-mikrotechnik.de/wp-content/uploads/2025/06/Datasheet-mp6-series.pdf)
- [Bartels micropumps oversigt](https://bartels-mikrotechnik.de/micropumps/)
