// =============================================================================
// Reservoir — Vand-beholder som plant cup hænger nedsænket i (Variant A)
// =============================================================================
// ZERO-PENETRATION (ADR 009): reservoiret har INGEN gennemføringer under
// vandlinjen — bunden og væggen under overflow-niveau er 100% tætte.
// Eneste hul er OVERFLOW-hullet (over max-fill, det er selve pointen).
// Slanger og kabler ruter gennem ring-gabet og cup-flangens åbninger.
//
// Features (vinkler jf. params.scad allokering / ADR 010 scalloped cup):
//   90°: float switch klips-ring i bunden (kabel op ad cup'ens kabel-kanal)
//  270°: to lodrette guide-ribber til water level strip — de stikker ind i
//        cup'ens brede REFILL-KANAL og fungerer samtidig som rotations-lås
//        (ribbe-spændet passer kun i den kanal) — plus overflow-hul i
//        væggen, 8mm under cup-bund-niveau
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

        // Water level strip guide-ribber ved 270° — inde i cup'ens
        // refill-kanal. Strippen skubbes ned mellem ribberne og hviler
        // mod indervæggen. Ribberne går i FULD højde op til rimmen:
        // de fungerer samtidig som rotations-lås (spændet ~26mm passerer
        // kun cup'ens Ø28 refill-kanal — de smallere kanaler blokerer).
        for (side = [-1, 1]) {
            rotate([0, 0, channel_refill_angle])
                translate([reservoir_inner_d / 2 - strip_rib_t,
                           side * (waterlevel_strip_w / 2 + print_tolerance
                                   + strip_rib_w / 2) - strip_rib_w / 2,
                           reservoir_wall])
                    cube([strip_rib_t, strip_rib_w,
                          reservoir_height - reservoir_wall]);
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

        // (Rim-tapper fjernet — ADR 010: orientering låses af strip-
        //  ribberne i refill-kanalen, centrering af 1mm kant-clearance.)
    }
}

// Render reservoir når filen åbnes direkte
reservoir();
