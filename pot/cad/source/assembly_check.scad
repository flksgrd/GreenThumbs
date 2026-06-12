// Assembly-verifikation: cup nedsænket i reservoir (variant A, M-cup)
include <params.scad>
use <reservoir.scad>
use <plant_cup.scad>

module half(){ difference(){ children(); translate([-250,-500,-10]) cube([500,500,500]); } }

half() {
    color("steelblue") reservoir();
    // Cup placeret så flange-undersiden hviler på reservoir-rim:
    // flange-underside er ved (cup_height - top_ring_height) i cup-koordinater
    color("yellowgreen")
        translate([0, 0, reservoir_height - (cup_height - top_ring_height)])
            plant_cup();
    // Vand op til cup-bund-niveau
    color("cyan", 0.5)
        translate([0, 0, reservoir_wall])
            cylinder(d = reservoir_inner_d, h = water_zone_h - reservoir_wall);
}
