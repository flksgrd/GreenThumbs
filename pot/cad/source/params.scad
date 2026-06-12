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
cup_size = "M";  // "S" | "M" | "L"

cup_diameter = (cup_size == "S") ? 100 :
               (cup_size == "M") ? 140 :
               180;  // L

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
// 2. Reservoir
// ----------------------------------------------------------------------------
reservoir_volume_ml = 700;       // 700 eller 1500

// Indvendig diameter: standardiseret så plant cups passer
reservoir_inner_d = 180;         // skal være >= max(cup_diameter)
reservoir_outer_d = reservoir_inner_d + 2 * 3;  // 3mm wall
reservoir_wall = 3;              // tykkere end cup (vandtryk + stabilitet)

// Højde beregnet ud fra volumen (cylinder)
// V = pi * r^2 * h  →  h = V / (pi * r^2)
// Tilføj +30mm for top-ring og sensor-clearance
reservoir_height = reservoir_volume_ml * 1000 /
                   (PI * pow(reservoir_inner_d / 2, 2)) + 30;

// Top-ring til plant cup
top_ring_width = 8;              // bredden af flange-overlap
top_ring_height = 4;

// Water level strip slot (vertikal kanal indvendig)
waterlevel_strip_w = 18;
waterlevel_strip_t = 2;
waterlevel_strip_h = 60;         // strip rækker fra bund og op

// Float switch niche (vandret monteret i bund)
float_switch_d = 16;             // typisk vertical float switch
float_switch_h = 25;
float_switch_x = 20;             // offset fra reservoir-center til niche

// Pump output port (lodret gennem reservoir-bund / ebase-top)
pump_port_d = 7;                 // 4mm slange + 1.5mm wall + tolerance
pump_port_z = 15;                // højde over reservoir bund
// AUDIT-FIX: fælles X-position så reservoir-bund og ebase-top flugter
// (var inner_d/4 vs outer_d/4 = 1.5mm offset)
pump_port_x = reservoir_inner_d / 4;  // 45mm fra center

// Refill: v1 bruger en simpel NOTCH i reservoir top-rim (se reservoir.scad).
// Fuld integreret refill-tube (tragt-top, ned til 1cm fra bund) er v1.1 —
// parametre genindføres dér. (AUDIT-FIX: døde tube-params fjernet)


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

// Cable gland gennemføring (USB-C + sensor wires)
gland_hole_d = 12;                  // PG7 = 12mm hole
gland_count = 2;                    // 1x USB-C, 1x sensor-bundt

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
echo("=== GreenThumbs CAD params ===");
echo("cup_size:", cup_size);
echo("cup_diameter:", cup_diameter, "mm");
echo("cup_height:", cup_height, "mm");
echo("reservoir_volume:", reservoir_volume_ml, "ml");
echo("reservoir_height:", reservoir_height, "mm");
echo("reservoir_outer_d:", reservoir_outer_d, "mm");
echo("electronics_base_height:", ebase_height, "mm");
