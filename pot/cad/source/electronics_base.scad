// =============================================================================
// Electronics Base — Vandtæt kammer for elektronik + pumpe
// =============================================================================
// Cylindrisk kammer der sidder under reservoir. Indeholder:
//   - XIAO ESP32-C6 + AHT20 + buzzer
//   - MOSFET + buck-converter + PD-trigger på prototype board
//   - Pumpe monteret på lid'ets indvendige side (DUAL FOOTPRINT:
//     Kamoer KPP peristaltisk ELLER Bartels BP7 piezo + driver — se
//     docs/research/piezo-components.md)
//
// Top mod reservoir har O-ring groove for vandtæt seal.
// Adgang sker via aftageligt låg i BUNDEN (lid skrues på med M3-skruer).
// Cable glands i siden til USB-C og sensor-wires.
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

                // Cable glands gennem side-væg (2x, modsat hinanden)
                for (i = [0, 180]) {
                    rotate([0, 0, i])
                        translate([0, 0, ebase_height / 2])
                            rotate([0, 90, 0])
                                cylinder(d = gland_hole_d,
                                         h = ebase_outer_d + 4,
                                         center = true);
                }

                // Pump output port — lodret gennem top, flugter med
                // reservoir-bundens port (fælles pump_port_x, audit-fix)
                rotate([0, 0, 180])
                    translate([pump_port_x, 0, ebase_height - ebase_wall - 0.5])
                        cylinder(d = pump_port_d + 1,
                                 h = ebase_wall + 1);

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
// Lid'ets TOP-side (indvendig når monteret) bærer pump-mount bosserne.
module electronics_base_lid() {
    difference() {
        union() {
            cylinder(d = ebase_outer_d, h = ebase_lid_height);
            pump_mount_bosses();
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
    }
}

// ─── Dual-footprint pump mount (Kamoer KPP eller Bartels BP7) ───────────────
// Bosserne sidder centreret på lid'et — frit for lid-skruerne ved kanten.
//   - 2× boss på 46mm c-c (Kamoer flange, langs X)
//   - 4× boss i 24mm kvadrat (BP7 clamp-plade / mp-Lowdriver standoffs)
module pump_mount_positions() {
    // Kamoer KPP: 2 huller langs X
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

// ─── Render begge dele ved siden af hinanden når filen åbnes direkte ────────
electronics_base();

translate([ebase_outer_d + 20, 0, 0])
    electronics_base_lid();
