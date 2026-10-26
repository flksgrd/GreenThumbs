// =============================================================================
// Pumpe-vugge — holder Kamoer NKP-DC-S10B liggende i bay'en (ADR 012)
// =============================================================================
// Pumpen ligger med motoraksen langs y, hovedet (plast) mod Qi-spolen (+y)
// og slangerne ud foroven. Hovedet står på bay-gulvet; motoren ligger i to
// 90°-V-sadler og spændes fast med en kabelstrip om hver sadel. En V tager
// enhver motor-Ø fra ~20 til ~30mm — tallene i params.scad er skøn, så mål
// motorens Ø og aksens højde over hovedets bund før print.
//
// Vuggen sættes ned over to pinde på bay-gulvet (ingen huller i gulvet) og
// sikres med en dråbe lim eller tynd dobbeltklæbende tape.
//
// PRINT: PETG (eller TPU for mindre vibrationsstøj), bundpladen nedad.
// V-fladerne er 45° → ingen support. Strip-tunnelen er en 4mm bro.
// =============================================================================

include <params.scad>

r         = nkp_motor_d / 2;
v_clear   = 0.2;                                    // luft i V'en
apex_z    = nkp_axis_h - (r + v_clear) * sqrt(2);   // V'ens bund over gulvet
contact_z = nkp_axis_h - r / sqrt(2);               // hvor motoren rører V'en
block_h   = contact_z + 3;

module pump_cradle() {
    difference() {
        union() {
            translate([-cradle_w / 2, cradle_y0, 0])
                cube([cradle_w, cradle_y1 - cradle_y0, cradle_t]);
            for (sy = [cradle_s1, cradle_s2])
                translate([-cradle_w / 2, sy - 4, 0]) cube([cradle_w, 8, block_h]);
        }
        for (sy = [cradle_s1, cradle_s2]) {
            // 90°-V langs motoraksen
            translate([0, sy, 0]) rotate([90, 0, 0])
                linear_extrude(height = 10, center = true)
                    polygon([[0, apex_z], [-40, apex_z + 40], [40, apex_z + 40]]);
            // Strip-tunnel på tværs, under motoren
            translate([-cradle_w / 2 - 1, sy - tie_w / 2, max(apex_z, 0) + 1.2])
                cube([cradle_w + 2, tie_w, 2]);
        }
        // Huller til pindene på bay-gulvet
        for (px = [-9, 9])
            translate([px, cradle_pin_y, -1])
                cylinder(d = cradle_pin_d + 0.5, h = cradle_t + 2, $fn = 32);
    }
}

pump_cradle();
