// =============================================================================
// Assembly Check — visualisering af hele stakken (Variant A, zero-penetration)
// =============================================================================
// Genbrugelig preview-fil med flere view-modes. Vælg view med -D:
//
//   openscad -D 'view="section"' -o out.png assembly_check.scad
//
// Views:
//   "iso"       hel samling udefra, ¾-vinkel (default)
//   "section"   halv-snit forfra — viser vand-zone, ring-gab, nedsænket cup
//   "top"       set lige oppefra — flangens åbninger (slange/kabel/refill)
//   "exploded"  eksploderet stack — alle dele adskilt lodret
//   "reservoir" reservoir alene, skråt ned i — ribber, float-klips, overflow
//   "ebase"     electronics base + lid udefra — glands og drain
//
// Farver: grøn=cup, blå=reservoir, cyan=vand, grå=ebase, mørkegrå=lid,
//         rød=overflow-markør, brun=wick
// =============================================================================

include <params.scad>
use <reservoir.scad>
use <plant_cup.scad>
use <electronics_base.scad>

view = "iso";  // override med -D

// ─── Placeringshøjder ────────────────────────────────────────────────────────
z_lid   = 0;
z_ebase = ebase_lid_height;
z_res   = z_ebase + ebase_height;
// -0.05: marginal interpenetration mellem flange og rim, så STL-eksport af
// visualiseringen ikke får coincident faces (ren PNG-preview er upåvirket)
z_cup   = z_res + reservoir_height - (cup_height - top_ring_height) - 0.05;

// ─── Helpers ─────────────────────────────────────────────────────────────────
module half() {
    difference() {
        children();
        translate([-300, -600, -50]) cube([600, 600, 600]);
    }
}

module stack(explode = 0) {
    // Lid (mørkegrå) — pump-mount bosses opad
    color("dimgray")
        translate([0, 0, z_lid])
            electronics_base_lid();

    // Electronics base (grå)
    color("gray")
        translate([0, 0, z_ebase + explode])
            electronics_base();

    // Reservoir (blå)
    color("steelblue", 0.9)
        translate([0, 0, z_res + 2 * explode])
            reservoir();

    // Vand (cyan) — op til overflow-niveau (max-fill)
    color("cyan", 0.45)
        translate([0, 0, z_res + 2 * explode + reservoir_wall])
            cylinder(d = reservoir_inner_d,
                     h = overflow_z - reservoir_wall);

    // Overflow-markør (rød skive udenpå væggen ved 270°)
    color("red")
        translate([0, 0, z_res + 2 * explode + overflow_z])
            rotate([0, 0, 270])
                translate([reservoir_outer_d / 2, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(d = overflow_hole_d + 4, h = 1.5);

    // Plant cup (grøn)
    color("yellowgreen", 0.95)
        translate([0, 0, z_cup + 3 * explode])
            plant_cup();

    // Wick (brun) — fra cup-bund ned i vandet
    color("peru")
        translate([0, 0, z_res + 2 * explode + reservoir_wall + 1])
            cylinder(d = 4, h = water_zone_h + 2 * explode);
}

// ─── View dispatch ───────────────────────────────────────────────────────────
if (view == "iso") {
    stack();
} else if (view == "section") {
    half() stack();
} else if (view == "top") {
    stack();
} else if (view == "exploded") {
    stack(explode = 45);
} else if (view == "reservoir") {
    // Halv-snit så indvendige features ses: strip-ribber (0°),
    // float-klips (90°), overflow-hul (270°), index-tap (315°).
    // +100° rotation lægger ribber, overflow og tap i den synlige halvdel;
    // float-klipsen (lille radius) ligger tæt nok på snitplanet til at ses.
    half() rotate([0, 0, 100]) color("steelblue") reservoir();
} else if (view == "ebase") {
    color("gray") electronics_base();
    translate([ebase_outer_d + 25, 0, 0])
        color("dimgray") electronics_base_lid();
} else {
    echo("Ukendt view — brug iso|section|top|exploded|reservoir|ebase");
}
