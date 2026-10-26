// =============================================================================
// Bay — elektronik + batteri i bunden af tårnet (ADR 012, ADR 013)
// =============================================================================
// Åben top: tankens gulv er loftet. Tanken hviler på randen og centreres af
// en krave udenfor.
//
// Form (målt pyntepotte 2026-10-26): de nederste 30mm er en FOD (Ø152), der
// står på bunden af pyntepottens udhulede bund (Ø160 × 28). En 45°-skulder
// fører ud til tårnets Ø180 og går fri af afsatsen. Foden centrerer tårnet.
//
// Layout i foden (set oppefra):
//          +y
//      ┌─ Qi-spole ─┐        Qi-lomme i gulvet (1,2mm gulv under spolen)
//   18650  ┌──────┐  18650   én celle på hver side af pumpen (1S2P)
//          │ NKP  │
//          │pumpe │          liggende; plast-hovedet mod spolen, motoren mod -y
//          └──────┘
//          -y   (nøgle-ribbe på ydersiden ved 270°)
// Elektronik (ESP32-H2-Zero, TP4056, boost, DRV8871) på en hylde ≥10mm over spolen.
// XKC-sensoren hænger under skålens sump ved 180°.
//
// TODO: pumpe-vugge (NKP-flangens huller ukendte → spændebånd om motoren)
//
// PRINT: opak PETG, upright. Skulderen er 45° → ingen support.
// =============================================================================

include <params.scad>

R  = tower_d / 2;
H  = bay_h;
w  = bay_wall;
ft = bay_floor_t;
rf = foot_d / 2;

collar_r_in  = R + print_tolerance;
collar_r_out = collar_r_in + 1.5;

module bay() {
    difference() {
        union() {
            rotate_extrude() outer_profile(H);
            // Krave: 45° fas forneden → printbar uden support
            rotate_extrude()
                polygon([[R - 0.1, H - 3 - (collar_r_out - R)],
                         [collar_r_out, H - 3],
                         [collar_r_out, H + collar_h],
                         [collar_r_in, H + collar_h],
                         [collar_r_in, H],
                         [R - 0.1, H]]);
            // Nøgle-ribbe på fodens yderside (passer i ladebasens slids)
            rotate([0, 0, key_angle])
                translate([rf - 0.5, -key_w / 2, 0])
                    cube([key_t + 0.5, key_w, key_h]);
        }
        // Hulrum: profilen forskudt en vægtykkelse ind (også langs skulderen),
        // åben i toppen
        rotate_extrude()
            intersection() {
                half_plane() offset(delta = -w) full_profile(H + 10);
                translate([0, ft]) square([R, H + 10]);
            }
        // Qi-lomme: tyndt gulv under modtager-spolen
        translate([-qi_w / 2, qi_cy - qi_l / 2, qi_floor_t])
            cube([qi_w, qi_l, ft]);
    }
    battery_cradles();
}

// Tårnets ydre tværsnit (r, z): fod → 45° skulder → fuld Ø
function profile_pts(h) = [[0, 0], [rf, 0], [rf, foot_h],
                           [R, shoulder_top], [R, h], [0, h]];
module outer_profile(h) polygon(profile_pts(h));
// Spejlet om aksen, så offset() ikke trækker profilen væk fra aksen
module full_profile(h) { polygon(profile_pts(h)); mirror([1, 0]) polygon(profile_pts(h)); }
module half_plane() intersection() { children(); translate([0, -1]) square([R + 1, H + 20]); }

// To sadler pr. celle; cellerne ligger langs y på hver side af pumpen
module battery_cradles() {
    for (sx = [-1, 1], yy = [cell_y0 + 10, cell_y0 + cell_l - 10])
        translate([sx * cell_x, yy, 0])
            difference() {
                translate([-cell_d / 2 - 2, -3, ft - 0.01])
                    cube([cell_d + 4, 6, cell_d / 2 + 1]);
                translate([0, -5, ft + cell_d / 2 + 0.5])
                    rotate([-90, 0, 0]) cylinder(d = cell_d + 0.6, h = 10);
            }
}

bay();
