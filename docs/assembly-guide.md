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

Alle dele er vinkel-indekserede (se [ADR 009](decisions/009-zero-penetration-overflow.md)
og [ADR 010](decisions/010-scalloped-cup-channels.md)). Cuppen har 3
service-kanaler i kanten; reservoir-væggens strip-ribber passer kun i den
brede refill-kanal, så cuppen kan kun sænkes ned i én rotation:

- **0°**: USB-C-lomme uden på reservoiret under et hak i flangen; USB-C-gennemføring (Ø14) i ebase
- **90°**: KABEL-KANAL i cuppen, float-klips i bunden, kabel-gland i ebase
- **180°**: SLANGE-KANAL i cuppen (dyse-hul øverst i kanal-fladen), M16-gland i ebase
- **270°**: REFILL-KANAL i cuppen, water-strip mellem guide-ribberne på
  væggen, overflow-hul i reservoir-væggen under

## Samling (rækkefølge)

1. **Electronics base**: montér ESP32-H2-Zero (RGB-LED aflodet), switch-board, boost og batteriet (2× 18650 i vuggen på lid'et, ADR 013). Qi-modtagerens spole limes i lommen i lid'et (ferrit-siden opad). Pumpen skrues på lid'ets bosses (Kamoer på 46mm-hullerne / BP7 på 24mm-kvadratet). Skru lid på med 4× M3.
2. **Glands**: USB-C-forlængerens han-stik ind gennem Ø14-hullet ved 0° (tætnes med split-grommet/silikone), M12 ved 90° (sensor-kabler), M16 ved 180° (slanger).
3. **Reservoir** placeres oven på ebase med EPDM/O-ring i gasket-grooven.
4. **Float switch** klipses i ringen ved 90°; kablet føres op ad kabel-kanalen.
5. **Water-strip** skubbes ned mellem guide-ribberne ved 270° (i refill-kanalen); kabel op ad samme kanal og over i kabel-kanalen via flangen.
6. **Sugeslange**: én ende med lille vægt/sinker ned i vand-zonen (gennem slange-kanalen), anden ende op ad kanalen → udvendigt ned → M16 → pumpe-indgang.
7. **Trykslange**: fra pumpe-udgang → M16 → op udvendigt → ned i slange-kanalen → ind i dyse-hullet øverst i kanal-fladen.
8. **Kabler** (soil, strip, float): op ad kabel-kanalen (90°) → ned udvendigt → M12 ved 90°.
9. **USB-C hun-ende**: trykkes ned i lommen ved 0° (kablet i slidsen forneden) → stikket flugter med rimmen og nås gennem hakket i flangen. Sæt støvproppen i.

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
4. Sænk cuppen i reservoiret — **drej til refill-kanalen (den brede) glider
   ned over strip-ribberne** (der er kun én orientering der passer)
5. Fyld vand gennem refill-åbningen (270°) til buzzeren dobbelt-bipper
   — eller til der drypper fra overflow-hullet (så er den HELT fuld; stop)

## Kalibrering

Følg [calibration.md](calibration.md) — bemærk at water-level-sensorens
100%-punkt måles ved **overflow-niveau** (fyld til det drypper, vent til
dryppet stopper, kalibrér).

## Fotos

*TODO Fase 2/3: indsæt fotos af hver samlings-trin.*
