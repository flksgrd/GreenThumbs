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
// Flangen har to gennemføringer:
//   - Slange-hul ved 180° (over pump_port_x): pumpe-slangen kommer op
//     gennem ring-gabet og ind gennem flangen til cup-toppens side-hul
//   - Refill-åbning ved 270°: hæld vand direkte ned i ring-gabet
//     (flugter med reservoirens refill-notch)
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

        // Flange-gennemføring til slangen — ved 180° over pump_port_x
        // (samme vinkel som reservoir-bundens port, så slangen løber lige op)
        rotate([0, 0, 180])
            translate([pump_port_x, 0, cup_height - top_ring_height - 0.5])
                cylinder(d = pump_port_d + 2,
                         h = top_ring_height + 1);

        // Refill-åbning i flangen — ved 270° (flugter med reservoir-notch).
        // Vandkande-tud rammer hullet og vandet løber ned i ring-gabet.
        rotate([0, 0, 270])
            translate([refill_opening_x, 0,
                       cup_height - top_ring_height - 0.5])
                cylinder(d = refill_opening_d,
                         h = top_ring_height + 1);

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
