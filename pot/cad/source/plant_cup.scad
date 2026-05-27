// =============================================================================
// Plant Cup — Inner pot der holder jord + plante
// =============================================================================
// Skiftelig pr. plantestørrelse via cup_size i params.scad ("S" | "M" | "L").
// Hviler med top-flange på reservoirens top-ring. Drænhuller i bund leder
// overskydende vand ned i reservoirens bund-niche (fordamper, recirkuleres ikke).
//
// PRINT: PETG (PLA degraderer i vand over tid). Print upright. Brim på bund.
// Drænhullerne er 4mm → bridges fint uden support på Prusa XL med PETG-profil.
// =============================================================================

include <params.scad>

module plant_cup() {
    difference() {
        // ─── Solid body ─────────────────────────────────────────────────────
        union() {
            // Hovedkop
            cylinder(d = cup_diameter, h = cup_height);

            // Top-flange (hviler på reservoir top-ring)
            translate([0, 0, cup_height - top_ring_height])
                cylinder(d = cup_diameter + 2 * top_ring_width,
                         h = top_ring_height);
        }

        // ─── Subtractions ───────────────────────────────────────────────────
        // Indvendig hulrum
        translate([0, 0, cup_wall])
            cylinder(d = cup_diameter - 2 * cup_wall,
                     h = cup_height + 1);

        // Drænhuller i bund (hex-mønster: 1 center + 6 ring)
        drain_holes();

        // Pumpe-slange entry: hul i side nær toppen for vand-tilførsel
        // Slangen kommer op fra reservoir og dripper ned på jorden.
        translate([cup_diameter / 2 - cup_wall - 1, 0, cup_height - 15])
            rotate([0, 90, 0])
                cylinder(d = pump_port_d,
                         h = cup_wall + 4,
                         center = true);

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
    // Center
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
