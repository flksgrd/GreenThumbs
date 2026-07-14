// =============================================================================
// Plant Cup — Inner pot der holder jord + plante (SCALLOPED, ADR 010)
// =============================================================================
// Skiftelig pr. plantestørrelse via cup_size i params.scad
// ("S" | "M" | "L" | "CUSTOM"). Cuppen fylder næsten hele reservoir-
// åbningen (1mm kant-clearance) — ring-gabet er erstattet af 3 lodrette
// SERVICE-KANALER: konkave cirkel-udskæringer i cup-kanten:
//
//    90°: KABEL-KANAL (Ø16) — soil/strip/float-kabler
//   180°: SLANGE-KANAL (Ø18) — suge + tryk (Ø6); trykslangens dyse-hul
//         sidder i kanal-fladen nær toppen
//   270°: REFILL-KANAL (Ø28) — påfyldning; reservoir-væggens strip-ribber
//         stikker ind i denne kanal
//
// ORIENTERING: strip-ribberne (spænd ~26mm) kan kun passere refill-kanalen
// (Ø28) — cuppen kan fysisk kun sænkes ned i ÉN rotation. Centrering
// klares af den tætte kant-clearance. (Ingen tapper/lommer nødvendige.)
//
// STACK VARIANT A: cuppen hænger fra sin top-flange på reservoir-rimmen.
// Cup-bunden ender water_zone_h over reservoir-bunden — vandet lever dér
// (aldrig i kanalerne over overflow-niveau). Wick (ADR 006) går gennem
// center-drænhullet ned i vandet.
//
// PRINT: PETG (PLA degraderer i vand over tid). Print upright. Brim på
// bund. Kanalernes konkave flader er lodrette — printer uden support.
// =============================================================================

include <params.scad>

// ─── 2D-profiler ─────────────────────────────────────────────────────────────

// Kanal-udskæringer: cirkler centreret PÅ cup-omkredsen
module channel_cutouts_2d(extra = 0) {
    rotate(channel_cable_angle)
        translate([cup_diameter / 2, 0])
            circle(d = channel_cable_d + extra);
    rotate(channel_hose_angle)
        translate([cup_diameter / 2, 0])
            circle(d = channel_hose_d + extra);
    rotate(channel_refill_angle)
        translate([cup_diameter / 2, 0])
            circle(d = channel_refill_d + extra);
}

// Cup-kroppens ydre tværsnit: cirkel minus kanaler
module cup_profile_2d() {
    difference() {
        circle(d = cup_diameter);
        channel_cutouts_2d();
    }
}

// ─── Hovedmodul ──────────────────────────────────────────────────────────────

module plant_cup() {
    difference() {
        union() {
            // Cup-krop: ekstruderet scalloped profil
            linear_extrude(height = cup_height)
                cup_profile_2d();

            // Top-flange: dækker reservoir-toppen; kanalerne fortsætter
            // gennem flangen men KLIPPES til reservoir-åbningen, så
            // påfyldt vand kun kan lande I reservoiret (ikke udenfor)
            translate([0, 0, cup_height - top_ring_height])
                linear_extrude(height = top_ring_height)
                    difference() {
                        circle(d = flange_outer_d);
                        intersection() {
                            channel_cutouts_2d(extra = 1);
                            circle(d = reservoir_inner_d - 1);
                        }
                    }
        }

        // Indvendig hulrum: samme scalloped profil, offset cup_wall indad.
        // offset(r=...) afrunder de indadgående hjørner ved kanalerne —
        // robust manifold og pænere print.
        translate([0, 0, cup_wall])
            linear_extrude(height = cup_height)
                offset(r = -cup_wall)
                    cup_profile_2d();

        // Drænhuller i bund (hex-mønster: 1 center + 6 ring)
        // Center-hullet bruges også til wick (ADR 006)
        drain_holes();

        // Trykslangens dyse-hul: radialt gennem slange-kanalens væg nær
        // toppen. Slangen kommer op ad kanalen og stikkes ind her —
        // dripper på jord-overfladen.
        rotate([0, 0, channel_hose_angle])
            translate([cup_diameter / 2 - channel_hose_d / 2 + cup_wall / 2,
                       0, cup_height - 15])
                rotate([0, 90, 0])
                    cylinder(d = pump_port_d,
                             h = cup_wall + 2,
                             center = true);

        // TODO v1.1: Soil sensor mount.
        // Sensor PCB (1.8mm tyk × 12mm bred) skal holdes med proben ned i
        // jord og elektronik op over jord-niveau. Cup-væggen (2.4mm) er for
        // tynd til en recessed slot uden at gå igennem. Mulige løsninger:
        //   (a) Ekstern boss på cup-væg med slot — bedst, men øger ydre Ø
        //   (b) Separat clip-on holder der printes uafhængigt og snap-fitter
        //       på top-flangen
        //   (c) Bare lade sensoren stå frit i jorden (simplest, ingen mount)
        // v1 bruger (c). Validér i prototype om sensoren behøver støtte.
    }
}

// Drænhuller: 1 center + 6 i en ring (hexagonal pattern)
module drain_holes() {
    // Center (også wick-gennemføring)
    translate([0, 0, -0.5])
        cylinder(d = cup_drain_hole_d, h = cup_wall + 1);

    // Ring af 6 huller
    ring_r = cup_diameter / 4;
    for (i = [0:5]) {
        rotate([0, 0, i * 60])
            translate([ring_r, 0, -0.5])
                cylinder(d = cup_drain_hole_d, h = cup_wall + 1);
    }
}

// Render plant cup når filen åbnes direkte
plant_cup();
