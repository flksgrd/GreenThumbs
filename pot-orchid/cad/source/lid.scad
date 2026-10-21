// =============================================================================
// Ring-låg — dækker lager-ringen og skålens kant (ADR 012)
// =============================================================================
// Hviler på ringens ydervæg med en læbe indenfor. Går fri af dyrkningspotten
// (2mm), så potten kan løftes op uden at fjerne låget. Påfyldningshul ved
// 270° direkte over ringen — man kan fylde på uden at løfte planten.
// USB-C-skakten (60°) stikker op gennem låget; låget kan stadig løftes af.
// Slanger går under låget fra skaktens top til skålens slange-kanal.
//
// PRINT: opak PETG, på HOVEDET (læben opad) — ingen support.
// =============================================================================

include <params.scad>

lip_t = 1.5;
lip_h = 3;

module ring_lid() {
    difference() {
        union() {
            cylinder(r = tower_d / 2, h = lid_t);
            // Læbe ned i ringen (centrerer låget)
            translate([0, 0, -lip_h])
                difference() {
                    cylinder(r = ring_outer_r - print_tolerance, h = lip_h);
                    translate([0, 0, -1])
                        cylinder(r = ring_outer_r - print_tolerance - lip_t, h = lip_h + 2);
                }
        }
        translate([0, 0, -lip_h - 1])
            cylinder(r = lid_inner_r, h = lid_t + lip_h + 2);
        // Frigang til USB-C-skakten (skakten går op gennem låget)
        rotate([0, 0, usbc_angle])
            translate([usbc_tube_r, 0, -lip_h - 1])
                cylinder(d = usbc_tube_od + 2 * print_tolerance, h = lid_t + lip_h + 2);
        // Påfyldningshul over ringen
        rotate([0, 0, refill_angle])
            translate([(bowl_r_in_top + bowl_wall + ring_outer_r) / 2, 0, -lip_h - 1])
                cylinder(d = refill_hole_d, h = lid_t + lip_h + 2);
    }
}

ring_lid();
