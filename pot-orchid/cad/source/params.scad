// =============================================================================
// GreenThumbs Pot-Orchid — Centrale parametre (ADR 011)
// =============================================================================
// To-kammer flood-and-drain til Phalaenopsis i bark:
//
//   ORKIDE-CUP (klar PETG)     — bark + rødder, scalloped med 3 kanaler
//   SOAK-KAMMER (klar PETG)    — oversvømmes til soak_depth over cup-bund,
//                                 tømmes igen af den vendbare pumpe
//   LAGER (opak PETG)          — vandreserve; bred base for stabilitet
//   ELECTRONICS BASE (opak)    — pumpe (vendbar, H-bro), MCU, sensorer
//
// Pumpen kører forlæns (lager → soak-kammer) for at fylde og baglæns for at
// tømme. Ingen ventiler, ingen huller under vandlinjen ud mod elektronik.
//
// Fælles konstanter er her DUPLIKERET fra pot/cad/source/params.scad —
// flyttes til shared/cad-lib/ når begge designs er stabile.
// Konvention: mm, grader. z = 0 er bunden af hver del.
// =============================================================================

$fn = 96;

print_tolerance = 0.3;
m3_insert_d = 4.0;
m3_insert_h = 5.0;
m3_screw_head_d = 6.0;

// ----------------------------------------------------------------------------
// 1. Orkide-cup (klar PETG) — dimensioneret til 12cm Phalaenopsis
// ----------------------------------------------------------------------------
cup_diameter    = 132;          // ydre; indre ≈ 127 (12cm orkidepotte + luft)
cup_height      = 115;
cup_wall        = 2.4;
cup_clearance   = 1;            // kant-spillerum cup ↔ kammer-væg
top_ring_height = 4;            // flange-tykkelse
top_ring_width  = 6;            // flange-udhæng uden for kammeret

// Bund-drænhuller: større end i pot/ (bark-stykker er 5-15mm, ikke jord)
cup_drain_hole_d = 6;

// Side-aerations-slidser (orkidepotter har dem: luft til rødderne + vandet
// trænger hurtigere ind fra siden under soak). Smallere end bark-stykker.
side_slot_w     = 3;
side_slot_h     = 40;
side_slot_z0    = 8;            // over cup-bund
side_slot_step  = 15;           // vinkel-afstand
side_slot_skip  = 28;           // spring over inden for ± denne vinkel fra en kanal

// ----------------------------------------------------------------------------
// 2. Service-kanaler i cup-kanten (samme princip som ADR 010)
// ----------------------------------------------------------------------------
//    90°: SENSOR-kanal — Grove water level i guide-ribber (måler soak-dybde
//         og bekræfter fuld dræn)
//   180°: SKAKT-kanal  — tør skakt (conduit) med alle slanger + kabler ned
//         til electronics base; slange A løber ved siden af ned til sump
//   270°: REFILL-kanal — påfyldnings-rør direkte ned i lageret
// Skakten og påfyldnings-røret står fast i kammeret og fungerer som nøgler:
// cuppen kan kun sænkes ned i ÉN rotation.
ch_sensor_angle  = 90;   ch_sensor_d  = 32;
ch_conduit_angle = 180;  ch_conduit_d = 40;
ch_refill_angle  = 270;  ch_refill_d  = 32;

// ----------------------------------------------------------------------------
// 3. Soak-kammer (klar PETG; gulvet printes OPAKT via filamentskift i
//    gulv-toppen, så lys ikke når lageret — alger)
// ----------------------------------------------------------------------------
chamber_wall    = 3;
chamber_inner_d = cup_diameter + 2 * cup_clearance;
chamber_outer_d = chamber_inner_d + 2 * chamber_wall;

cup_floor_gap   = 12;           // gulv-top → cup-bund (dræn-zone)
soak_depth      = 55;           // vand over cup-bund ved max soak (~halv cup)
max_soak_level  = cup_floor_gap + soak_depth;   // over gulv-top

soak_floor_t    = 4;            // gulv-tykkelse ved laveste kant (sump-siden)
floor_slope     = 3;            // fald over kammer-diameteren mod sumpen
chamber_height  = cup_floor_gap + cup_height - top_ring_height; // gulv-top (høje side) → rim

// Sump: laveste punkt; slange A's ende (med si) ligger her
sump_angle = 194;               // ved siden af skakten (i skakt-kanalens rum)
sump_r     = 60;
sump_d     = 12;
sump_depth = 2.5;

// Fysisk loft over soak-niveauet (ADR 009-princip): hul UDAD i kammer-væggen
// ved max_soak_level. Rammes kun ved firmware-fejl (pumpe-runaway).
soak_overflow_d     = 5;
soak_overflow_angle = 0;

flange_outer_d = chamber_outer_d + 2 * top_ring_width;

// Grove Water Level Sensor 10cm (20×133mm) holdes af to ribber med noter,
// så printpladen sidder 2mm fra væggen — så går den fri af flangen og
// stikker op gennem flange-udskæringen ved 90°.
grove_w        = 20;
grove_t        = 2;
grove_h        = 133;
grove_wall_gap = 2;             // afstand væg → printplade
rib_depth      = 6;             // radialt ind fra væggen
rib_solid      = 3;             // ribbe-bredde uden for printpladen
groove_bite    = 2.5;           // hvor langt pladens kant går ind i ribben

// ----------------------------------------------------------------------------
// 4. Lager (opak PETG) — bred base: stabilitet med høj blomsterstængel
// ----------------------------------------------------------------------------
base_outer_d            = 170;
storage_wall            = 3;
storage_inner_d         = base_outer_d - 2 * storage_wall;
storage_water_h         = 58;   // vandsøjle til overflow-hullet
storage_overflow_margin = 6;    // overflow-hul → rim (kan aldrig nå skakt/rør)
storage_overflow_d      = 6;
storage_overflow_angle  = 0;
storage_height          = storage_wall + storage_water_h + storage_overflow_margin;

// Krave på lager-rimmen: soak-kammerets gulv-skive sidder inde i den
collar_t = 1.5;
collar_h = 4;

// Float switch (low-water) i lagerets bund under påfyldnings-røret;
// kablet går op gennem røret
float_d      = 16;
float_r      = 45;
float_angle  = 270;
float_clip_h = 10;
float_clip_wall = 2;

// ----------------------------------------------------------------------------
// 5. Tør skakt (conduit) — del af lager-printet: fra lagerets bund (åben ned
//    i electronics base) op gennem lageret og kammer-gulvet til et stykke over
//    max soak-niveau. Vand kan kun komme ind fra toppen.
// ----------------------------------------------------------------------------
conduit_od = 20;
conduit_id = 16;
conduit_r  = chamber_inner_d / 2 - conduit_od / 2 - 0.5;   // radial position
conduit_top_above_soak = 20;
// Krave på skakten lige under soak-gulvet: gulvet hviler på den med en
// pakning (EPDM/TPU-skive). Uden den ville spalten om skakten dræne
// soak-kammeret ned i lageret på under et minut.
conduit_collar_d = conduit_od + 12;
conduit_gasket_t = 1.5;
conduit_gasket_squeeze = 0.5;
// Højde målt fra lagerets bund (z = 0 i storage.scad)
conduit_top_z = storage_height + soak_floor_t + floor_slope
                + max_soak_level + conduit_top_above_soak;

// ----------------------------------------------------------------------------
// 6. Påfyldnings-rør (del af soak-kammeret) — fra gulvet op til rimmen,
//    bunden åben ned i lageret. Slange B og float-kablet går også herned.
// ----------------------------------------------------------------------------
refill_od = 14;
refill_id = 10;
refill_r  = chamber_inner_d / 2 - refill_od / 2 - 0.5;

// ----------------------------------------------------------------------------
// 7. Electronics base (opak) — højere end i pot/: KPHM200-pumpen er større
// ----------------------------------------------------------------------------
ebase_outer_d    = base_outer_d;
ebase_height     = 60;          // PLACEHOLDER — verificér mod KPHM200-mål
ebase_wall       = 3;
ebase_lid_height = 5;
usb_hole_d       = 12;          // placeholder til USB-C panel-mount ved 0°
drain_hole_d     = 4;

// ----------------------------------------------------------------------------
// 8. Beregnede størrelser (echo)
// ----------------------------------------------------------------------------
bark_porosity = 0.55;           // vandfyldt andel af bark-volumen (antagelse)

chamber_area     = PI * pow(chamber_inner_d / 2, 2);
cup_outer_area   = PI * pow(cup_diameter / 2, 2);
cup_inner_area   = PI * pow(cup_diameter / 2 - cup_wall, 2);
channels_half    = PI * (pow(ch_sensor_d / 2, 2) + pow(ch_conduit_d / 2, 2)
                         + pow(ch_refill_d / 2, 2)) / 2;

soak_volume_ml = (chamber_area * cup_floor_gap
                  + (chamber_area - cup_outer_area + channels_half) * soak_depth
                  + cup_inner_area * soak_depth * bark_porosity) / 1000;

storage_capacity_ml = (PI * pow(storage_inner_d / 2, 2)
                       - PI * pow(conduit_od / 2, 2)) * storage_water_h / 1000;

pump_ml_per_min = 260;          // Kamoer KPHM200 (forhandler-spec)

total_height = ebase_lid_height + ebase_height + storage_height
               + soak_floor_t + floor_slope + chamber_height + top_ring_height;

echo("=== Pot-Orchid params (ADR 011) ===");
echo("cup:", cup_diameter, "x", cup_height, "mm");
echo("soak-volumen ved max soak (BEREGNET):", soak_volume_ml, "ml");
echo("lager-kapacitet (BEREGNET):", storage_capacity_ml, "ml");
echo("reserve efter én soak:", storage_capacity_ml - soak_volume_ml, "ml");
echo("fyld-/dræntid pr. retning:", soak_volume_ml / pump_ml_per_min, "min");
echo("total stak-højde:", total_height, "mm (+ load cell ~33mm)");
