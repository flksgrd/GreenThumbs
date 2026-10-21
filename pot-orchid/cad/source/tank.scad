// =============================================================================
// Tank — konisk skål + lager-ring + tør skakt, ét print (ADR 012)
// =============================================================================
// Skålen holder dyrkningspotten. Ringen rundt om er lageret. Fælles gulv er
// barrieren mod elektronikken i bay'en nedenunder — ingen huller i det
// undtagen skaktens boring (som er tør).
//
// Soak-loft: skålens kant (bowl_rim_z) ligger LAVERE end ringens ydervæg.
// Fyldes skålen for meget, løber vandet over kanten og tilbage i ringen.
// Ringens max-niveau (overløb udad) ligger under skålens kant, så lageret
// aldrig kan løbe tilbage i skålen.
//
// Features:
//   180°: slange-kanal i skålens væg + sump i bunden (slange A)
//   160°: tør skakt fra bay'en op til over ringens max
//    60°: USB-C-skakt fra bay'en op gennem låget (ADR 013)
//   125°: to float-beslag på ydervæggen (lager lavt / lager fuldt)
//     0°: ring-overløb udad (sidste udvej)
//   Centreres af en krave på bay'ens rand (ingen lommer i vandbarrieren)
//
// PRINT: opak PETG, upright. Gulv 100% massivt (vandbarriere).
// =============================================================================

include <params.scad>

module tank() {
    difference() {
        union() {
            // Fælles gulv
            cylinder(r = tower_d / 2, h = tank_floor_t);

            // Ringens ydervæg
            difference() {
                cylinder(r = tower_d / 2, h = ring_wall_h);
                translate([0, 0, -1]) cylinder(r = ring_outer_r, h = ring_wall_h + 2);
            }

            // Skålens væg (konisk) + udbuling til slange-kanalen
            bowl_wall_solid();
            rotate([0, 0, hose_ch_angle])
                translate([bowl_r_in_bottom, -(hose_ch_w / 2 + bowl_wall), 0])
                    cube([bowl_r_in_top + hose_ch_depth + bowl_wall - bowl_r_in_bottom,
                          hose_ch_w + 2 * bowl_wall, bowl_rim_z]);

            // Tør skakt
            rotate([0, 0, conduit_angle])
                translate([conduit_r, 0, 0])
                    cylinder(d = conduit_od, h = conduit_top_z);

            // USB-C-skakt: op gennem ring-låget, top med slids til stikket
            rotate([0, 0, usbc_angle])
                translate([usbc_tube_r, 0, 0])
                    cylinder(d = usbc_tube_od, h = ring_wall_h + lid_t);

            float_brackets();
            feet_ribs();
        }

        // USB-C-skaktens boring (åben ned i bay'en) + slids i toppen
        rotate([0, 0, usbc_angle])
            translate([usbc_tube_r, 0, 0]) {
                translate([0, 0, -1])
                    cylinder(d = usbc_tube_id, h = ring_wall_h + lid_t - usbc_cap_t + 1);
                translate([0, 0, ring_wall_h + lid_t - usbc_cap_t - 1])
                    linear_extrude(height = usbc_cap_t + 2)
                        offset(r = 0.2)
                            square([usbc_body_t, usbc_body_w], center = true);
            }

        // Skålens hulrum
        translate([0, 0, tank_floor_t])
            cylinder(r1 = bowl_r_in_bottom, r2 = bowl_r_in_top,
                     h = bowl_rim_z - tank_floor_t + 0.01);
        translate([0, 0, bowl_rim_z - 0.01])
            cylinder(r = bowl_r_in_top, h = 1);

        // Slange-kanal (lodret, åben i toppen)
        rotate([0, 0, hose_ch_angle])
            translate([bowl_r_in_bottom - 2, -hose_ch_w / 2, tank_floor_t])
                cube([bowl_r_in_top + hose_ch_depth - bowl_r_in_bottom + 2,
                      hose_ch_w, bowl_rim_z]);

        // Sump i kanalens bund
        rotate([0, 0, hose_ch_angle])
            translate([bowl_r_in_bottom + 3, 0, tank_floor_t - sump_depth])
                cylinder(d = sump_d, h = sump_depth + 1);

        // Skaktens boring — gennem gulvet, åben ned i bay'en
        rotate([0, 0, conduit_angle])
            translate([conduit_r, 0, -1])
                cylinder(d = conduit_id, h = conduit_top_z + 2);

        // Ring-overløb udad
        rotate([0, 0, ring_overflow_angle])
            translate([0, 0, ring_overflow_z])
                rotate([0, 90, 0])
                    cylinder(d = ring_overflow_d, h = tower_d / 2 + 2);

    }
}

module bowl_wall_solid() {
    difference() {
        cylinder(r1 = bowl_r_in_bottom + bowl_wall, r2 = bowl_r_in_top + bowl_wall,
                 h = bowl_rim_z);
        translate([0, 0, -1])
            cylinder(r = bowl_r_in_bottom - 0.01, h = 1.01);
    }
}

// Radiale ribber på skålens bund — potten står på dem
module feet_ribs() {
    for (a = [30 : 60 : 330])
        rotate([0, 0, a])
            translate([12, -1, tank_floor_t - 0.01])
                cube([bowl_r_in_bottom - 13, 2, feet_h + 0.01]);
}

// To beslag på ringens ydervæg med Ø8.5-hul til en lodret mini-float (stammen
// skrues fast, flyderen hænger nedenunder). 45° fas forneden → ingen support.
module float_brackets() {
    for (zf = [float_low_z, float_full_z])
        rotate([0, 0, float_angle])
            difference() {
                hull() {
                    translate([ring_outer_r - float_arm_l, -float_arm_w / 2,
                               zf + float_hang])
                        cube([float_arm_l + 0.5, float_arm_w, float_arm_t]);
                    translate([ring_outer_r - 0.5, -float_arm_w / 2,
                               zf + float_hang - float_arm_l])
                        cube([1, float_arm_w, float_arm_l + float_arm_t]);
                }
                translate([ring_outer_r - float_hole_from_wall, 0, zf + float_hang - 1])
                    cylinder(d = float_hole_d, h = float_arm_t + 2);
            }
}

tank();
