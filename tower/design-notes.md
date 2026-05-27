# Tower Design Notes

**Status:** Initiel design — bliver opdateret løbende mens vi lærer fra plantekrukke-prototypen.

Dette dokument samler designvalg, åbne spørgsmål, og lessons learned der akkumuleres under v1-arbejdet. Når v1 er færdig, vil dette være grundlag for v2-implementering.

---

## Brugerkrav (fra projektopstart)

- **Vægmonteret** — frigør gulvplads
- **Modificeret "3D Printed Hydroponic Tower Garden"**-koncept
- **Stille og automatisk**
- **Beholder med vand i bunden** — ikke ofte genopfyldning
- **Nemt at fylde**: tragt eller åbning i top
- **Water meter sensor** + **gennemsigtigt vindue** til fysisk vand-inspektion
- **Stille pumpe** (akvarie-type)
- **Stikkontakt-baseret** (batteri er ikke krav)
- **Krydderurter** primært, **leafy greens** sekundært

---

## Designvalg (foreløbige)

### Hydroponic-metode

**Foreløbig beslutning:** Vertical drip → drain-and-recirculate.

Vand pumpes fra reservoir op til top → drypper ned gennem plant slots → falder tilbage i reservoir.

| Metode | Pro | Contra |
|---|---|---|
| **Vertical drip (chosen)** | Simpel, ingen kontinuerlig waterflow, nem rens | Risiko for tørre rødder mellem cyklus |
| NFT (Nutrient Film Technique) | Effektivt, lavt vandforbrug | Kontinuerlig pumpedrift, fragmenteres ved strømsvigt |
| DWC (Deep Water Culture) | Rødder altid i vand | Tungt, kræver air-pump for ilt → mere støj |
| Aeroponics | Højeste yield | Mest komplekst, dyrt, tilstoppes |

Beslutning baseres på: stille drift (peristaltisk impossible i denne skala — kræver submersible), og forgivende mht. tørke-tolerance (krydderurter klarer korte tørke).

### Antal plante-slots

**Foreløbig:** 5-7 slots. Hver slot er et standard 2" net cup.

Begrundelse: Prusa XL har 360x360mm print bed. En tower-segment på 200mm højde × 7 slots = 1.4m total højde. Print 3-5 segmenter á 30-40cm.

### Pumpe

**Foreløbig:** Submersible aquarium-pumpe 12V, ~200-400 L/h.

| Kandidater | Flow | Støj | Pris |
|---|---|---|---|
| Eheim CompactON 300 (12V variant) | 300 L/h | Ultra stille | ~250 DKK |
| Generic submersible USB 5V | 100-200 L/h | Lav | ~30 DKK |
| Jebao DC-1200 (overkill) | 1200 L/h | Lav | ~400 DKK |

Submersible passer fordi: hele pumpen sidder i reservoir (vand-køling, ingen prime-issues), og vi behøver høj flow (kontinuerlig recirculation vs pot's diskrete dosering).

### MCU

**Genbruger XIAO ESP32-C6 fra pot.** Samme firmware-skelet (FreeRTOS-tasks), men anden config-mode.

### Sensorer

- **Water level**: Større reservoir → ultralyd JSN-SR04T kunne fungere her (har 25cm dødzone, men reservoir er højere). Eller capacitive strip som i pot, bare længere.
- **Float switch**: ja, samme rolle som i pot (low-water cutoff).
- **pH-sensor**: ? — hydroponic kræver pH 5.5-6.5. Manuel måling er muligt, men automatisk er fancy. Beslut efter v1.
- **EC-sensor**: ? — nutrient concentration. Samme.
- **Temperatur** (vand): hydroponic vand >25°C → bakterie-vækst. Tilføj 1-wire DS18B20 i reservoir.

### Strøm

USB-C PD til 12V (samme som pot), eller direkte 12V barrel jack. Brug eksisterende 12V adapter hvis tilgængelig.

### Lys

**Åbent spørgsmål:** Vinduskarms-lys er tilstrækkeligt for krydderurter, men leafy greens (salat, spinat) trænger mere. LED grow lights tilføjer kompleksitet (timer, control, varme) men kunne være v2-feature.

Tanker:
- Hvis tower placeres ved vindue: skip grow lights i v2, evaluer behov efter 2-3 måneder
- Hvis indvendigt på væg: grow lights nødvendige; planlæg sektion i firmware til time-of-day-styret LED PWM

---

## Åbne spørgsmål (besvares løbende)

- [ ] Skal tower være ét stort print (Prusa XL) eller modulært (flere mindre prints)?
- [ ] Hvordan håndteres rens/skift af planter uden at demontere alt?
- [ ] Hvor placeres elektronikken — i bunden ved reservoir (våd!) eller separat udvendigt?
- [ ] Hvilken nutrient-løsning? (General Hydroponics Flora-serien er standard)
- [ ] Hvordan undgå alger i transparent vandvindue? (UV-LED? Dækfilm? Acceptér rens månedligt?)
- [ ] Skal pumpen køre 24/7 eller cykle? (24/7 er enklest; cyklisk sparer strøm + støj)
- [ ] Strømudtag: bag tower (skjult) eller skal kablet være pænt synligt?
- [ ] Vægmontering: skruer i mur eller free-standing med vægstøtte?

---

## Lessons learned fra pot (opdateres løbende)

*Endnu intet — pot er ikke bygget.*

Pladsholder-sektioner der opdateres efter hver pot-fase:

### Fra Fase 1 (firmware bring-up)
*TBD*

### Fra Fase 2 (mekanisk prototype)
*TBD*

### Fra Fase 3 (integration + live test)
*TBD*

### Generelle ting at huske ind i tower-design
*TBD*

---

## Genbrug fra pot

Disse moduler/dele kan genbruges direkte:

| Komponent | Genbrugsstatus | Notes |
|---|---|---|
| XIAO ESP32-C6 + ESP-Matter setup | 100% | Samme firmware base |
| Float switch + interlock logic | 100% | Hardware safety pattern |
| Water level capacitive strip | 90% | Bare længere version |
| MOSFET + flyback diode driver | 100% | Samme topologi |
| PD-trigger + buck converter | 100% | Samme strøm-arkitektur |
| OpenSCAD-modules (M3 inserts, gaskets) | 100% | Fra shared/cad-lib/ |
| Plant profile struct | Tilpasses | Bruger ikke moisture, men flow-rate + pH |

## Nye ting tower kræver

- Submersible aquarium-pumpe (vs peristaltisk)
- Større reservoir (2-4 L)
- Net cups + clay pebbles / rockwool
- Plumbing til top-distribution
- Mounting til væg (M5 inserts + tunge skruer)
- (Optional) pH + EC sensorer
- (Optional) LED grow lights + LED driver
