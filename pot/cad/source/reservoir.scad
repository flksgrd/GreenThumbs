// =============================================================================
// Reservoir — Vand-beholder som plant cup hænger nedsænket i (Variant A)
// =============================================================================
// ZERO-PENETRATION (ADR 009): reservoiret har INGEN gennemføringer under
// vandlinjen — bunden og væggen under overflow-niveau er 100% tætte.
// Eneste hul er OVERFLOW-hullet (over max-fill, det er selve pointen).
// Slanger og kabler ruter gennem ring-gabet og cup-flangens åbninger.
//
// Features (vinkler jf. params.scad allokering):
//    0°: to lodrette guide-ribber til water level strip (klemmes imellem)
//   90°: float switch klips-ring i bunden (kabel op gennem ring-gab)
//  270°: overflow-hul i væggen, 8mm under cup-bund-niveau
//  30/150/210/315°: rim-tapper — centrering + rotations-indexering
//  (asymmetriske vinkler → cup-flangen passer kun i én orientering)
//
// STACK VARIANT A: høj cylinder hvor cuppen hænger fra top-rimmen via sin
// flange. Vandet lever i zonen UNDER cup-bunden. Højde og kapacitet
// beregnes i params.scad (M-cup: ~199mm, ~815 ml til overflow-niveau).
//
// PRINT: PETG. 3 perimeters minimum. 100% bund. Print upright med brim.
// Høj print (~200mm) — Prusa XL klarer det fint; brug draft shield ved træk.
// =============================================================================

include <params.scad>

module reservoir() {
    union() {
        difference() {
            // ─── Solid outer body ───────────────────────────────────────────
            cylinder(d = reservoir_outer_d, h = reservoir_height);

            // Hovedhulrum (vand + plads til nedsænket cup)
            translate([0, 0, reservoir_wall])
                cylinder(d = reservoir_inner_d,
                         h = reservoir_height + 1);

            // Overflow-hul ved 270° — eneste hul, og det sidder BEVIDST
            // ved max-fill niveau (8mm under cup-bund). Overløb drypper
            // ud i pyntepotten, synligt fra refill-åbningen ovenover.
            rotate([0, 0, 270])
                translate([0, 0, overflow_z])
                    rotate([0, 90, 0])
                        cylinder(d = overflow_hole_d,
                                 h = reservoir_outer_d / 2 + 2);
        }

        // ─── Additive features (ingen af dem gennembryder væggen) ───────────

        // Water level strip guide-ribber ved 0°: strippen skubbes ned
        // mellem ribberne og hviler mod indervæggen. (Erstatter tidligere
        // gennemskåret slot = lækage-bug.)
        for (side = [-1, 1]) {
            rotate([0, 0, 0])
                translate([reservoir_inner_d / 2 - strip_rib_t,
                           side * (waterlevel_strip_w / 2 + print_tolerance
                                   + strip_rib_w / 2) - strip_rib_w / 2,
                           reservoir_wall])
                    cube([strip_rib_t, strip_rib_w,
                          waterlevel_strip_h + 10]);
        }

        // Float switch klips-ring i bunden ved 90° (åben ring, floaten
        // presses ned i). Kablet føres langs bunden ud til ring-gabet.
        rotate([0, 0, 90])
            translate([float_switch_x, 0, reservoir_wall])
                difference() {
                    cylinder(d = float_switch_d + 2 * float_clip_wall
                                 + print_tolerance,
                             h = float_clip_h);
                    translate([0, 0, -0.5])
                        cylinder(d = float_switch_d + print_tolerance,
                                 h = float_clip_h + 1);
                    // Kabel-udgang i klips-ringen (mod ring-gabet, +X lokal)
                    translate([0, -3, -0.5])
                        cube([float_switch_d, 6, float_clip_h + 1]);
                }

        // Rim-tapper: centrering + rotations-indexering i ét. Fire tapper
        // ved asymmetriske vinkler (30/150/210/315°) griber op i matchende
        // lommer i cup-flangens underside — cuppen kan kun sidde i ÉN
        // orientering og holdes præcist centreret. Tapperne sidder på
        // rim-bandet (inner→outer radius) og printer perfekt (peger op).
        for (a = rim_tab_angles)
            rotate([0, 0, a])
                translate([reservoir_inner_d / 2, -rim_tab_w / 2,
                           reservoir_height])
                    cube([reservoir_wall, rim_tab_w, rim_tab_h]);
    }
}

// Render reservoir når filen åbnes direkte
reservoir();
