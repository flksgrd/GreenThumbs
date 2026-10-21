// =============================================================================
// Soak-kammer — klar PETG-vase som orkide-cuppen hænger i (ADR 011)
// =============================================================================
// Oversvømmes til max_soak_level af den vendbare pumpe (forlæns fra lageret),
// står i soak-tiden, og tømmes igen (baglæns) via slange A i sumpen.
//
// Gulvet er også lagerets låg: gulv-skiven hviler inde i lagerets krave og på
// skaktens krave (med pakning). Gulvet hælder mod sumpen så pumpen kan tømme
// kammeret helt (rødder må ikke stå i vand).
//
// Features (vinkler jf. params.scad):
//    0°: overflow-hul UDAD ved max soak-niveau (fysisk loft, ADR 009-princip)
//   90°: to ribber med noter til Grove water level-sensoren
//  180°: hul i gulvet til den tørre skakt (skakten er del af lageret)
//  194°: sump — laveste punkt, slange A's ende (med si) ligger her
//  270°: påfyldnings-rør fra gulvet til rimmen, åbent ned i lageret
//
// PRINT: upright. Gulvet (de første soak_floor_t + floor_slope mm) i OPAK
// PETG, derefter filamentskift (M600 / Prusa XL værktøjsskift) til KLAR
// PETG for væggene — så lys ikke når lageret (alger).
// =============================================================================

include <params.scad>

floor_top_hi = soak_floor_t + floor_slope;     // gulv-top på den høje side
wall_top     = floor_top_hi + chamber_height;   // rim
floor_disk_d = base_outer_d - 2 * collar_t - 2 * print_tolerance;

module soak_chamber() {
    difference() {
        union() {
            // Gulv-skive (dækker hele lageret, også skulderen uden for kammeret)
            cylinder(d = floor_disk_d, h = soak_floor_t);

            // Kammer-væg
            difference() {
                cylinder(d = chamber_outer_d, h = wall_top);
                translate([0, 0, soak_floor_t])
                    cylinder(d = chamber_inner_d, h = wall_top);
            }

            sloped_floor();
            refill_tube();
            grove_ribs();
        }

        // Sump i gulvet
        rotate([0, 0, sump_angle])
            translate([sump_r, 0, soak_floor_t - sump_depth])
                cylinder(d = sump_d, h = floor_top_hi);

        // Hul til den tørre skakt (skakten selv tilhører lageret)
        rotate([0, 0, ch_conduit_angle])
            translate([conduit_r, 0, -1])
                cylinder(d = conduit_od + 2 * print_tolerance, h = floor_top_hi + 2);

        // Påfyldnings-rørets boring — gennem gulvet, åben ned i lageret
        rotate([0, 0, ch_refill_angle])
            translate([refill_r, 0, -1])
                cylinder(d = refill_id, h = wall_top + 2);

        // Overflow UDAD ved max soak-niveau
        rotate([0, 0, soak_overflow_angle])
            translate([0, 0, floor_top_hi + max_soak_level])
                rotate([0, 90, 0])
                    cylinder(d = soak_overflow_d, h = chamber_outer_d / 2 + 2);

        // Noter i Grove-ribberne
        grove_grooves();
    }
}

// Kile inde i kammeret: høj på den modsatte side af sumpen, lav ved sumpen
module sloped_floor() {
    theta = atan(floor_slope / chamber_inner_d);
    intersection() {
        cylinder(d = chamber_inner_d + 0.2, h = floor_top_hi);
        translate([0, 0, soak_floor_t + floor_slope / 2])
            rotate([0, 0, sump_angle])
                rotate([0, theta, 0])
                    translate([-500, -500, -1000])
                        cube([1000, 1000, 1000]);
    }
}

// Påfyldnings-rør: 1mm under rimmen så flangen ikke hviler på det
module refill_tube() {
    rotate([0, 0, ch_refill_angle])
        translate([refill_r, 0, 0])
            cylinder(d = refill_od, h = wall_top - 1);
}

// To ribber ved 90° — printpladen sidder grove_wall_gap fra væggen
module grove_ribs() {
    R  = chamber_inner_d / 2;
    hw = grove_w / 2;
    rotate([0, 0, ch_sensor_angle])
        for (s = [-1, 1])
            translate([R - rib_depth,
                       s > 0 ? hw - groove_bite : -(hw + rib_solid),
                       soak_floor_t])
                cube([rib_depth + 0.5, groove_bite + rib_solid,
                      wall_top - soak_floor_t - 1]);
}

module grove_grooves() {
    R  = chamber_inner_d / 2;
    hw = grove_w / 2;
    r_out = R - grove_wall_gap;              // pladens yderside
    r_in  = r_out - grove_t;                 // pladens inderside
    rotate([0, 0, ch_sensor_angle])
        translate([r_in - print_tolerance,
                   -(hw + print_tolerance),
                   soak_floor_t])
            cube([grove_t + 2 * print_tolerance,
                  grove_w + 2 * print_tolerance,
                  wall_top]);
}

soak_chamber();
