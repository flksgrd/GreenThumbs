// =============================================================================
// Electronics Base — Vandtæt kammer for elektronik + pumpe
// =============================================================================
// Cylindrisk kammer der sidder under reservoir. Indeholder:
//   - ESP32-H2-Zero + AHT20 + buzzer (ADR 014)
//   - Switches + boost 12V på prototype board
//   - 2× 18650 (1S2P) i vugge på lid'et (ADR 013)
//   - Pumpe monteret på lid'ets indvendige side (DUAL FOOTPRINT:
//     Kamoer KXF-DC peristaltisk ELLER Bartels BP7 piezo + driver — se
//     docs/research/piezo-components.md)
//
// ZERO-PENETRATION (ADR 009): toppen er HELT lukket — reservoiret ovenpå
// har ingen bund-gennemføringer, så selv ved reservoir-lækage ned langs
// siderne er elektronikken beskyttet af den lukkede top + kant-O-ring.
// Alt (USB, kabler, slanger) kommer ind via side-glands:
//    0° Ø14 = USB-C-forlænger (han-stik igennem), 90° M12 = sensor-kabler,
//  180° M16 = 2× slanger. Qi-spolen ligger i en lomme i lid'et (ADR 013).
//
// Adgang sker via aftageligt låg i BUNDEN (lid skrues på med M3-skruer).
//
// AUDIT-FIX 2026-06: mounting bosses var tidligere i samme union som
// shell'en FØR cavity-subtraktionen — cavity-cylinderen åd bosserne så kun
// 0.5mm flager bestod. Nu: shell færdiggøres først (difference), bosses
// unions bagefter, insert-huller subtraheres til sidst.
//
// PRINT: PETG, 40% infill, 3mm vægge. Print upright (open bund-side ned).
// =============================================================================

include <params.scad>

// ─── Hoveddel: electronics base (cylinder med bund åben) ────────────────────
module electronics_base() {
    difference() {
        union() {
            // Shell: cylinder med cavity + alle gennemføringer subtraheret
            difference() {
                cylinder(d = ebase_outer_d, h = ebase_height);

                // Indvendig hulrum (åben mod bund, lukket top på nær port)
                translate([0, 0, -0.5])
                    cylinder(d = ebase_outer_d - 2 * ebase_wall,
                             h = ebase_height - ebase_wall + 0.5);

                // O-ring/gasket groove på TOPpen (mod reservoir bund)
                gasket_groove_top();

                // Cable glands gennem side-væg (zero-penetration, ADR 009:
                // toppen er nu HELT lukket — alt kommer ind fra siden).
                // Ø14 ved 0° (USB-C-forlænger) og M12 ved 90° (sensor-kabler):
                for (a = gland_angles) {
                    rotate([0, 0, a])
                        translate([0, 0, ebase_height / 2])
                            rotate([0, 90, 0])
                                cylinder(d = (a == usbc_angle) ? usbc_pass_d
                                                               : gland_hole_d,
                                         h = ebase_outer_d / 2 + 2);
                }
                // M16 ved 180° (2× Ø6 slanger — suge + tryk):
                rotate([0, 0, hose_gland_angle])
                    translate([0, 0, ebase_height / 2])
                        rotate([0, 90, 0])
                            cylinder(d = hose_gland_d,
                                     h = ebase_outer_d / 2 + 2);

                // Drænhul (fail-safe ved lækage) — roteret 45° så det går
                // MELLEM bosserne ved 0/90/180/270° (audit-fix)
                rotate([0, 0, 45])
                    translate([0, 0, 3])
                        rotate([0, 90, 0])
                            cylinder(d = drain_hole_d,
                                     h = ebase_outer_d + 2,
                                     center = true);
            }

            // Mounting bosses til lid-skruer — tilføjes EFTER cavity er
            // subtraheret, så de består i fuld størrelse
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a])
                    translate([ebase_outer_d / 2 - ebase_wall - 4, 0, 0])
                        cylinder(d = 9, h = 12);
            }
        }

        // M3 insert-huller i bosserne (fra bund-siden, hvor lid skrues på)
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a])
                translate([ebase_outer_d / 2 - ebase_wall - 4, 0, -0.5])
                    cylinder(d = m3_insert_d, h = m3_insert_h + 1);
        }
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
// Lid'ets TOP-side (indvendig når monteret) bærer pump-mount bosserne og
// batteri-vuggen (ADR 013).
module electronics_base_lid() {
    difference() {
        union() {
            cylinder(d = ebase_outer_d, h = ebase_lid_height);
            pump_mount_bosses();
            if (battery_fits) battery_cradle();
        }

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

        // M3 insert-huller i pump-mount bosserne (fra toppen)
        pump_mount_insert_holes();

        // Qi-lomme: tyndt gulv under modtager-spolen
        if (qi_fits)
            translate([-qi_w / 2, qi_center_y - qi_l / 2, qi_floor_t])
                cube([qi_w, qi_l, ebase_lid_height]);
    }
}

// ─── Dual-footprint pump mount (Kamoer KXF-DC eller Bartels BP7) ───────────────
// Bosserne sidder centreret på lid'et — frit for lid-skruerne ved kanten.
//   - 2× boss på 46mm c-c (Kamoer flange, langs X)
//   - 4× boss i 24mm kvadrat (BP7 clamp-plade / mp-Lowdriver standoffs)
module pump_mount_positions() {
    // Kamoer KXF-DC: 2 huller langs X
    for (dx = [-pump_mount_kamoer_spacing / 2, pump_mount_kamoer_spacing / 2])
        translate([dx, 0, 0]) children();

    // BP7/driver: 4 huller i kvadrat, roteret 90° (langs Y) så de ikke
    // falder sammen med Kamoer-hullerne
    for (dx = [-pump_mount_bp7_square / 2, pump_mount_bp7_square / 2])
        for (dy = [-pump_mount_bp7_square / 2, pump_mount_bp7_square / 2])
            translate([dx, dy, 0]) children();
}

module pump_mount_bosses() {
    translate([0, 0, ebase_lid_height - 0.01])
        pump_mount_positions()
            cylinder(d = pump_mount_boss_d, h = pump_mount_boss_h + 0.01);
}

module pump_mount_insert_holes() {
    translate([0, 0, ebase_lid_height + pump_mount_boss_h - m3_insert_h])
        pump_mount_positions()
            cylinder(d = m3_insert_d, h = m3_insert_h + 1);
}

// ─── Batteri-vugge (ADR 013): 2× 18650 side om side, to sadler ─────────────
module battery_cradle() {
    for (sx = [-1, 1])
        translate([sx * (cell_l / 2 - 10), 0, ebase_lid_height - 0.01])
            difference() {
                translate([-3, cradle_y - cell_d - 3, 0])
                    cube([6, 2 * cell_d + 6, cell_d / 2 + 1]);
                for (sy = [-1, 1])
                    translate([-5, cradle_y + sy * (cell_d / 2 + 0.5), cell_d / 2 + 0.5])
                        rotate([0, 90, 0])
                            cylinder(d = cell_d + 0.6, h = 10);
            }
}

// ─── Render begge dele ved siden af hinanden når filen åbnes direkte ────────
electronics_base();

translate([ebase_outer_d + 20, 0, 0])
    electronics_base_lid();
