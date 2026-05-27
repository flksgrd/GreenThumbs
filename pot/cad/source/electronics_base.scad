// =============================================================================
// Electronics Base — Vandtæt kammer for elektronik + pumpe
// =============================================================================
// Cylindrisk kammer der sidder under reservoir. Indeholder:
//   - XIAO ESP32-C6
//   - MOSFET + buck-converter + PD-trigger på prototype board
//   - Peristaltisk pumpe (slangen passerer gennem reservoir, pumpen er HER)
//
// Top mod reservoir har O-ring groove for vandtæt seal.
// Adgang sker via aftageligt låg i BUNDEN (lid skrues på med M3-skruer).
// Cable glands i siden til USB-C og sensor-wires.
//
// PRINT: PETG, 40% infill, 3mm vægge. Print upright (open bund-side ned).
// =============================================================================

include <params.scad>

// ─── Hoveddel: electronics base (cylinder med bund åben) ────────────────────
module electronics_base() {
    difference() {
        union() {
            // Hoved-cylinder
            cylinder(d = ebase_outer_d, h = ebase_height);

            // Indvendige mounting bosses til lid-skruer (M3 heat-set inserts)
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a])
                    translate([ebase_outer_d / 2 - ebase_wall - 4, 0, 0])
                        cylinder(d = 9, h = 12);
            }
        }

        // ─── Subtractions ───────────────────────────────────────────────────
        // Indvendig hulrum (åben mod bunden, lukket mod toppen bortset fra port)
        translate([0, 0, -0.5])
            cylinder(d = ebase_outer_d - 2 * ebase_wall,
                     h = ebase_height - ebase_wall + 0.5);

        // O-ring/gasket groove på TOPpen (mod reservoir bund)
        gasket_groove_top();

        // Cable glands gennem side-væg (2x, modsat hinanden)
        for (i = [0, 180]) {
            rotate([0, 0, i])
                translate([0, 0, ebase_height / 2])
                    rotate([0, 90, 0])
                        cylinder(d = gland_hole_d,
                                 h = ebase_outer_d + 4,
                                 center = true);
        }

        // Pump output port (slange går fra pumpe op gennem top → ind i reservoir)
        // Placeret så det matcher pump_port-hullet i reservoir bund
        rotate([0, 0, 180])
            translate([ebase_outer_d / 4, 0, ebase_height - ebase_wall - 0.5])
                cylinder(d = pump_port_d + 1,
                         h = ebase_wall + 1);

        // M3 insert-huller i mounting bosses
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a])
                translate([ebase_outer_d / 2 - ebase_wall - 4, 0, -0.5])
                    cylinder(d = m3_insert_d, h = m3_insert_h + 1);
        }

        // Drænhul i siden lige over bunden (fail-safe ved lækage)
        // Pegger nedad så vand kan løbe ud
        translate([0, 0, 3])
            rotate([0, 90, 0])
                cylinder(d = drain_hole_d,
                         h = ebase_outer_d + 2,
                         center = true);
    }
}

// O-ring groove på toppen af base — for 2mm O-ring eller EPDM-foam strip
module gasket_groove_top() {
    groove_d_outer = ebase_outer_d - 2 * gasket_groove_offset;
    translate([0, 0, ebase_height - gasket_groove_d])
        difference() {
            cylinder(d = groove_d_outer, h = gasket_groove_d + 0.1);
            cylinder(d = groove_d_outer - 2 * gasket_groove_w,
                     h = gasket_groove_d + 1);
        }
}

// ─── Aftageligt låg (skrues på bunden af electronics_base) ──────────────────
module electronics_base_lid() {
    difference() {
        cylinder(d = ebase_outer_d, h = ebase_lid_height);

        // Gennemgående huller til M3-skruer (M3 cap head fra undersiden)
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a]) {
                // Skrue clearance hole
                translate([ebase_outer_d / 2 - ebase_wall - 4, 0, -0.5])
                    cylinder(d = 3.4, h = ebase_lid_height + 1);

                // Countersink for M3 cap head
                translate([ebase_outer_d / 2 - ebase_wall - 4, 0, -0.1])
                    cylinder(d = m3_screw_head_d, h = 3);
            }
        }
    }
}

// ─── Render begge dele ved siden af hinanden når filen åbnes direkte ────────
electronics_base();

translate([ebase_outer_d + 20, 0, 0])
    electronics_base_lid();
