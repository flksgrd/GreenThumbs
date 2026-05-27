// =============================================================================
// Reservoir — Vand-beholder under plant cup
// =============================================================================
// Cylindrisk vand-beholder med:
//   - Top-ring hvor plant cup's flange hviler
//   - Indvendig slot til kapacitiv water level strip (vertikal)
//   - Bund-niche til float switch (vertikal mount)
//   - Side-port til pumpens output-slange (ind i electronics base nedenunder)
//   - Refill-notch i top-rim til at hælde vand direkte i reservoir
//     (uden at flytte plant cup) — simpel v1-løsning.
//
// PRINT: PETG. 3 perimeters minimum. 100% bund. Print upright med brim.
// =============================================================================

include <params.scad>

module reservoir() {
    difference() {
        // ─── Solid outer body ───────────────────────────────────────────────
        cylinder(d = reservoir_outer_d, h = reservoir_height);

        // ─── Subtractions ───────────────────────────────────────────────────
        // Hovedhulrum (vand-volumen)
        translate([0, 0, reservoir_wall])
            cylinder(d = reservoir_inner_d,
                     h = reservoir_height + 1);

        // Water level strip slot (vertikal kanal indvendig)
        // Stripen presses ind herfra. Slot bunden 5mm over reservoir-bund.
        translate([reservoir_inner_d / 2 - waterlevel_strip_t,
                   -waterlevel_strip_w / 2 - print_tolerance / 2,
                   reservoir_wall + 5])
            cube([waterlevel_strip_t + reservoir_wall + 1,
                  waterlevel_strip_w + print_tolerance,
                  waterlevel_strip_h]);

        // Float switch niche (bund-monteret, lodret)
        // Roteret 90° fra water level strip så de ikke overlapper
        rotate([0, 0, 90])
            translate([float_switch_x, 0, reservoir_wall - 0.5])
                cylinder(d = float_switch_d + print_tolerance,
                         h = float_switch_h);

        // Pump output port (lodret hul gennem reservoir bund)
        // Pumpe sidder i electronics base nedenunder; slange går op herigennem
        // og videre til pump_port-hullet i plant cup
        rotate([0, 0, 180])
            translate([reservoir_inner_d / 4, 0, -0.5])
                cylinder(d = pump_port_d + 1,
                         h = reservoir_wall + 1);

        // Refill notch i top-rim
        // En lille udskæring så bruger kan hælde vand ned langs siden af
        // plant cup uden at løfte cup'en ud.
        refill_notch();
    }
}

// Refill notch: kile-formet udskæring i top-rim
module refill_notch() {
    notch_w = 15;        // bredde af notch (passer vandkande-tud)
    notch_d = 25;        // dybde ned i reservoir-væg
    notch_h = notch_d;   // højde af udskæringen i top

    rotate([0, 0, 270])
        translate([reservoir_outer_d / 2 - reservoir_wall / 2,
                   -notch_w / 2,
                   reservoir_height - notch_h + 0.1])
            cube([reservoir_wall + 1, notch_w, notch_h + 1]);
}

// Render reservoir når filen åbnes direkte
reservoir();
