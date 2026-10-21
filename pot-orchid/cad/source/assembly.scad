// =============================================================================
// Pot-Orchid v1 assembly (ADR 012)
// =============================================================================
//   openscad -D 'view="section"' -o out.png assembly.scad
//
// Views:
//   "iso"       hele tårnet + dyrkningspotte, pyntepotten som skygge
//   "section"   halvsnit i hvile: vandet i lager-ringen, skålen tom
//   "soaking"   halvsnit under soak: skålen fyldt til kanten, ringen sænket
//   "top"       oppefra — kun planten i potten + ring-låget ses
//   "exploded"  dele adskilt lodret
//
// Farver: opak PETG = grå, vand = cyan, dyrkningspotte = grøn,
//         pyntepotte = svag terrakotta-skygge, sensor = orange,
//         USB-C-stik = sort, Qi-spole = lilla
// =============================================================================

include <params.scad>
use <bay.scad>
use <tank.scad>
use <lid.scad>

view = "iso";

z_tank = bay_h;
z_lid  = bay_h + ring_wall_h;
z_pot  = bay_h + z_pot_bottom;

opaque   = [0.45, 0.47, 0.5];
water    = [0.2, 0.75, 0.95, 0.55];
potcol   = [0.55, 0.75, 0.45, 0.6];
cachecol = [0.75, 0.45, 0.3, 0.18];

// Snit-kuben må ikke omslutte kameraet (OpenCSG-preview fejler så)
module half() {
    difference() { children(); translate([-400, -300, -50]) cube([800, 300, 800]); }
}
module cut(on) { if (on) half() children(); else children(); }

module nursery_pot() {
    difference() {
        cylinder(r1 = pot_r(0), r2 = pot_r(pot_h), h = pot_h);
        translate([0, 0, 1.2])
            cylinder(r1 = pot_r(0) - 1, r2 = pot_r(pot_h) - 1, h = pot_h);
    }
}

// Pyntepotte: vandret bund, indvendig Ø210, ydre højde 200 (anslået)
module cachepot() {
    translate([0, 0, -(200 - cachepot_inner_h)])
        difference() {
            cylinder(d = cachepot_inner_d + 10, h = 200);
            translate([0, 0, 200 - cachepot_inner_h])
                cylinder(d = cachepot_inner_d, h = 201);
        }
}

ring_area          = ring_capacity_ml * 1000 / (ring_overflow_z - tank_floor_t);
ring_level_rest    = float_full_z - tank_floor_t;
ring_level_soaking = ring_level_rest - soak_volume_ml * 1000 / ring_area;

module ring_water(level) {
    translate([0, 0, z_tank + tank_floor_t])
        difference() {
            cylinder(r = ring_outer_r - 0.3, h = level);
            translate([0, 0, -1])
                cylinder(r1 = bowl_r_in_bottom + bowl_wall + 0.3,
                         r2 = bowl_r_in_top + bowl_wall + 0.3, h = bowl_rim_z);
            rotate([0, 0, conduit_angle]) translate([conduit_r, 0, -1])
                cylinder(d = conduit_od + 0.6, h = level + 2);
            rotate([0, 0, usbc_angle]) translate([usbc_tube_r, 0, -1])
                cylinder(d = usbc_tube_od + 0.6, h = level + 2);
        }
}

module bowl_water() {
    translate([0, 0, z_tank + tank_floor_t])
        cylinder(r1 = bowl_r_in_bottom - 0.3, r2 = bowl_r_in_top - 0.3,
                 h = bowl_rim_z - tank_floor_t);
}

module stack(explode = 0, soaking = false, sec = false, ghost = false) {
    color(opaque) cut(sec) bay();
    color(opaque) cut(sec) translate([0, 0, z_tank + explode]) tank();
    color(opaque) cut(sec) translate([0, 0, z_lid + 2 * explode]) ring_lid();
    color(potcol) cut(sec) translate([0, 0, z_pot + 3 * explode]) nursery_pot();

    if (explode == 0) {
        color(water) cut(sec) ring_water(soaking ? ring_level_soaking : ring_level_rest);
        if (soaking) color(water) cut(sec) bowl_water();
        // "Skål tom"-sensor limet op under skålens sump
        color([0.95, 0.55, 0.1]) rotate([0, 0, hose_ch_angle])
            translate([bowl_r_in_bottom - 14, -14, z_tank - 12]) cube([28, 28, 12]);
        // USB-C hun-ende i skaktens top (flugter med låget)
        color([0.1, 0.1, 0.1]) rotate([0, 0, usbc_angle])
            translate([usbc_tube_r - usbc_body_t / 2, -usbc_body_w / 2,
                       z_lid + lid_t - 25])
                cube([usbc_body_t, usbc_body_w, 25]);
        // Qi-modtager i bay-gulvets lomme
        color([0.6, 0.3, 0.8]) translate([-23, -18, qi_floor_t])
            cube([46, 36, 1.5]);
    }
    if (ghost) color(cachecol) cut(sec) cachepot();
}

if (view == "iso")           stack(ghost = true);
else if (view == "section")  stack(sec = true, ghost = true);
else if (view == "soaking")  stack(soaking = true, sec = true, ghost = true);
else if (view == "top")      stack(ghost = true);
else if (view == "exploded") stack(explode = 45);
else echo("Ukendt view — brug iso|section|soaking|top|exploded");
