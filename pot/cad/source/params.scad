// =============================================================================
// GreenThumbs Plantekrukke — Centrale parametre
// =============================================================================
// Single source of truth for alle dimensioner.
// Ændringer her propagerer til alle .scad-filer der bruger 'use <params.scad>'.
//
// Konvention: alle mål i mm. Vinkler i grader. Tolerances er positive (clearance).
// =============================================================================


// ----------------------------------------------------------------------------
// 1. Plant cup — driver HELE stakkens dimensioner (adaptivt design)
// ----------------------------------------------------------------------------
// ADAPTIV DIAMETER (2026-07): cup-størrelsen driver alle diametre nedstrøms
// (reservoir, electronics base, lid, load cell platform) via et FAST ring_gap.
// Hver størrelse er dermed et MATCHENDE SÆT — reservoir og base re-printes
// per størrelse, til gengæld er gabet altid ens og reservoiret maksimalt.
//
// STACK-GEOMETRI (Variant A): cuppen hænger NEDSÆNKET i reservoiret fra sin
// top-flange, med en vand-zone under cup-bunden. Centrerings-lugs på
// flangens underside holder cuppen præcist i midten.
cup_size = "M";  // "S" | "M" | "L" | "CUSTOM"

// CUSTOM: sæt frit til din pyntepotte. Eksemplet her er tunet til en potte
// med indre mål Ø260×H230: ydre reservoir Ø236 (12mm luft per side), total
// stak-højde ~229mm (flugter med pottens kant). Kapacitet ~1.3 L.
custom_cup_diameter = 190;
custom_cup_height   = 145;

cup_diameter = (cup_size == "S") ? 100 :
               (cup_size == "M") ? 140 :
               (cup_size == "L") ? 180 :
               custom_cup_diameter;

cup_height = (cup_size == "S") ? 120 :
             (cup_size == "M") ? 160 :
             (cup_size == "L") ? 200 :
             custom_cup_height;

cup_wall = 2.4;                  // vægtykkelse (6 perimeters @ 0.4mm nozzle)
cup_drain_hole_d = 4;            // diameter på drænhuller i bund
cup_drain_holes_count = 7;       // hex-mønster: 1 center + 6 ring

// Soil sensor slot (snap-fit i indvendig væg)
soil_sensor_w = 12;              // bredde af sensor PCB
soil_sensor_t = 1.8;             // tykkelse af sensor PCB
soil_sensor_slot_depth = 80;     // hvor langt ned sensor stikkes


// ----------------------------------------------------------------------------
// 2. Reservoir (Variant A: cup hænger nedsænket) — ADAPTIV diameter
// ----------------------------------------------------------------------------
// Højde drives af cup-dybde + vand-zone; diameter drives af cup-diameter +
// FAST ring_gap. Kapaciteten er et OUTPUT (se echo nederst).

// FAST ring-gab (per side) mellem cup-væg og reservoir-indervæg.
// Dimensionerer plads til: 2× Ø6 slanger, water-strip + ribber (5mm),
// sensor-kabler, og påfyldning med vandkande-tud. Ens for ALLE størrelser.
ring_gap = 20;

reservoir_wall = 3;              // tykkere end cup (vandtryk + stabilitet)
reservoir_inner_d = cup_diameter + 2 * ring_gap;   // ADAPTIV
reservoir_outer_d = reservoir_inner_d + 2 * reservoir_wall;

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

// Cup-flange: dækker hele reservoir-toppen (matchende sæt per størrelse)
flange_outer_d = reservoir_outer_d + 2 * top_ring_width;

// CENTRERING + ROTATIONS-INDEXERING i ét: 4 tapper på reservoir-RIMMEN
// (peger op — printer perfekt ved upright print) griber op i matchende
// LOMMER i flangens underside (subtraktioner — heller intet print-problem).
// Vinklerne er BEVIDST asymmetriske → flangen passer kun i ÉN orientering,
// og de tætte lomme-tolerancer holder samtidig cuppen præcist centreret
// med ens ring-gab hele vejen rundt.
// Vinkler valgt fri af flange-åbningerne (90° slids, 180° slanger,
// 270° refill):
rim_tab_angles = [30, 150, 210, 315];
rim_tab_w = 8;                   // tangentielt (radial dybde = reservoir_wall)
rim_tab_h = 2.5;                 // højde over rim

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
//  30/150/210/315°: rim-tapper (centrering + rotations-indexering)
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
// Radial position: midt i ring-gabet — ADAPTIV, følger cup-størrelsen
hose_pass_x = cup_diameter / 2 + ring_gap / 2;

// Refill-åbning i flangen ved 270° — samme radiale position som slangerne
refill_opening_x = hose_pass_x;
refill_opening_d = min(20, ring_gap - 2);   // 18mm ved ring_gap=20

// Kabel-slids i flangen ved 90° — åben mod kanten så kabler med stik kan
// lægges i fra siden ved montering
cable_slot_w = 8;

// (Rotations-indexering er slået sammen med centrering — se rim_tab_*
//  parametrene ovenfor. De 4 asymmetriske rim-tapper klarer begge dele.)

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
echo("=== GreenThumbs CAD params (variant A, adaptiv diameter) ===");
echo("cup_size:", cup_size);
echo("cup_diameter:", cup_diameter, "mm");
echo("cup_height:", cup_height, "mm");
echo("ring_gap (fast):", ring_gap, "mm");
echo("water_zone_h:", water_zone_h, "mm");
echo("reservoir_capacity (BEREGNET):", reservoir_capacity_ml, "ml");
echo("reservoir_height (BEREGNET):", reservoir_height, "mm");
echo("reservoir_outer_d (BEREGNET):", reservoir_outer_d, "mm");
echo("flange_outer_d (BEREGNET):", flange_outer_d, "mm");
echo("total_stack_height (ca.):",
     ebase_lid_height + ebase_height + reservoir_height + top_ring_height, "mm");
echo("--- Pyntepotte-krav: indre diameter >=", flange_outer_d + 4,
     "mm, hoejde ca.", ebase_lid_height + ebase_height + reservoir_height, "mm ---");
