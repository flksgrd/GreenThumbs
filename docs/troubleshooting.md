# Troubleshooting

Common issues og hvordan du diagnostiserer dem. Opdateres løbende under prototyping.

## Pumpen vil ikke køre

1. **Tjek float switch**: hvis reservoir er tom → safety-interlock blokerer pumpe. Fyld vand op.
2. **Tjek HomeKit-status**: er manuel-pump-switch ON? Står der "Pump disabled" i log?
3. **Tjek 12V skinne**: mål med multimeter ved pumpe-terminaler når GPIO er HIGH. Skal være 12V ±0.5V.
4. **Tjek MOSFET-gate**: GPIO PWM skal være HIGH (3.3V). Hvis 0V: software-bug i `pump.cpp`.
5. **Tjek slange**: er der knæk på slangen? Er pumpe-rotoren blokeret?

## HomeKit viser ikke device

1. **Thread Border Router aktiv?**: HomePod mini / Apple TV 4K / iPad Pro M-serie. Tjek i Home-app → Settings → "Thread Network".
2. **Distance til border router**: ESP32-C6 Thread radio rækker ~10m gennem vægge. Flyt tættere ved første pairing.
3. **Reset device**: hold manuel-knap nede i 10 sek ved boot → factory reset, åbner pairing-mode igen.
4. **Tjek log**: serial monitor skal vise `Matter device ready, QR code: ...`. Hvis ingen QR: ESP-Matter SDK init fejler.

## Soil moisture læser konstant 0% eller 100%

1. **0%**: Sensoren rører ikke jord. Sæt den længere ned i jorden (men ikke så langt at elektronikken rører jord).
2. **100%**: Sensoren rører jord-overfladen og er måske over-vandet, eller sensoren har vand-skade. Verificer i tør luft først.
3. **Stuck**: re-kalibrer (se [calibration.md](calibration.md) sektion 2).
4. **Korrosion**: hvis sensor-pad er begyndt at korrodere → udskift sensor. Brug ALDRIG resistive sensorer — kun kapacitive.

## Vægt-aflæsning drifter

1. **Temperatur-skift**: HX711 har ~50 ppm/°C drift. Hvis værelse-temperatur ændres betydeligt → re-tare via HomeKit-knap.
2. **Termisk drift fra egen elektronik**: ESP32 + buck-converter genererer ~1-2W der vandrer ned gennem electronics base i load cell. Drift på ~0.5g/°C ved 5kg cell. **Mitigation**: indsæt 2-3mm rubber-pad mellem `electronics_base_lid` og `load_cell_mount` upper plate.
3. **Krukke flyttet**: load cell er sensitiv overfor placering. Hvis krukken er flyttet → re-tare.
4. **Cable issue**: tjek at load cell wires ikke er løse i HX711-modulet.

## Vægt-aflæsning er støjende, især under/efter pumpning

Pumpen sidder i electronics base, direkte over load cell. Mekaniske vibrationer forplanter sig ind i cellen.

1. **Verificer firmware filtrerer korrekt**: 5-sample moving average skal være aktivt. Tjek `weight_filter()` i sensors.cpp.
2. **Sample timing**: firmware MÅ ikke læse HX711 mens `pump_active = true`. Verificer i log at sample-timestamps ikke ligger inden for pumpe-cyklus.
3. **Vent-tid efter pump stop**: minimum 30 sek før første nye gyldige sample. Mekaniske oscillationer dør først ud da.
4. **Vibration fra eksterne kilder**: vaskemaskine, gulv-stomp, etc. Moving average filtrerer 1-2 sek spikes. Hvis vedvarende støj — flyt krukken eller læg blød mat under.

## Vandlækage til elektronik

**Stop alt med det samme**. Tag USB-C ud.

1. Tag electronics base af.
2. Tør komplet med absorbing klud + 24t i tørt rum.
3. Inspicer for korrosion på pin headers og passive komponenter.
4. Find lækage-kilde: typisk slange-grommet eller PG7 cable gland. Skift gasket.
5. Test electronics base separat (uden vand) før samling igen.

**Forebyggelse**: drænhullet i electronics base bund skal være åbent (papir-clip kan rense det).

## Krukken vibrerer / udsender støj

1. **Pumpe mekanisk klik**: normalt for peristaltisk pumpe. Acceptabelt ved 100 sek/dag drift.
2. **Vibration fra electronics base**: monteringen er løs. Spænd M3-bolte.
3. **Whining / pibe-lyd**: buck-converter switching noise. Forsøg at flytte MP1584 længere væk fra MCU og pumpe-loop. Tilføj 100µF elko ved input/output.

## Firmware bygger ikke

1. **`platformio.ini` framework-mismatch**: Skal være `framework = espidf`, ikke `arduino`. ESP-Matter SDK kræver IDF.
2. **esp-matter component fail**: kør `pio pkg update` og tjek at `dependencies.lock` ikke er gammel.
3. **Out of memory under link**: ESP-Matter er stor. Tjek at partition table giver mindst 2MB til app.
4. **Toolchain mismatch**: platform `espressif32 @ ^6.5.0` matcher med ESP-IDF 5.1+. Hvis du ser GCC-fejl: pin til specifik version.

## Plante ser tør ud trods systemet vander

1. **Profile mismatch**: tjek at aktiv profil matcher plantetypen. Succulent-profil på Monstera → kraftig under-vanding.
2. **Cooldown for lang**: `cooldown_min` for høj → planten kan tørre ud mellem doseringer. Sænk til 50% af nuværende.
3. **Dose for lille**: `dose_ml` for lille → vandet når ikke rødderne. Hæv til 50% mere.
4. **Drip-ring tilstoppet**: små huller kalker til over tid. Rens med en safety pin.

## Plante ser over-vandet ud (gulnende blade, råd)

1. **Profile for våd**: succulent-profil bør have `target_max_pct` ≤ 20%. Tjek aktuel profil.
2. **`daily_ml_cap` for høj**: hvis pumpen kører for ofte → safety-cap stopper det. Sænk daily cap.
3. **Drænage problem**: dræn-huller i plant cup tilstoppet → vand står i bund. Tjek + rens.
