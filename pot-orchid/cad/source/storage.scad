// =============================================================================
// Lager — opak vandreserve + tør skakt (ADR 011)
// =============================================================================
// Åbent kar (printes upright); soak-kammerets gulv er låget og hviler inde i
// kraven. Lageret har INGEN gennemføringer under vandlinjen ud mod elektronik
// eller omgivelser (ADR 009): den eneste vej ned i electronics base er den
// tørre skakt, hvis væg er en del af samme print og hvis top sidder over
// max soak-niveau.
//
// Features:
//    0°: overflow-hul UDAD — lageret kan aldrig fyldes så højt at vandet når
//        kraven, skaktens krave eller påfyldnings-røret (ingen tilbageløb op
//        i soak-kammeret ved overfyldning)
//  180°: tør skakt fra bunden (åben ned i ebase) op til over max soak; krave
//        med pakning som soak-gulvet hviler på
//  270°: float switch-klips i bunden (low-water); kabel op gennem
//        påfyldnings-røret
//
// PRINT: opak PETG, upright. Skaktens krave har 45° chamfer → ingen support.
// =============================================================================

include <params.scad>

collar_top_z = storage_height - conduit_gasket_t + conduit_gasket_squeeze;
collar_chamfer_h = (conduit_collar_d - conduit_od) / 2;
collar_flat_h = 2;

module storage() {
    difference() {
        union() {
            // Kar
            difference() {
                cylinder(d = base_outer_d, h = storage_height);
                translate([0, 0, storage_wall])
                    cylinder(d = storage_inner_d, h = storage_height);
            }

            // Krave på rimmen (soak-gulvet sidder indenfor)
            translate([0, 0, storage_height])
                difference() {
                    cylinder(d = base_outer_d, h = collar_h);
                    translate([0, 0, -1])
                        cylinder(d = base_outer_d - 2 * collar_t, h = collar_h + 2);
                }

            // Tør skakt + krave
            rotate([0, 0, ch_conduit_angle])
                translate([conduit_r, 0, 0]) {
                    cylinder(d = conduit_od, h = conduit_top_z);
                    translate([0, 0, collar_top_z - collar_flat_h - collar_chamfer_h])
                        cylinder(d1 = conduit_od, d2 = conduit_collar_d,
                                 h = collar_chamfer_h);
                    translate([0, 0, collar_top_z - collar_flat_h])
                        cylinder(d = conduit_collar_d, h = collar_flat_h);
                }

            // Float switch-klips
            rotate([0, 0, float_angle])
                translate([float_r, 0, storage_wall])
                    difference() {
                        cylinder(d = float_d + 2 * float_clip_wall + print_tolerance,
                                 h = float_clip_h);
                        translate([0, 0, -0.5])
                            cylinder(d = float_d + print_tolerance, h = float_clip_h + 1);
                        translate([0, -3, -0.5])
                            cube([float_d, 6, float_clip_h + 1]);
                    }
        }

        // Skaktens boring — helt igennem bunden, åben ned i electronics base
        rotate([0, 0, ch_conduit_angle])
            translate([conduit_r, 0, -1])
                cylinder(d = conduit_id, h = conduit_top_z + 2);

        // Overflow UDAD
        rotate([0, 0, storage_overflow_angle])
            translate([0, 0, storage_wall + storage_water_h])
                rotate([0, 90, 0])
                    cylinder(d = storage_overflow_d, h = base_outer_d / 2 + 2);
    }
}

storage();
