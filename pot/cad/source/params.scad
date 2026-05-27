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

// Pump output port (i siden, op til drip-ring)
pump_port_d = 7;                 // 4mm slange + 1.5mm wall + tolerance
pump_port_z = 15;                // højde over reservoir bund

// Refill tube (integreret i siden, vertikal)
refill_tube_outer_d = 22;
refill_tube_inner_d = 16;        // funnel i top
refill_tube_z_top = reservoir_height - 5;
refill_tube_z_bottom = 10;       // 1cm fra bund


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

// Drænhul (fail-safe ved lækage)
drain_hole_d = 3;


// ----------------------------------------------------------------------------
// 4. Load cell mount
// ----------------------------------------------------------------------------
loadcell_length = 80;            // standard 1kg bar load cell
loadcell_height = 13;
loadcell_width = 13;
loadcell_screw_spacing = 15;     // afstand mellem M4-huller

// Platform pladerne (over og under load cell)
platform_d = ebase_outer_d;      // matcher base
platform_thickness = 6;
platform_separation = loadcell_height + 4;  // load cell + clearance


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
PI = 3.14159265;                 // OpenSCAD har built-in PI, men eksplicit her for clarity


// ----------------------------------------------------------------------------
// Debug: print params til console når denne fil køres direkte
// ----------------------------------------------------------------------------
echo("=== GreenThumbs CAD params ===");
echo("cup_size:", cup_size);
echo("cup_diameter:", cup_diameter, "mm");
echo("cup_height:", cup_height, "mm");
echo("reservoir_volume:", reservoir_volume_ml, "ml");
echo("reservoir_height:", reservoir_height, "mm");
echo("reservoir_outer_d:", reservoir_outer_d, "mm");
echo("electronics_base_height:", ebase_height, "mm");

// En lille test-cylinder så filen kan åbnes direkte i OpenSCAD uden warnings
% cylinder(d = reservoir_outer_d, h = 1, center = false);
