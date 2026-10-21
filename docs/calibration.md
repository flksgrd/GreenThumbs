# Kalibreringsprocedure

Dokumenteret procedure for at kalibrere alle sensorer og pumpe på en samlet krukke. Udføres første gang ved opsætning, og periodisk hver 3-6 måned for sensor-drift.

## 1. Pumpe-kalibrering (ml/sek konstant)

**Formål**: Konverter pump-aktiveringstid til præcis volumen.

1. Saml elektronik + pumpe + slange. Sæt slange-udløb over et målebæger.
2. Fyld reservoir med vand.
3. Via UART serial monitor eller HomeKit-knap: trig pumpe i præcis 10.0 sekunder.
4. Vej output (1 gram vand = 1 ml).
5. Beregn `pump_ml_per_sec = output_ml / 10.0`.
6. Gem i NVS via firmware-kommandoen `cal pump <ml_per_sec>`.
7. **Verifikation**: kør pumpe i 5 sek og 20 sek, mål output. Forventet inden for ±5%.

Typisk værdi for Kamoer KXF-DC-S06 @ 12V: ~0.6 ml/sek (forhandler-spec 37 ml/min — mål selv, flow afhænger af slangen).

## 2. Soil moisture sensor (kapacitiv)

**Formål**: Sæt `adc_dry` (luft) og `adc_wet` (våd jord) referencer per sensor-eksemplar.

1. Hold sensoren i åbn luft (ikke rør elektronikken). Vent 5 sek for stabilisering.
2. Læs ADC-værdi fra UART (eller `sensor read soil` kommando). Notér som `adc_dry`.
3. Dyp sensoren i et glas vand op til markeringslinjen (IKKE elektronikken!). Vent 5 sek.
4. Læs ADC-værdi. Notér som `adc_wet`.
5. Gem begge i NVS via `cal soil <adc_dry> <adc_wet>`.

Typiske værdier (DFRobot kapacitiv v2.0 @ 3.3V):
- `adc_dry` ≈ 3000 (højere = tørrere)
- `adc_wet` ≈ 1200

Procent beregnes som: `pct = 100 * (adc_dry - reading) / (adc_dry - adc_wet)`, clampet til [0, 100].

## 3. Water level sensor (Seeed Grove 10cm, I2C)

**Formål**: Sæt pad-tærskel og 100%-punkt for vandniveau-sensoren.

Sensoren har 20 kapacitive pads (8 på I2C 0x77, 12 på 0x78) langs 10cm og
returnerer én råværdi per pad. Vandstand = antal pads over tærskel × ~5mm
(spec: ±5mm). Kun de nederste ~7 pads ligger i vand-zonen (max ~32mm) —
det er rigeligt til refill-buzzerens 25%-trin.

1. Tom reservoir helt. Læs alle 20 pad-værdier (`sensor read water raw`).
   Notér tør-niveauet.
2. Fyld reservoir til **overflow-niveau**: hæld til det begynder at dryppe
   fra overflow-hullet (270°), stop, og vent til dryppet er ophørt. Det er
   det fysisk entydige 100%-punkt (ADR 009).
3. Læs pad-værdierne igen. Sæt tærsklen midt mellem tør- og våd-værdierne
   (Seeeds eksempelkode bruger ~100 som default).
4. Notér antal våde pads ved overflow som `water_full_pads`.
5. Gem via `cal water <threshold> <water_full_pads>`.

Procent beregnes som `pct = 100 * wet_pads / water_full_pads`, clampet til [0, 100].
Vandet må aldrig nå sensorens hvide skillelinje (elektronik-zonen) — ved
overflow-niveau er der ~10cm margin.

## 4. Float switch (binær)

**Formål**: Verificer at low-water cut-off virker.

1. Sæt float switch i reservoir-bund. Reservoir tom.
2. Verificer at GPIO læser **LOW** (= "vand tomt"). Hvis HIGH: tjek polaritet på switch (NO vs NC).
3. Fyld reservoir langsomt. Når vandstand når ~1cm over switch-toppen, skal GPIO skifte til **HIGH**.
4. Verificer via firmware-log eller HomeKit Leak Detector-cluster.

Ingen NVS-kalibrering nødvendig — float er binær.

## 5. HX711 load cell

**Formål**: Sæt scale-faktor og tare-baseline.

1. Sæt hele krukken (samlet) på load cell platform — tom (ingen plante, ingen vand).
2. Læs HX711 rå-værdi. Notér som `raw_zero`.
3. Sæt en standard-vægt på krukken (fx 500g certificeret kalibreringslod).
4. Læs rå-værdi. Notér som `raw_500g`.
5. Beregn `scale_factor = 500.0 / (raw_500g - raw_zero)` (gram per LSB).
6. Gem i NVS via `cal weight <raw_zero> <scale_factor>`.
7. **Verifikation**: brug 100g lod, forvent aflæsning 100g ±2g.

## 6. Plant tare (per plante, ikke per sensor)

**Formål**: Sæt `weight_baseline_g` for den specifikke plante.

1. Plant planten, fyld reservoir, kør første vanding manuelt så jorden er optimalt fugtet.
2. Vent 30 min så vand er fordelt og dryp er stoppet.
3. Tryk på "Tare"-knap (fysisk knap på krukken, eller HomeKit-knap).
4. Firmware gemmer aktuel HX711-vægt som `weight_baseline_g` for aktiv profil.
5. Fra nu af måles vand-behov som vægt-fald fra denne baseline.

**Hvornår re-tare**: Hver gang du omplanter, beskærer betydeligt, eller skifter potte-substrat.

## Genkalibrerings-skema

| Komponent | Frekvens | Symptomer der trigger re-kalibrering |
|---|---|---|
| Pumpe ml/sek | Hver 6. måned | Aflejringer i slangen ændrer flow-rate |
| Soil sensor dry/wet | Hver 6. måned | Aflæsninger drifter, jord ser ikke ud som beregnet |
| Water level | Hver 12. måned | Stripper kalk-belægning ændrer kapacitans |
| Float switch | Visuel inspektion 6. måned | Float kan kile sig fast af biofilm |
| HX711 zero | Ved synlig drift | Temperaturskift ved sæson-skifte |
| Plant tare | Ved omplantning | Ny baseline efter genplantning |
