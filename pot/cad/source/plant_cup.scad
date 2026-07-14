// =============================================================================
// Plant Cup — Inner pot der holder jord + plante
// =============================================================================
// Skiftelig pr. plantestørrelse via cup_size i params.scad
// ("S" | "M" | "L" | "CUSTOM"). ADAPTIVT design: cup-diameteren driver hele
// stakkens diametre via fast ring_gap — reservoir + base er et matchende sæt.
//
// STACK VARIANT A: cuppen hænger NEDSÆNKET i reservoiret fra sin top-flange.
// Cup-bunden ender water_zone_h over reservoir-bunden — vandet lever dér
// (aldrig i ring-gabet, jf. overflow-hullet). Wick (ADR 006) går gennem
// center-drænhullet ned i vandet.
//
// Flange-features (vinkler jf. params.scad allokering / ADR 009):
//   - Slange-åbning ved 180° (Ø14): begge slanger (suge + tryk)
//   - Kabel-slids ved 90° (åben mod kanten): soil/strip/float-kabler
//   - Refill-åbning ved 270°: hæld vand ned i ring-gabet; overflow-hullet
//     sidder lodret under så overløb ses ved påfyldning
//   - RIM-TAB-LOMMER ved 30/150/210/315° i undersiden: griber reservoir-
//     rimmens fire tapper → centrering + rotations-indexering i ét.
//     Asymmetriske vinkler = flangen passer kun i ÉN orientering.
//
// PRINT: PETG (PLA degraderer i vand over tid). Print upright. Brim på bund.
// Drænhuller (4mm) printer uden support; lommerne er subtraktioner i
// flangens underside og koster intet print-mæssigt.
// =============================================================================

include <params.scad>

module plant_cup() {
    difference() {
            // ─── Solid body ─────────────────────────────────────────────────
            union() {
                // Hovedkop
                cylinder(d = cup_diameter, h = cup_height);

                // Top-flange — dækker reservoir-toppen helt
                translate([0, 0, cup_height - top_ring_height])
                    cylinder(d = flange_outer_d, h = top_ring_height);
            }

            // ─── Subtractions ───────────────────────────────────────────────
            // Indvendig hulrum
            translate([0, 0, cup_wall])
                cylinder(d = cup_diameter - 2 * cup_wall,
                         h = cup_height + 1);

            // Drænhuller i bund (hex-mønster: 1 center + 6 ring)
            // Center-hullet bruges også til wick (ADR 006)
            drain_holes();

            // Pumpe-slange entry: hul i cup-siden nær toppen
            translate([cup_diameter / 2 - cup_wall - 1, 0, cup_height - 15])
                rotate([0, 90, 0])
                    cylinder(d = pump_port_d,
                             h = cup_wall + 4,
                             center = true);

            // Slange-åbning i flangen ved 180° — plads til begge slanger
            rotate([0, 0, 180])
                translate([hose_pass_x, 0, cup_height - top_ring_height - 0.5])
                    cylinder(d = hose_pass_d,
                             h = top_ring_height + 1);

            // Kabel-slids ved 90° — åben mod flange-kanten så kabler med
            // JST-stik kan lægges i fra siden uden at trække stik igennem
            rotate([0, 0, 90])
                translate([cup_diameter / 2 + 2, -cable_slot_w / 2,
                           cup_height - top_ring_height - 0.5])
                    cube([flange_outer_d / 2 - cup_diameter / 2,
                          cable_slot_w, top_ring_height + 1]);

            // Refill-åbning i flangen — ved 270° (over overflow-hullet)
            rotate([0, 0, 270])
                translate([refill_opening_x, 0,
                           cup_height - top_ring_height - 0.5])
                    cylinder(d = refill_opening_d,
                             h = top_ring_height + 1);

            // Rim-tab-lommer i flangens underside (30/150/210/315°) —
            // griber reservoir-rimmens tapper. Tæt tolerance = centrering;
            // asymmetriske vinkler = kun én mulig orientering.
            for (a = rim_tab_angles)
                rotate([0, 0, a])
                    translate([reservoir_inner_d / 2 - print_tolerance,
                               -(rim_tab_w + 2 * print_tolerance) / 2,
                               cup_height - top_ring_height - 0.5])
                        cube([reservoir_wall + 2 * print_tolerance,
                              rim_tab_w + 2 * print_tolerance,
                              rim_tab_h + print_tolerance + 0.5]);

            // TODO v1.1: Soil sensor mount.
            // Sensor PCB (1.8mm tyk × 12mm bred) skal holdes med proben ned i
            // jord og elektronik op over jord-niveau. Cup-væggen (2.4mm) er for
            // tynd til en recessed slot uden at gå igennem. Mulige løsninger:
            //   (a) Ekstern boss på cup-væg med slot — bedst, men øger ydre Ø
            //   (b) Separat clip-on holder der printes uafhængigt og snap-fitter
            //       på top-flangen
            //   (c) Bare lade sensoren stå frit i jorden (simplest, ingen mount)
            // v1 bruger (c). Validér i prototype om sensoren behøver støtte.
    }
}

// Drænhuller: 1 center + 6 i en ring (hexagonal pattern)
module drain_holes() {
    // Center (også wick-gennemføring)
    translate([0, 0, -0.5])
        cylinder(d = cup_drain_hole_d, h = cup_wall + 1);

    // Ring af 6 huller
    ring_r = cup_diameter / 4;
    for (i = [0:5]) {
        rotate([0, 0, i * 60])
            translate([ring_r, 0, -0.5])
                cylinder(d = cup_drain_hole_d, h = cup_wall + 1);
    }
}

// Render plant cup når filen åbnes direkte
plant_cup();
