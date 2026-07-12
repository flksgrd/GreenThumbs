// =============================================================================
// Plant Cup — Inner pot der holder jord + plante
// =============================================================================
// Skiftelig pr. plantestørrelse via cup_size i params.scad ("S" | "M" | "L").
//
// STACK VARIANT A (valgt 2026-06): cuppen hænger NEDSÆNKET i reservoiret.
// Flangen dækker hele reservoir-toppen (flange_outer_d er ens for alle
// cup-størrelser), så enhver cup passer på samme reservoir. Cup-bunden
// ender water_zone_h over reservoir-bunden — vandet lever dér og i ringen
// omkring cuppen. Wick (ADR 006) går gennem center-drænhullet ned i vandet.
//
// Flangen har fire features (vinkler jf. params.scad allokering / ADR 009):
//   - Slange-åbning ved 180° (Ø14): BEGGE slanger (suge + tryk) ruter op
//     gennem ring-gabet og videre — trykslangen ind i cup-toppens side-hul,
//     sugeslangen ned igen på ydersiden til ebase
//   - Kabel-slids ved 90° (åben mod kanten): soil/strip/float-kabler
//     lægges i fra siden ved montering
//   - Refill-åbning ved 270°: hæld vand direkte ned i ring-gabet;
//     overflow-hullet sidder lodret under så overløb ses ved påfyldning
//   - Index-notch ved 315° i undersiden: griber reservoir-rimmens tap så
//     alle åbninger altid flugter med reservoirets features
//
// PRINT: PETG (PLA degraderer i vand over tid). Print upright. Brim på bund.
// Drænhullerne er 4mm → bridges fint uden support på Prusa XL med PETG-profil.
// =============================================================================

include <params.scad>

// Refill-åbning i flangen: dimensioneres efter ring-gabet (gap varierer
// med cup-størrelse: S=40mm, M=20mm, L=10mm). Min 2mm clearance til begge
// vægge. L-cup får dermed kun Ø8 — funktionelt med tynd tud eller tragt;
// fuld refill-tube er v1.1-feature.
ring_gap = (reservoir_inner_d - cup_diameter) / 2;
refill_opening_d = min(20, ring_gap - 2);
refill_opening_x = (cup_diameter / 2 + reservoir_inner_d / 2) / 2;

module plant_cup() {
    difference() {
        // ─── Solid body ─────────────────────────────────────────────────────
        union() {
            // Hovedkop
            cylinder(d = cup_diameter, h = cup_height);

            // Top-flange — dækker reservoir-toppen helt (variant A)
            translate([0, 0, cup_height - top_ring_height])
                cylinder(d = flange_outer_d, h = top_ring_height);
        }

        // ─── Subtractions ───────────────────────────────────────────────────
        // Indvendig hulrum
        translate([0, 0, cup_wall])
            cylinder(d = cup_diameter - 2 * cup_wall,
                     h = cup_height + 1);

        // Drænhuller i bund (hex-mønster: 1 center + 6 ring)
        // Center-hullet bruges også til wick (ADR 006)
        drain_holes();

        // Pumpe-slange entry: hul i cup-siden nær toppen
        // Slangen kommer op gennem ring-gabet → gennem flange-hullet →
        // ind her og dripper ned på jorden.
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

        // Refill-åbning i flangen — ved 270° (over overflow-hullet).
        // Vandkande-tud rammer hullet og vandet løber ned i ring-gabet.
        rotate([0, 0, 270])
            translate([refill_opening_x, 0,
                       cup_height - top_ring_height - 0.5])
                cylinder(d = refill_opening_d,
                         h = top_ring_height + 1);

        // Index-notch i flangens underside ved 315° — griber rimmens tap
        rotate([0, 0, 315])
            translate([reservoir_inner_d / 2 - index_tab_l / 2 - print_tolerance,
                       -(index_tab_w + 2 * print_tolerance) / 2,
                       cup_height - top_ring_height - 0.5])
                cube([index_tab_l + reservoir_wall + 2 * print_tolerance + 4,
                      index_tab_w + 2 * print_tolerance,
                      index_tab_h + print_tolerance + 0.5]);

        // TODO v1.1: Soil sensor mount.
        // Sensor PCB (1.8mm tyk × 12mm bred) skal holdes med proben ned i
        // jord og elektronik op over jord-niveau. Cup-væggen (2.4mm) er for
        // tynd til en recessed slot uden at gå igennem. Mulige løsninger:
        //   (a) Ekstern boss på cup-væg med slot — bedst, men øger ydre Ø
        //   (b) Separat clip-on holder der printes uafhængigt og snap-fitter
        //       på top-flangen
        //   (c) Bare lade sensoren stå frit i jorden (simplest, ingen mount)
        // v1 bruger (c). Validér i prototype om sensoren behøver mekanisk støtte.
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
