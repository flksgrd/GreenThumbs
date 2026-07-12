// =============================================================================
// GreenThumbs Plantekrukke — Centrale parametre
// =============================================================================
// Single source of truth for alle dimensioner.
// Ændringer her propagerer til alle .scad-filer der bruger 'use <params.scad>'.
//
// Konvention: alle mål i mm. Vinkler i grader. Tolerances er positive (clearance).
// =============================================================================


// ----------------------------------------------------------------------------
// 1. Plant cup (skiftelig pr. plantestørrelse)
// ----------------------------------------------------------------------------
// Tre størrelser. Skift cup_size for at re-eksportere en anden variant.
//
// STACK-GEOMETRI (Variant A, valgt 2026-06): cuppen hænger NEDSÆNKET i
// reservoiret fra sin top-flange, med en vand-zone under cup-bunden.
// Derfor er L-cup max Ø160 (ikke 180): der skal altid være ≥10mm ring-gap
// mellem cup og reservoir-indervæg til pumpe-slange, water-strip og refill.
cup_size = "M";  // "S" | "M" | "L"

cup_diameter = (cup_size == "S") ? 100 :
               (cup_size == "M") ? 140 :
               160;  // L (max — se note ovenfor)

cup_height = (cup_size == "S") ? 120 :
             (cup_size == "M") ? 160 :
             200;  // L

cup_wall = 2.4;                  // vægtykkelse (6 perimeters @ 0.4mm nozzle)
cup_drain_hole_d = 4;            // diameter på drænhuller i bund
cup_drain_holes_count = 7;       // hex-mønster: 1 center + 6 ring

// Soil sensor slot (snap-fit i indvendig væg)
soil_sensor_w = 12;              // bredde af sensor PCB
soil_sensor_t = 1.8;             // tykkelse af sensor PCB
soil_sensor_slot_depth = 80;     // hvor langt ned sensor stikkes


// ----------------------------------------------------------------------------
// 2. Reservoir (Variant A: cup hænger nedsænket)
// ----------------------------------------------------------------------------
// AUDIT-FIX + redesign 2026-06: tidligere blev højden beregnet af et
// volumen-INPUT og ignorerede at cuppen optager pladsen (fysisk umulig
// geometri). Nu drives højden af cup-dybde + vand-zone, og kapaciteten
// er et OUTPUT (se echo nederst).

// Indvendig diameter: cup + ring-gap (slange/sensorer/refill)
reservoir_inner_d = 180;         // ≥ max cup (160) + 2×10mm ring-gap
reservoir_outer_d = reservoir_inner_d + 2 * 3;  // 3mm wall
reservoir_wall = 3;              // tykkere end cup (vandtryk + stabilitet)

// Top-ring til plant cup (defineres FØR reservoir_height-formlen —
// OpenSCAD tillader ikke forward references)
top_ring_width = 8;              // bredden af flange-overlap
top_ring_height = 4;

// Vand-zone under cup-bunden — vandet lever her (+ i ringen omkring cup)
water_zone_h = 40;

// Højde: cup hænger fra flangen på top-rim; cup-bund ender water_zone_h
// over reservoirets indre bund
reservoir_height = (cup_height - top_ring_height) + water_zone_h + reservoir_wall;

// OVERFLOW (ADR 009): fysisk beskyttelse mod overfyldning. Hul i
// reservoir-væggen overflow_margin under cup-bunden — fylder man forbi,
// løber overskuddet ud i pyntepotten i stedet for op i jorden.
// Placeret ved 270° (under refill-åbningen) så overløb ses ved påfyldning.
overflow_margin = 8;             // afstand fra cup-bund ned til overflow-niveau
overflow_hole_d = 5;
overflow_z = reservoir_wall + water_zone_h - overflow_margin;

// Beregnet vandkapacitet ved max fill-line (= overflow-niveau):
reservoir_capacity_ml = PI * pow(reservoir_inner_d / 2, 2)
                        * (water_zone_h - overflow_margin) / 1000;

// Cup-flange: dækker hele reservoir-toppen uanset cup-størrelse, så
// enhver cup (S/M/L) passer på samme reservoir-ring
flange_outer_d = reservoir_outer_d + 2 * top_ring_width;

// ============================================================================
// ZERO-PENETRATION PRINCIP (ADR 009): INGEN huller under vandlinjen.
// Alle slanger + kabler ruter: op gennem ring-gabet → gennem åbninger i
// cup-flangen → ned UDVENDIGT langs reservoiret → ind i ebase via side-glands.
//
// Vinkel-allokering (set oppefra, konsistent på tværs af alle dele):
//    0°: water-strip guide-ribber (indvendig) + USB-C gland (ebase)
//   45°: drænhul (ebase, fri af bosses)
//   90°: kabel-slids i flange + kabel-gland (ebase) + float-klips (bund)
//  180°: slange-åbning i flange + slange-gland (ebase)
//  270°: refill-åbning i flange + overflow-hul (reservoir-væg)
//  315°: rotations-index tap (rim) + notch (flange)
// ============================================================================

// Water level strip — holdes af to lodrette guide-ribber på indervæggen
// (IKKE en fræset slot: det skar gennem væggen = lækage. Audit-fix 2.)
waterlevel_strip_w = 18;
waterlevel_strip_t = 2;
waterlevel_strip_h = 50;         // dækker vand-zonen (0-40mm) + margin
strip_rib_w = 3;                 // ribbe-bredde (tangentielt)
strip_rib_t = 3;                 // ribbe-dybde (radialt, ind i ring-gabet)

// Float switch — sidder i en print-integreret klips-ring i bunden.
// Kablet går op gennem vandet/ring-gabet (float-kabler er vandtætte).
float_switch_d = 16;             // typisk vertical float switch
float_switch_x = 30;             // offset fra center (fri af cup-S skygge? nej
                                 // — under cuppen er fint, kablet føres skråt
                                 // ud til ring-gabet ved 90°)
float_clip_h = 10;               // klips-ring højde
float_clip_wall = 2;

// Slanger (2× 6mm OD: suge + tryk) gennem flange-åbning ved 180°
pump_port_d = 7;                 // hul i CUP-VÆGGEN til trykslangens dyse
hose_pass_d = 14;                // flange-åbning: plads til 2× Ø6 slanger
hose_pass_x = 85;                // radial position, midt i ring-gabet

// Kabel-slids i flangen ved 90° — åben mod kanten så kabler med stik kan
// lægges i fra siden ved montering
cable_slot_w = 8;

// Rotations-indexering: tap på reservoir-rim ved 315° + matchende notch i
// flangens underside → flangens åbninger flugter ALTID med reservoirets
// features (overflow under refill, ribber ved 0°, osv.)
index_tab_w = 8;                 // tangentielt
index_tab_l = 5;                 // radialt
index_tab_h = 2.5;

// Refill: gennem flange-åbningen ved 270°. Fuld refill-tube m. tragt = v1.1.


// ----------------------------------------------------------------------------
// 3. Electronics base (vandtæt kammer)
// ----------------------------------------------------------------------------
ebase_outer_d = reservoir_outer_d;  // matcher reservoir for stack-look
ebase_height = 40;                  // højde af elektronik-kammer
ebase_wall = 3;                     // tykkere walls for stabilitet
ebase_lid_height = 5;               // tykkelse af snap-on låg

// O-ring/gasket groove på top (forbinder med reservoir bund)
gasket_groove_w = 2.5;              // for 2mm O-ring
gasket_groove_d = 1.6;
gasket_groove_offset = 4;           // fra ydre kant

// Cable glands i ebase-siden (zero-penetration: alt kommer ind fra siden,
// ebase-toppen er nu HELT lukket). Vinkler matcher flange-åbningerne lodret:
//   0° = USB-C (PG7), 90° = sensor-kabler (PG7), 180° = slanger (PG9/grommet)
gland_hole_d = 12;                  // PG7 = 12mm hul (USB-C + kabler)
hose_gland_d = 16;                  // PG9 = 16mm hul (2× Ø6 slanger)
gland_angles = [0, 90];             // PG7-positioner
hose_gland_angle = 180;

// Drænhul (fail-safe ved lækage). AUDIT-FIX: 3→4mm (hurtigere afløb ved
// pumpe-lækage) + roteres 45° i ebase så det ikke skærer mounting bosses.
drain_hole_d = 4;

// Pump mount — DUAL FOOTPRINT på lid'ets indvendige side (piezo-research):
// passer både Kamoer KPP peristaltisk (2× M3, 46mm c-c flange) og
// Bartels BP7 + mp-Lowdriver (4× M3 i 24mm kvadrat til clamp/standoffs).
pump_mount_boss_h = 4;            // boss-højde over lid-flade
pump_mount_boss_d = 9;            // boss-diameter (M3 insert = 4.0mm hul)
pump_mount_kamoer_spacing = 46;   // 2-huls flange c-c
pump_mount_bp7_square = 24;       // 4-huls kvadrat side-længde


// ----------------------------------------------------------------------------
// 4. Load cell mount
// ----------------------------------------------------------------------------
// Bar load cell — TAL220 5kg eller equivalent
// (Samme fysiske dimensioner som 1kg-varianten; 5kg giver safety margin for
// succulenter/orkide. Se ADR 004.)
loadcell_length = 80;
loadcell_height = 13;
loadcell_width = 13;
loadcell_screw_spacing = 15;     // afstand mellem M4-huller på cellen

// Hvor langt fra cellens center er bolt-hullerne (ene end vs anden end)
// Standard TAL220: ~8mm fra hver ende. Negativ = fixed end, positiv = free end.
loadcell_fixed_x = -loadcell_length / 2 + 8;  // ≈ -32mm for 80mm cell
loadcell_free_x  =  loadcell_length / 2 - 8;  // ≈ +32mm

// Cantilever boss-dimensioner — KRITISK for at cellen kan bøje korrekt
// Boss højde skaber air-gap mellem cell midte og plader. Min ~3mm.
// Boss centreres OMKRING bolt-positionen (loadcell_fixed_x / loadcell_free_x).
boss_height = 4;                 // air-gap mellem cell og plade-overflade
boss_l = 22;                     // langs cellens akse (x) — minimum ~15mm + margin
boss_w = 24;                     // tværs på cellen (y) — skal omslutte 15mm hul-spacing

// Platform pladerne (over og under load cell)
platform_d = ebase_outer_d;      // matcher base
platform_thickness = 6;
// Total separation = under-boss + cell + over-boss
platform_separation = 2 * boss_height + loadcell_height;


// ----------------------------------------------------------------------------
// 5. Toleranser og print-settings
// ----------------------------------------------------------------------------
print_tolerance = 0.3;           // generisk clearance for snap-fits
press_fit_tolerance = 0.1;       // for trykpas (heat-set inserts, gaskets)
wall_thickness = 2.4;            // default for non-water parts

// Heat-set inserts (M3x5mm)
m3_insert_d = 4.0;               // hul-diameter for melt-in fit
m3_insert_h = 5.0;
m3_screw_head_d = 6.0;           // M3 socket head clearance


// ----------------------------------------------------------------------------
// 6. Globale rendering settings
// ----------------------------------------------------------------------------
$fn = 64;                        // smooth cylinder facets; sæt højere for final render
// (AUDIT-FIX: lokal PI-redefinition fjernet — OpenSCAD har built-in PI)


// ----------------------------------------------------------------------------
// Debug: print params til console når denne fil køres direkte
// ----------------------------------------------------------------------------
// echo() er sikre at have her — de udskriver til console også når filen
// inkluderes af andre. Til gengæld må der IKKE være top-level geometri
// (cylinder, cube, etc.) her — det ville forurene alle includere.
// Hvis du vil se geometri ved at åbne params.scad direkte, så åbn i stedet
// en af part-filerne (plant_cup.scad, reservoir.scad, ...) der include'er denne.
echo("=== GreenThumbs CAD params (stack variant A) ===");
echo("cup_size:", cup_size);
echo("cup_diameter:", cup_diameter, "mm");
echo("cup_height:", cup_height, "mm");
echo("water_zone_h:", water_zone_h, "mm");
echo("reservoir_capacity (BEREGNET):", reservoir_capacity_ml, "ml");
echo("reservoir_height (BEREGNET):", reservoir_height, "mm");
echo("reservoir_outer_d:", reservoir_outer_d, "mm");
echo("flange_outer_d:", flange_outer_d, "mm");
echo("total_stack_height (ca.):",
     ebase_lid_height + ebase_height + reservoir_height + top_ring_height, "mm");
