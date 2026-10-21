// =============================================================================
// Pot-Orchid assembly — visualisering af hele stakken (ADR 011)
// =============================================================================
//   openscad -D 'view="section"' -o out.png assembly.scad
//
// Views:
//   "iso"       hel samling, lager fuldt (hvile-tilstand)
//   "section"   halv-snit, hvile-tilstand: vandet i lageret, kammeret tomt
//   "soaking"   halv-snit under soak: kammeret oversvømmet til max soak,
//               lageret tilsvarende tømt
//   "top"       set oppefra — flangens kanal-åbninger
//   "exploded"  dele adskilt lodret
//
// Farver: klar PETG = halvgennemsigtig hvid, opak = grå, vand = cyan,
//         skakt = orange-markeret, Grove-sensor = grøn plade
// =============================================================================

include <params.scad>
use <ebase_orchid.scad>
use <storage.scad>
use <soak_chamber.scad>
use <orchid_cup.scad>

view = "iso";

floor_top_hi = soak_floor_t + floor_slope;

z_lid     = 0;
z_ebase   = ebase_lid_height;
z_storage = z_ebase + ebase_height;
z_chamber = z_storage + storage_height;            // soak-gulv hviler på rimmen
z_rim     = z_chamber + floor_top_hi + chamber_height;
z_cup     = z_rim - (cup_height - top_ring_height);

clear  = [0.85, 0.93, 1.0, 0.35];
opaque = [0.45, 0.47, 0.5];
water  = [0.2, 0.75, 0.95, 0.55];

module half() {
    // Snit-kuben må ikke omslutte kameraet — så fejler OpenCSG-previewet
    difference() { children(); translate([-400, -300, -50]) cube([800, 300, 800]); }
}

// Vandmængder i de to tilstande (cylinder-approksimation til visualisering)
storage_area = PI * pow(storage_inner_d / 2, 2);
storage_level_soaking = storage_water_h - soak_volume_ml * 1000 / storage_area;

module grove_board() {
    R = chamber_inner_d / 2;
    color([0.1, 0.55, 0.25])
        rotate([0, 0, ch_sensor_angle])
            translate([R - grove_wall_gap - grove_t, -grove_w / 2, z_chamber + soak_floor_t])
                cube([grove_t, grove_w, grove_h]);
}

// Snittet lægges om HVER del (inden for color()) — OpenCSG-previewet anvender
// ikke en difference der ligger uden om farvede, halvgennemsigtige objekter.
module cut(on) { if (on) half() children(); else children(); }

module stack(explode = 0, soaking = false, sec = false) {
    color(opaque) cut(sec) translate([0, 0, z_lid]) ebase_orchid_lid();
    color(opaque) cut(sec) translate([0, 0, z_ebase + explode]) ebase_orchid();
    color(opaque) cut(sec) translate([0, 0, z_storage + 2 * explode]) storage();
    color(clear)  cut(sec) translate([0, 0, z_chamber + 3 * explode]) soak_chamber();
    color(clear)  cut(sec) translate([0, 0, z_cup + 4 * explode]) orchid_cup();
    if (explode == 0) grove_board();

    // Vand i lageret
    color(water) cut(sec)
        translate([0, 0, z_storage + 2 * explode + storage_wall])
            cylinder(d = storage_inner_d - 0.5,
                     h = soaking ? storage_level_soaking : storage_water_h);

    // Vand i soak-kammeret (kun under soak)
    if (soaking)
        color(water) cut(sec)
            translate([0, 0, z_chamber + soak_floor_t])
                cylinder(d = chamber_inner_d - 0.5,
                         h = floor_top_hi - soak_floor_t + max_soak_level);
}

if (view == "iso")           stack();
else if (view == "section")  stack(sec = true);
else if (view == "soaking")  stack(soaking = true, sec = true);
else if (view == "top")      stack();
else if (view == "exploded") stack(explode = 40);
else echo("Ukendt view — brug iso|section|soaking|top|exploded");
