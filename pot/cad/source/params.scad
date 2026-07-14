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
// med indre mål Ø260×H230: flange Ø254 (3mm luft per side), total stak-
// højde ~229mm (flugter med pottens kant). Kapacitet ~1.35 L. Med
// scalloped-designet (ADR 010) er cuppen Ø230 — 46% mere jord-areal end
// det gamle ring-gab-design gav i samme potte.
custom_cup_diameter = 230;
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
// 2. Reservoir (Variant A: cup hænger nedsænket) — SCALLOPED CUP (ADR 010)
// ----------------------------------------------------------------------------
// Cuppen fylder næsten HELE reservoir-åbningen (kun 1mm kant-clearance).
// Ring-gabet er erstattet af 3 lodrette SERVICE-KANALER — konkave cirkel-
// udskæringer i cup-kanten med hver sin funktion (kabler/slanger/refill).
// Det maksimerer jord-arealet (~40% af tværsnittet var før spildt gab) og
// kanalerne selv låser orienteringen (se channel_* nedenfor).

cup_clearance = 1;               // kant-spillerum cup ↔ reservoir-indervæg
reservoir_wall = 3;              // tykkere end cup (vandtryk + stabilitet)
reservoir_inner_d = cup_diameter + 2 * cup_clearance;   // ADAPTIV
reservoir_outer_d = reservoir_inner_d + 2 * reservoir_wall;

// SERVICE-KANALER: cirkler centreret PÅ cup-omkredsen, skåret lodret ned
// gennem cup-krop + flange. Forskellige diametre → strip-ribberne på
// reservoir-væggen (ved 270°) kan KUN passere gennem den brede refill-
// kanal → cuppen kan kun sænkes ned i ÉN orientering. Centrering klares
// af den tætte kant-clearance.
channel_cable_angle  = 90;       // sensor-kabler (soil/strip/float)
channel_cable_d      = 16;
channel_hose_angle   = 180;      // 2× Ø6 slanger (suge + tryk)
channel_hose_d       = 18;
channel_refill_angle = 270;      // påfyldning + water-strip + ribber
channel_refill_d     = 28;       // ≥ strip-ribbe-spænd (~26mm) → unik lås

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

// Cup-flange: dækker hele reservoir-toppen (matchende sæt per størrelse).
// Kanalerne fortsætter op gennem flangen (klippet til reservoir-åbningen
// så påfyldt vand kun kan lande I reservoiret).
flange_outer_d = reservoir_outer_d + 2 * top_ring_width;

// ============================================================================
// ZERO-PENETRATION PRINCIP (ADR 009): INGEN huller under vandlinjen.
// Alle slanger + kabler ruter: op gennem SERVICE-KANALERNE i cup-kanten
// (ADR 010) → ned UDVENDIGT langs reservoiret → ind i ebase via side-glands.
//
// Vinkel-allokering (set oppefra, konsistent på tværs af alle dele):
//    0°: USB-C gland (ebase)
//   45°: drænhul (ebase, fri af bosses)
//   90°: KABEL-KANAL (cup) + float-klips (bund) + kabel-gland (ebase)
//  180°: SLANGE-KANAL (cup) + trykslange-hul i kanal-væg + PG9-gland (ebase)
//  270°: REFILL-KANAL (cup) + water-strip ribber (væg) + overflow-hul (væg)
//
// Orientering: strip-ribberne (spænd ~26mm) passerer kun refill-kanalen
// (Ø28) — kabel/slange-kanalerne (Ø16/18) er for smalle → kun ÉN rotation
// er fysisk mulig. Centrering: 1mm kant-clearance.
// ============================================================================

// Water level strip — holdes af to lodrette guide-ribber på indervæggen
// ved 270° (inde i refill-kanalen — strippen er vandtæt og måler jo netop
// vand, så påfyldnings-strømmen forbi den er uproblematisk).
// (IKKE en fræset slot: det skar gennem væggen = lækage. Audit-fix 2.)
waterlevel_strip_w = 18;
waterlevel_strip_t = 2;
waterlevel_strip_h = 50;         // dækker vand-zonen (0-40mm) + margin
strip_rib_w = 3;                 // ribbe-bredde (tangentielt)
strip_rib_t = 3;                 // ribbe-dybde (radialt, ind i kanal-rummet)

// Float switch — sidder i en print-integreret klips-ring i bunden.
// Kablet går op gennem vandet og op ad kabel-kanalen ved 90°.
float_switch_d = 16;             // typisk vertical float switch
float_switch_x = 30;             // offset fra center (under cuppen)
float_clip_h = 10;               // klips-ring højde
float_clip_wall = 2;

// Trykslangens dyse-hul i cup-væggen (i slange-kanalens flade, nær toppen)
pump_port_d = 7;                 // 4mm slange + tolerance


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
echo("=== GreenThumbs CAD params (variant A, scalloped cup ADR 010) ===");
echo("cup_size:", cup_size);
echo("cup_diameter:", cup_diameter, "mm");
echo("cup_height:", cup_height, "mm");
echo("kanaler (kabel/slange/refill):",
     channel_cable_d, "/", channel_hose_d, "/", channel_refill_d, "mm");
echo("water_zone_h:", water_zone_h, "mm");
echo("reservoir_capacity (BEREGNET):", reservoir_capacity_ml, "ml");
echo("reservoir_height (BEREGNET):", reservoir_height, "mm");
echo("reservoir_outer_d (BEREGNET):", reservoir_outer_d, "mm");
echo("flange_outer_d (BEREGNET):", flange_outer_d, "mm");
echo("total_stack_height (ca.):",
     ebase_lid_height + ebase_height + reservoir_height + top_ring_height, "mm");
echo("--- Pyntepotte-krav: indre diameter >=", flange_outer_d + 4,
     "mm, hoejde ca.", ebase_lid_height + ebase_height + reservoir_height, "mm ---");
