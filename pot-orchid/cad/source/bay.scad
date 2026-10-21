// =============================================================================
// Bay — elektronik + batteri i bunden af tårnet (ADR 012, ADR 013)
// =============================================================================
// Åben top: tankens gulv er loftet. Tanken hviler på randen og centreres af
// en krave udenfor. Indhold: 2× 18650 (1S2P), Kamoer NKP-pumpe, XIAO ESP32-C6,
// DRV8871 H-bro, boost 3.7→12V, berøringsfri "skål tom"-sensor limet op under
// skålens bund (måler gennem tank-gulvet).
//
// Bunden har 45° fas, så tårnet står på pyntepottens buede bund.
//
// Ladning (ADR 013): Qi-spolen ligger i en lomme midt i gulvet (tyndt gulv
// under den); USB-C-kablet kommer ned fra skakten i tanken (60°).
//
// TODO: pumpe-beslag (NKP-mål ikke verificeret) — skal holdes uden for
// Qi-lommen og ≥10mm fra spolen (metal).
//
// PRINT: opak PETG, upright.
// =============================================================================

include <params.scad>

R  = tower_d / 2;
H  = bay_h;
ch = bay_chamfer;
w  = bay_wall;
ft = bay_floor_t;

collar_r_in  = R + print_tolerance;
collar_r_out = collar_r_in + 1.5;

module bay() {
    difference() {
        union() {
            rotate_extrude()
                polygon([[0, 0], [R - ch, 0], [R, ch], [R, H], [0, H]]);
            // Krave: 45° fas forneden → printbar uden support
            rotate_extrude()
                polygon([[R - 0.1, H - 3 - (collar_r_out - R)],
                         [collar_r_out, H - 3],
                         [collar_r_out, H + collar_h],
                         [collar_r_in, H + collar_h],
                         [collar_r_in, H],
                         [R - 0.1, H]]);
        }
        // Hulrum (væggen følger fasen)
        rotate_extrude()
            polygon([[0, ft], [R - ch - w + ft, ft], [R - w, ch + 1.1],
                     [R - w, H + 1], [0, H + 1]]);
        // Qi-lomme: tyndt gulv under modtager-spolen
        translate([-qi_w / 2, -qi_l / 2, qi_floor_t])
            cube([qi_w, qi_l, ft]);
    }
    battery_cradle();
}

// To 18650-celler side om side (1S2P), holdt af to sadler
module battery_cradle() {
    y0 = cradle_y;
    for (sx = [-1, 1])
        translate([sx * (cell_l / 2 - 10), 0, 0])
            difference() {
                translate([-3, y0 - cell_d - 3, ft - 0.01])
                    cube([6, 2 * cell_d + 6, cell_d / 2 + 1]);
                for (sy = [-1, 1])
                    translate([-5, y0 + sy * (cell_d / 2 + 0.5), ft + cell_d / 2 + 0.5])
                        rotate([0, 90, 0])
                            cylinder(d = cell_d + 0.6, h = 10);
            }
}

bay();
