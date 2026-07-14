# Assembly Guide — Plantekrukke v1

**Status:** Skelet — udfyldes med fotos under Fase 2/3 (mekanisk prototype + integration).

## Del-oversigt

| Del | Print-fil | Materiale | Note |
|---|---|---|---|
| Plant cup (S/M/L) | `plant_cup.scad` | PETG | Vælg størrelse efter plante |
| Reservoir | `reservoir.scad` | PETG | Højde følger cup-størrelse |
| Electronics base | `electronics_base.scad` | PETG | 40% infill |
| Electronics lid | `electronics_base.scad` (lid-modul) | PETG/PLA | Pump-mount bosses på top |
| Load cell mount ×2 | `load_cell_mount.scad` (render_mode="plate") | PLA/PETG | KUN til orkide/vægt-config |

## Vinkel-orientering (vigtig!)

Alle dele er vinkel-indekserede (se [ADR 009](decisions/009-zero-penetration-overflow.md)).
Reservoir-rimmens **4 tapper** (asymmetriske vinkler) griber op i lommer i
flangens underside — de både **centrerer** cuppen (ens ring-gab hele vejen
rundt) og låser rotationen, så cuppen kun kan sidde i én orientering:

- **0°**: water-strip mellem guide-ribberne, USB-C gland i ebase nedenunder
- **90°**: kabel-slids i flangen, float-klips i bunden, kabel-gland i ebase
- **180°**: slange-åbning i flangen, slange-gland (PG9) i ebase
- **270°**: refill-åbning i flangen, overflow-hul i reservoir-væggen under

## Samling (rækkefølge)

1. **Electronics base**: montér XIAO, MOSFET-board, buck, PD-trigger. Pumpen skrues på lid'ets bosses (Kamoer på 46mm-hullerne / BP7 på 24mm-kvadratet). Skru lid på med 4× M3.
2. **Glands**: PG7 ved 0° (USB-C) og 90° (sensor-kabler), PG9 ved 180° (slanger).
3. **Reservoir** placeres oven på ebase med EPDM/O-ring i gasket-grooven.
4. **Float switch** klipses i ringen ved 90°; kabel føres op langs indervæggen til ring-gabet.
5. **Water-strip** skubbes ned mellem guide-ribberne ved 0°; kabel op.
6. **Sugeslange**: én ende med lille vægt/sinker ned i vand-zonen (gennem ring-gab), anden ende gennem flangens 180°-åbning → udvendigt ned → PG9 → pumpe-indgang.
7. **Trykslange**: fra pumpe-udgang → PG9 → op udvendigt → gennem flangens 180°-åbning → ind i cup-toppens side-hul.
8. **Kabler** (soil, strip, float): op gennem ring-gab → læg i flangens kabel-slids (90°) → ned udvendigt → PG7 ved 90°.

## LECA-lag (VIGTIGT — beskytter mod vandlogging)

Læg **2-3 cm LECA-kugler (lerkugler) i bunden af plant cup** før jorden:

- Bryder kapillær kontakt hvis vandstanden kortvarigt når cup-bunden
- Forbedrer drænage fra top-vanding
- **Undtagelse**: wick-planter (African Violet m.fl.) — her skal wick'en gå
  gennem LECA-laget og godt op i selve jorden, ellers når kapillær-virkningen
  ikke rødderne

## Plantning

1. Træd wick gennem center-drænhullet hvis planten skal bottom-vandes (se [ADR 006](decisions/006-bottom-watering-strategies.md))
2. LECA-lag, derefter jord + plante
3. Stik soil-sensoren i jorden (elektronik-enden over jordniveau), kabel via flange-slidsen
4. Sænk cuppen i reservoiret — **drej til alle 4 rim-tapper falder i
   flange-lommerne** (der er kun én orientering der passer)
5. Fyld vand gennem refill-åbningen (270°) til buzzeren dobbelt-bipper
   — eller til der drypper fra overflow-hullet (så er den HELT fuld; stop)

## Kalibrering

Følg [calibration.md](calibration.md) — bemærk at water-strip'ens 100%-punkt
(`adc_full`) måles ved **overflow-niveau** (fyld til det drypper, vent til
dryppet stopper, kalibrér).

## Fotos

*TODO Fase 2/3: indsæt fotos af hver samlings-trin.*
