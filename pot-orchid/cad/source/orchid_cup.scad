// =============================================================================
// Orkide-cup — klar PETG, bark-medium, scalloped (ADR 010 + 011)
// =============================================================================
// Hænger fra flangen i soak-kammeret. Vandes UDELUKKENDE nedefra: under en
// soak stiger vandet op gennem bund-hullerne og side-slidserne og trækkes ud
// igen når pumpen tømmer kammeret. Ingen dyse-hul — ingen top-vanding.
//
// Klar cup: Phalaenopsis-rødder laver fotosyntese, og du kan se rodsundhed og
// om barken er tør (AOS: flertallet af avlere i Taiwan/Holland bruger klare
// potter).
//
// Kanaler (skal flugte med soak-kammerets faste features):
//    90°: sensor (Grove i ribber)       Ø32
//   180°: tør skakt + slange A til sump  Ø40
//  270°: påfyldnings-rør                 Ø32
//
// PRINT: klar PETG, upright, ingen support. Klarhed: høj temperatur, lav
// hastighed, 100% infill i vægge (2.4mm = 6 perimetre).
// =============================================================================

include <params.scad>

module channel_cutouts_2d(extra = 0) {
    for (c = [[ch_sensor_angle, ch_sensor_d],
              [ch_conduit_angle, ch_conduit_d],
              [ch_refill_angle, ch_refill_d]])
        rotate(c[0])
            translate([cup_diameter / 2, 0])
                circle(d = c[1] + extra);
}

module cup_profile_2d() {
    difference() {
        circle(d = cup_diameter);
        channel_cutouts_2d();
    }
}

// Er vinkel a tæt på en kanal? (så springes side-slidsen over)
function near_channel(a) =
    min([for (c = [ch_sensor_angle, ch_conduit_angle, ch_refill_angle])
         abs(((a - c + 540) % 360) - 180)]) < side_slot_skip;

module orchid_cup() {
    difference() {
        union() {
            linear_extrude(height = cup_height)
                cup_profile_2d();

            // Flange: kanalerne klippes til kammerets indervæg, så alt
            // der rager op (Grove-printplade) kan passere
            translate([0, 0, cup_height - top_ring_height])
                linear_extrude(height = top_ring_height)
                    difference() {
                        circle(d = flange_outer_d);
                        intersection() {
                            channel_cutouts_2d(extra = 1);
                            circle(d = chamber_inner_d - 1);
                        }
                    }
        }

        // Hulrum
        translate([0, 0, cup_wall])
            linear_extrude(height = cup_height)
                offset(r = -cup_wall)
                    cup_profile_2d();

        // Bund-drænhuller: center + 6 + 12
        bottom_holes();

        // Side-aerations-slidser i den nederste del (også vand-indløb ved soak)
        for (a = [side_slot_step / 2 : side_slot_step : 360])
            if (!near_channel(a))
                rotate([0, 0, a])
                    translate([cup_diameter / 2 - cup_wall - 1,
                               -side_slot_w / 2, side_slot_z0])
                        cube([cup_wall + 2, side_slot_w, side_slot_h]);
    }
}

module bottom_holes() {
    translate([0, 0, -0.5])
        cylinder(d = cup_drain_hole_d, h = cup_wall + 1);
    for (ring = [[cup_diameter * 0.17, 6], [cup_diameter * 0.33, 12]])
        for (i = [0 : ring[1] - 1])
            rotate([0, 0, i * 360 / ring[1] + 15])
                translate([ring[0], 0, -0.5])
                    cylinder(d = cup_drain_hole_d, h = cup_wall + 1);
}

orchid_cup();
