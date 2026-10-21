# Pot-Orchid — References & Inspiration

Links til orkide-pleje, hydroponic-soaking designs, og relaterede projekter. Tilføjes løbende under research.

## Orkide-pleje grundlag

- [American Orchid Society](https://www.aos.org/) — autoritativ kilde til Phalaenopsis-pleje
- Søg: "Phalaenopsis watering schedule", "orchid bark medium", "orchid soaking technique"

## Bark-mediums karakteristik

- Bark-størrelse vs vandretentions-tid
- Hvordan bark "ældes" (3-12 måneder) og hvornår det skal udskiftes
- Kontaktflade for vand-absorption

## Soak-tray / sub-irrigation designs

- [MakerWorld: 15cm automatic orchid watering system](https://makerworld.com/en/models/380211-15cm-automatic-orchid-watering-system)
  (+ small 380214 og large 440306) — orkide i øvre halvdel, akvariepumpe
  pumper vand op, niveausensor holder det i 2 min, dræner via huller.
  - Pro: bevist koncept, simpel elektronik, 3-4,5 L reservoir
  - Skip: submersible pumpe (tørløb), drænhuller kan stoppe til af bark
- Forum: LECA flyder ved oversvømmelse og kan løfte sensorer
  ([slippertalk](https://www.slippertalk.com/threads/worry-free-orchid-setup.54344/))

## Orkide-pleje — kilder brugt i ADR 011

- [AOS: Growing the Best Phalaenopsis pt. 2](https://secure.aos.org/media/Content-Images/PDFs/GrowingtheBestPhalaenopsisPart_2.pdf) — klare potter, bark-nedbrydning
- [UConn: Orchid Care and Repotting](https://homegarden.cahnr.uconn.edu/?p=558) — ~20 min soak
- [smartgardenguide](https://smartgardenguide.com/?p=514) — max 5 min i vand
- [Missouri Botanical Garden: Phalaenopsis](https://www.missouribotanicalgarden.org/Portals/0/Kemper%20Gardens/Fact%20Sheets/Orchids%20-%20Phalaenopsis%20%282020%29.pdf) — omplant ca. hvert 2. år

## Andre søgninger

- Søg Printables / Thingiverse: "orchid pot self-watering", "bottom watering pot"
- Kommercielle eksempler: Lechuza-line (sub-irrigation), Click and Grow

## Solenoid-ventiler 12V — FRAVALGT (ADR 011: vendbar pumpe i stedet)

- Generisk 12V solenoid ~150 DKK fra AliExpress / Conrad
- Normalt-lukket (NC) anbefales af safety-grunde
- Krav: kompatibel med drikke-vand (rustfri eller plastic interior)

## Smart home + soak-cyklus

- Matter cluster ideer: "Mode Select" for soak-state visning (IDLE / FILLING / SOAKING / DRAINING / DRYING)
- "Switch" cluster for manuel soak-trigger

## Tilføj løbende

Format:

```
- [Project Name](url) — kort beskrivelse
  - Pro: ...
  - Skip: ...
```
