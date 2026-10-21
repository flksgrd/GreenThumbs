// =============================================================================
// Ladebase — konisk sæde + lomme til Apple MagSafe-lader (ADR 013)
// =============================================================================
// Tårnet løftes ud af pyntepotten og stilles på basen. Bay'ens 45°-fas glider
// ned i det koniske sæde og centrerer Qi-modtageren (midt i bay-gulvet) over
// MagSafe-laderen med ±0,5mm. Laderen stikker 0,1mm op, så tårnets gulv
// hviler direkte på den: afstand spole-til-spole ≈ bay'ens 1,2mm Qi-gulv.
//
//   - Lomme til laderen, udskubningshul nedenunder (tryk den op nedefra)
//   - Kabel-kanal radialt ud (base_cable_angle): gennemgående inde i sædet, åben
//     nedad under kanten → kablet ligger under basen
//   - Alle synlige kanter afrundet; 45° fas forneden mod elephant foot
//
// PRINT: PETG eller PLA, upright, 15% infill. Ingen support (sædet er en
// opadvendt 45°-kegle).
// =============================================================================

include <params.scad>

z_seat = base_puck_floor + magsafe_t - magsafe_proud;   // sædets gulv
r_flat = tower_d / 2 - bay_chamfer + base_clear;        // hvor fasen starter
r_lip  = tower_d / 2 + base_clear;
r_out  = r_lip + base_wall;
h_rim  = z_seat + bay_chamfer - 1;                      // kanten under fasens top

module charging_base() {
    difference() {
        rotate_extrude($fn = 240) base_profile();

        // Lomme til MagSafe-laderen + 0,6mm indføringsfas
        translate([0, 0, base_puck_floor])
            cylinder(d = magsafe_d + 0.5, h = h_rim, $fn = 160);
        translate([0, 0, z_seat - 0.6])
            cylinder(d1 = magsafe_d + 0.5, d2 = magsafe_d + 1.7, h = 0.61, $fn = 160);

        // Udskubningshul
        translate([0, 0, -1]) cylinder(d = 20, h = base_puck_floor + 2, $fn = 64);

        // Kabel-kanal radialt ud
        rotate([0, 0, base_cable_angle])
            translate([magsafe_d / 2 - 3, -magsafe_cable_w / 2, -1])
                cube([r_out, magsafe_cable_w, z_seat + 1]);
    }
}

// Tværsnit (r, z). Spejles om aksen før afrundingen, så offset() ikke
// trækker profilen væk fra aksen; derefter klippes den rette halvdel ud.
module base_profile() {
    pts = [[0, 0], [r_out, 0], [r_out, h_rim], [r_lip - 1, h_rim],
           [r_flat, z_seat], [0, z_seat]];
    intersection() {
        union() {
            // Runder alle konvekse hjørner
            offset(r = base_round) offset(delta = -base_round)
                full_section(pts);
            // Bunden: skarp kant med 45° fas i stedet for runding (printbar)
            intersection() {
                full_section(chamfer_bottom(pts, 0.8));
                translate([-r_out - 1, 0]) square([2 * r_out + 2, base_round]);
            }
        }
        translate([0, -1]) square([r_out + 1, h_rim + 2]);
    }
}

module full_section(pts) {
    polygon(pts);
    mirror([1, 0]) polygon(pts);
}

// Erstatter yderste bundhjørne med en 45° fas
function chamfer_bottom(pts, c) =
    concat([pts[0], [pts[1][0] - c, 0], [pts[1][0], c]],
           [for (i = [2 : len(pts) - 1]) pts[i]]);

charging_base();
