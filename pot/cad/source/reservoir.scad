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
//    0°: lomme UDEN PÅ væggen til USB-C-forlængerens hun-ende (ADR 013) —
//        stikket flugter med rimmen, flangen har et hak ovenover
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
        // kun cup'ens Ø30 refill-kanal — de smallere kanaler blokerer).
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

        usbc_sleeve();

        // (Rim-tapper fjernet — ADR 010: orientering låses af strip-
        //  ribberne i refill-kanalen, centrering af 1mm kant-clearance.)
    }
}

// USB-C-lomme uden på væggen: åben top (stikket flugter med rimmen), hylde
// forneden med kabel-slids åben udad. 45° fas under → printes uden support.
module usbc_sleeve() {
    ro  = reservoir_outer_d / 2;
    cw  = usbc_body_t + 2 * print_tolerance;     // hulrum radialt
    cl  = usbc_body_w + 2 * print_tolerance;     // hulrum tangentielt
    d   = cw + 2 * usbc_sleeve_wall;             // lommens dybde ud fra væggen
    w   = cl + 2 * usbc_sleeve_wall;
    z0  = reservoir_height - usbc_body_l - usbc_sleeve_wall;
    rotate([0, 0, usbc_angle])
        difference() {
            hull() {
                translate([ro - 0.5, -w / 2, z0])
                    cube([d + 0.5, w, reservoir_height - z0]);
                translate([ro - 0.5, -w / 2, z0 - d])
                    cube([0.5, w, 0.01]);
            }
            // Hulrum til stikket
            translate([ro + usbc_sleeve_wall, -cl / 2, z0 + usbc_sleeve_wall])
                cube([cw, cl, usbc_body_l + 1]);
            // Kabel-slids i hylden, åben udad
            translate([ro + usbc_sleeve_wall + cw / 2 - 2.5, -2.5, z0 - d - 1])
                cube([d, 5, d + usbc_sleeve_wall + 2]);
        }
}

// Render reservoir når filen åbnes direkte
reservoir();
