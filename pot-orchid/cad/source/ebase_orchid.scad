// =============================================================================
// Electronics base (orkide) — vandtæt kammer under lageret (ADR 011)
// =============================================================================
// Som pot/'s electronics_base, men:
//   - bredere (base_outer_d) og højere (KPHM200-pumpen er større)
//   - toppen har ét hul: den tørre skakt fra lageret munder ud her; slanger
//     og kabler kommer ned gennem den — ingen side-glands til dem
//   - kun USB-C panel-mount i siden (0°) + drænhul (45°)
//
// TODO (næste iteration): pumpe-mount til Kamoer KPHM200 + H-bro (DRV8871)
// når pumpens faktiske mål kendes; stænk-hætte på skaktens top.
//
// PRINT: opak PETG, upright (åben bund ned).
// =============================================================================

include <params.scad>

boss_r = ebase_outer_d / 2 - ebase_wall - 4;

module ebase_orchid() {
    difference() {
        union() {
            difference() {
                cylinder(d = ebase_outer_d, h = ebase_height);
                translate([0, 0, -0.5])
                    cylinder(d = ebase_outer_d - 2 * ebase_wall,
                             h = ebase_height - ebase_wall + 0.5);
                // USB-C panel-mount (placeholder-hul)
                translate([0, 0, ebase_height / 2])
                    rotate([0, 90, 0])
                        cylinder(d = usb_hole_d, h = ebase_outer_d / 2 + 2);
                // Drænhul mellem bosserne
                rotate([0, 0, 45])
                    translate([0, 0, 3])
                        rotate([0, 90, 0])
                            cylinder(d = drain_hole_d, h = ebase_outer_d / 2 + 2);
                // Skaktens munding
                rotate([0, 0, ch_conduit_angle])
                    translate([conduit_r, 0, ebase_height - ebase_wall - 1])
                        cylinder(d = conduit_id, h = ebase_wall + 2);
            }
            for (a = [0, 90, 180, 270])
                rotate([0, 0, a + 22.5])
                    translate([boss_r, 0, 0])
                        cylinder(d = 9, h = 12);
        }
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a + 22.5])
                translate([boss_r, 0, -0.5])
                    cylinder(d = m3_insert_d, h = m3_insert_h + 1);
    }
}

module ebase_orchid_lid() {
    difference() {
        cylinder(d = ebase_outer_d, h = ebase_lid_height);
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a + 22.5]) {
                translate([boss_r, 0, -0.5])
                    cylinder(d = 3.4, h = ebase_lid_height + 1);
                translate([boss_r, 0, -0.1])
                    cylinder(d = m3_screw_head_d, h = 3);
            }
    }
}

ebase_orchid();
translate([ebase_outer_d + 20, 0, 0]) ebase_orchid_lid();
