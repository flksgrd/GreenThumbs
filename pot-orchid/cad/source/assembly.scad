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
//   "charging"  halvsnit: tårnet på ladebasen med MagSafe-laderen
//   "base"      ladebasen alene med MagSafe-laderen
//
// Farver: opak PETG = grå, vand = cyan, dyrkningspotte = grøn,
//         pyntepotte = svag terrakotta-skygge, sensor = orange,
//         USB-C-stik = sort, Qi-spole = lilla, pumpe = blå/grå, celler = grøn
// =============================================================================

include <params.scad>
use <bay.scad>
use <tank.scad>
use <lid.scad>
use <charging_base.scad>

view = "iso";

z_tank = bay_h;
z_lid  = bay_h + ring_wall_h;
z_pot  = bay_h + z_pot_bottom;

opaque   = [0.45, 0.47, 0.5];
water    = [0.2, 0.75, 0.95, 0.55];
potcol   = [0.55, 0.75, 0.45, 0.6];
cachecol = [0.75, 0.45, 0.3, 0.18];
basecol  = [0.82, 0.78, 0.7];

// Snit-kuben må ikke omslutte kameraet eller ligge tæt på det (near-plane
// klipper forsiden → OpenCSG trækker ikke fra). y ≥ -150 dækker tårnet (r 95).
module half() {
    difference() { children(); translate([-400, -150, -50]) cube([800, 150, 800]); }
}
module cut(on) { if (on) half() children(); else children(); }

module nursery_pot() {
    difference() {
        cylinder(r1 = pot_r(0), r2 = pot_r(pot_h), h = pot_h);
        translate([0, 0, 1.2])
            cylinder(r1 = pot_r(0) - 1, r2 = pot_r(pot_h) - 1, h = pot_h);
    }
}

// Pyntepotte (målt): udhulet bund Ø160×28, afsats, Ø200 → Ø210 ved kanten.
// z = 0 er bunden af fordybningen = tårnets fod.
module cachepot() {
    difference() {
        translate([0, 0, -6]) cylinder(d = cachepot_inner_d + 12, h = cachepot_inner_h + 6);
        cachepot_inside();
    }
}
module cachepot_inside() {
    translate([0, 0, -0.01]) cylinder(d = cachepot_recess_d, h = cachepot_recess_h + 0.02);
    translate([0, 0, cachepot_recess_h])
        cylinder(d1 = cachepot_ledge_d, d2 = cachepot_inner_d, h = cachepot_ledge_z + 1);
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
        color([0.6, 0.3, 0.8]) translate([-23, qi_cy - 18, qi_floor_t])
            cube([46, 36, 1.5]);
        cut(sec) bay_contents();
    }
    if (ghost) color(cachecol) cut(sec) cachepot();
}

if (view == "iso")           stack(ghost = true);
else if (view == "section")  stack(sec = true, ghost = true);
else if (view == "soaking")  stack(soaking = true, sec = true, ghost = true);
else if (view == "top")      stack(ghost = true);
else if (view == "exploded") stack(explode = 45);
else if (view == "charging") {
    zb = base_puck_floor + magsafe_t;            // tårnet hviler på laderen
    color(basecol) half() charging_base();
    half() magsafe();
    translate([0, 0, zb]) stack(sec = true);
}
else if (view == "base") { color(basecol) charging_base(); magsafe(); }
else echo("Ukendt view — brug iso|section|soaking|top|exploded|charging|base");

// Pumpe (hoved blå, motor grå) og 18650-celler — som keep-out
module bay_contents() {
    // Plast-hovedet mod Qi-spolen (+y), motoren (metal + magneter) væk fra den
    translate([0, pump_cy, bay_floor_t]) {
        color([0.2, 0.4, 0.85]) translate([-pump_w / 2, pump_l / 2 - 27, 0])
            cube([pump_w, 27, pump_h]);
        color([0.7, 0.7, 0.72]) translate([0, -pump_l / 2, pump_h / 2])
            rotate([-90, 0, 0]) cylinder(d = 28, h = pump_l - 27);
    }
    for (sx = [-1, 1])
        color([0.2, 0.6, 0.35]) translate([sx * cell_x, cell_y0, bay_floor_t + cell_d / 2 + 0.5])
            rotate([-90, 0, 0]) cylinder(d = cell_d, h = cell_l);
}

// MagSafe-lader (hvid flade, aluminium-side) + kabel ud i kanalen
module magsafe() {
    translate([0, qi_cy, base_puck_floor]) {
        color([0.75, 0.76, 0.78]) cylinder(d = magsafe_d, h = magsafe_t - 0.6, $fn = 120);
        color([0.97, 0.97, 0.97]) translate([0, 0, magsafe_t - 0.6])
            cylinder(d = magsafe_d, h = 0.6, $fn = 120);
        color([0.95, 0.95, 0.95]) rotate([0, 0, base_cable_angle])
            translate([magsafe_d / 2 - 1, 0, magsafe_t / 2])
                rotate([0, 90, 0]) cylinder(d = 3.5, h = 140, $fn = 24);
    }
}
