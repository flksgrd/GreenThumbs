# Pot-Orchid Design Notes

**Status:** Initielle design-noter. Opdateres løbende mens v1 (`pot/`) bygges.

Dette dokument samler designvalg, åbne spørgsmål, og lessons learned der akkumuleres under v1-arbejdet. Når v1 er færdig, vil dette være grundlag for v2 pot-orchid-implementering.

---

## Brugerkrav

- **Ægte soaking**: tray oversvømmes med vand op til "soak-line" → står i 10-15 min → drænes
- **Stille drift**: pumpen kører kun under fyld/drain (~30-60 sek total per uge ved Phalaenopsis-cyklus)
- **Bark-medium**: bark, ikke jord. Større drænhuller for at vandet kan trænge ind/ud
- **Vægt-detektion påkrævet**: bark-medium gør capacitive soil sensor upålidelig (samme problem som beskrevet i ADR 004)
- **Genbrug v1-elektronik**: samme MCU, pumpe, sensorer, kun ekstra solenoid + tray water level sensor

---

## Designvalg (foreløbige)

### Pumpe-valg: piezo-option (fra piezo-research 2026-06)

Bartels BP7 piezo-mikropumpe (€57 + mp-Lowdriver €67 ≈ 925 DKK) blev fravalgt i pot/ v1 (6× pris, ingen reel energigevinst). **Men til pot-orchid er den interessant:**
- Soak-tray fyldes langsomt → BP7's lave flow (0-9 ml/min) er ikke en ulempe her
- Nær-lydløs drift passer soveværelses-placering
- Præcis dosering ned til µl-niveau
- pot/ electronics_base får dual-footprint pump-mount, så BP7 kan testes dér først

→ Se [docs/research/piezo-components.md](../docs/research/piezo-components.md). Status: premium-option, beslut efter v1-validering.

### Drain-mekanisme: solenoid vs passiv overflow

**Foreløbig beslutning:** Passiv overflow (enklere, ingen ekstra elektronik).

**Solenoid-drain:**
- Pro: præcis kontrol over hvornår tray drænes
- Pro: kan holde tray fyldt for lange soak-cykler (>1 time hvis ønsket)
- Con: ekstra 12V solenoid (~150 DKK), driver kredsløb, vandtæt mounting
- Con: hvis solenoid fejler i lukket position → tray oversvømmer

**Passiv overflow:**
- Tray har en overflow-hul i siden ved "soak-line"-højde. Vand der pumpes ind over denne højde løber tilbage til reservoir via overflow-rør.
- Soak-tid styres af pump-aktiverings-tid: pump fylder tray → fortsætter til overflow → soak-tid løber → pump stopper → vand i tray VEDBLIVER indtil det fordamper / planten absorberer det
- Pro: ingen ekstra elektronik
- Con: ingen aktiv drain — vandet i tray skal absorberes/fordampe, kan tage timer
- Con: hvis pumpen ikke stopper rettidigt → kun overflow forhindrer overflow til gulv

**Status:** Lean toward passiv overflow for simplicity. Beslut endeligt efter v1-test af pumpe-præcision.

### Soak-cyklus tid

Standard Phalaenopsis soak:
- Soak-tid: 10-15 min
- Frekvens: 1 gang per uge (7 dage)
- Vandtemperatur: rumtemperatur (ikke koldt)

Firmware-tilstandsmaskine:

```
IDLE → (weight drop trigger) → FILLING → SOAKING → DRAINING → DRYING → IDLE
       ~7 dage cooldown        ~30 sek    ~12 min   ~5 min      ~1 dag
```

### Tray-størrelse

Hvilken tray-størrelse passer til en standard orkide?

Phalaenopsis i 12cm orkide-potte: typisk 100-150ml vand til soak.

Tray dimensioner (foreløbige):
- Indvendig diameter: 140mm (passer 12cm pot med spillerum)
- Højde: 50mm (med soak-line ved 40mm = ~600ml volumen)

Genbrug `params.scad` parametre hvor muligt; tilføj `tray_diameter`, `tray_height`, `soak_line_height`.

### Tray water level sensor

Behøver vi den? Argumenter:
- Pro: detekter om soak-cyklus rent faktisk når soak-line (sanity check på pumpe)
- Pro: detekter om drain fungerer (water level falder over tid)
- Con: endnu en sensor + wire-rute + kalibrering

Foreløbigt: ja, tilføj. Reuse capacitive water level strip type som i reservoir.

---

## Åbne spørgsmål (besvares løbende)

- [ ] Skal pot-orchid være ét stort print eller modulært (stack ovenpå pot/-base)?
- [ ] Solenoid eller passiv overflow? (lean: passiv)
- [ ] Hvordan ser bark-medium ud i en CAD-visualisering? (For at vælge drænhulsstørrelse)
- [ ] Skal vi støtte mock-orkide profiler for store succulenter også, eller kun orkide?
- [ ] Hvor sidder solenoiden hvis vi vælger den? (Inde i electronics_base eller ekstern?)
- [ ] Skal tray være transparent/halv-transparent så bruger kan se soak-progress?
- [ ] Hvor placeres tray water-level sensor? (Indvendigt slot eller eksternt monteret?)

---

## Lessons learned fra pot/ (opdateres løbende)

*Endnu intet — pot/ er ikke bygget.*

Pladsholder-sektioner der opdateres efter hver pot/-fase:

### Fra Fase 1 (firmware bring-up)
*TBD*

### Fra Fase 2 (mekanisk prototype)
*TBD*

### Fra Fase 3 (integration + live test)
*TBD*

### Specifikt relevant for pot-orchid
- Hvor præcis er peristaltisk pumpe efter kalibrering? (kritisk for tray-fyld uden overflow)
- Hvor godt detekterer load cell små vægt-fald i bark? (kalibrering reference)
- Termisk drift fra elektronik (hvor meget påvirker det vægt-måling over en uge)?

---

## Genbrug fra pot/

Se også [README.md](README.md) genbrugstabel.

Direkte genbrug af CAD-moduler fra `shared/cad-lib/`:
- M3 heat-set insert mount
- Gasket groove (for tray-til-reservoir seal)
- Cable gland holes

Genbrug fra `pot/cad/source/`:
- `reservoir.scad` mostly same
- `electronics_base.scad` udvides med ekstra cable gland for solenoid (hvis valgt)
- `load_cell_mount.scad` 100% genbrug
- `plant_cup.scad` udvides → `orchid_cup.scad` med færre, større drænhuller
- NY: `soak_tray.scad`

Genbrug fra `pot/firmware/`:
- Hele FreeRTOS task-skeletten
- profiles.h struct (udvides med soak-felter)
- HX711 driver
- Float switch ISR
- Matter cluster bindings

Ny firmware:
- `soak_cycle.cpp` — tilstands-maskine for FILL/SOAK/DRAIN/DRY
- Eventuelt `solenoid.cpp` hvis vi vælger solenoid-drain
