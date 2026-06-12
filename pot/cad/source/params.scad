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

// Beregnet vandkapacitet ved max fill-line (= cup-bund niveau):
// zone under cup er fuld cylinder. (Ringen over kan også holde vand ved
// overfyldning, men max-fill defineres konservativt ved cup-bunden.)
reservoir_capacity_ml = PI * pow(reservoir_inner_d / 2, 2) * water_zone_h / 1000;

// Cup-flange: dækker hele reservoir-toppen uanset cup-størrelse, så
// enhver cup (S/M/L) passer på samme reservoir-ring
flange_outer_d = reservoir_outer_d + 2 * top_ring_width;

// Water level strip slot (vertikal kanal indvendig, i ring-zonen)
waterlevel_strip_w = 18;
waterlevel_strip_t = 2;
waterlevel_strip_h = 50;         // dækker vand-zonen (0-40mm) + margin

// Float switch niche (vandret monteret i bund)
float_switch_d = 16;             // typisk vertical float switch
float_switch_h = 25;
float_switch_x = 20;             // offset fra reservoir-center til niche

// Pump output port (lodret gennem reservoir-bund / ebase-top)
pump_port_d = 7;                 // 4mm slange + 1.5mm wall + tolerance
// Fælles X-position så reservoir-bund og ebase-top flugter (audit-fix).
// Variant A: porten SKAL ligge i ring-gabet mellem L-cup (r=80) og
// reservoir-indervæg (r=90), så slangen kan løbe op langs cuppen:
pump_port_x = 85;                // midt i ring-gabet

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
