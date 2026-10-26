// =============================================================================
// Ladebase — bakke til tårnets fod + lomme til Apple MagSafe-lader (ADR 013)
// =============================================================================
// Tårnet løftes ud af pyntepotten og stilles i bakken. Foden (Ø152) centreres
// af bakkens væg (±0,5mm), og nøgle-ribben på foden glider ned i slidsen, så
// Qi-spolen (off-center i bay'en) står lige over MagSafe-laderen. Laderen
// stikker 0,1mm op, så foden hviler direkte på den: afstand spole-til-spole
// ≈ bay'ens 1,2mm Qi-gulv.
//
//   - Lomme til laderen, udskubningshul nedenunder (tryk den op nedefra)
//   - Kabel-kanal fra laderen ud gennem væggen, åben nedad under væggen
//   - Synlige kanter afrundet; 45° fas forneden mod elephant foot
//
// PRINT: PETG eller PLA, upright, 15% infill. Ingen support.
// =============================================================================

include <params.scad>

z_seat = base_puck_floor + magsafe_t - magsafe_proud;   // bakkens gulv
r_in   = foot_d / 2 + base_clear;
r_out  = r_in + base_wall;
h_rim  = z_seat + base_wall_h;

module charging_base() {
    difference() {
        rotate_extrude($fn = 240) base_profile();

        translate([0, qi_cy, 0]) {
            // Lomme til MagSafe-laderen + 0,6mm indføringsfas
            translate([0, 0, base_puck_floor])
                cylinder(d = magsafe_d + 0.5, h = h_rim, $fn = 160);
            translate([0, 0, z_seat - 0.6])
                cylinder(d1 = magsafe_d + 0.5, d2 = magsafe_d + 1.7, h = 0.61, $fn = 160);
            // Udskubningshul
            translate([0, 0, -1]) cylinder(d = 20, h = base_puck_floor + 2, $fn = 64);
            // Kabel-kanal ud gennem væggen
            rotate([0, 0, base_cable_angle])
                translate([magsafe_d / 2 - 3, -magsafe_cable_w / 2, -1])
                    cube([r_out, magsafe_cable_w, z_seat + 1]);
        }

        // Slids til nøgle-ribben (ydre hud bevares → intet hul udadtil)
        rotate([0, 0, key_angle])
            translate([r_in - 0.5, -(key_w + 1) / 2, z_seat])
                cube([key_t + 1, key_w + 1, h_rim]);
    }
}

// Tværsnit (r, z). Spejles om aksen før afrundingen, så offset() ikke
// trækker profilen væk fra aksen; derefter klippes den rette halvdel ud.
module base_profile() {
    pts = [[0, 0], [r_out, 0], [r_out, h_rim], [r_in, h_rim],
           [r_in, z_seat], [0, z_seat]];
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
