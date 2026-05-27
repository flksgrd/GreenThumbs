// =============================================================================
// Load Cell Mount — Vægt-platform under hele krukken (OPTIONAL)
// =============================================================================
// OPTIONAL hardware: kun nødvendigt hvis du vil bruge orkide-profilen
// (DETECT_WEIGHT) eller HYBRID-mode på succulenter. For Monstera/Peace Lily/
// store jord-baserede planter kan du SKIPPE denne del og bare sætte stick-on
// rubber feet under electronics_base_lid. Se ADR 004 for begrundelse.
//
// =============================================================================
// CANTILEVER PRINCIP — vigtig forståelse!
// =============================================================================
// En bar/beam strain gauge load cell måler ved at BØJE under belastning.
// Det betyder:
//   - ÉT end skal være rigidt fastgjort (FIXED END)
//   - Det ANDET end skal være FRIT til at bøje (FREE END, hvor lasten påføres)
//   - Cellens MIDTE må IKKE røre noget (skal være i luft)
//
// Hvis BEGGE ender klampes mellem to flade plader → cellen kan ikke bøje →
// strain gauges læser ~0 uanset belastning. Det er en common mistake.
//
// Vores løsning: STANDOFF-BOSSER der kun kontakter cellen ved bolt-punkterne.
//
//                  ┌─────────────────────────────┐  ← Upper plate
//                  │           ╔══════╗          │
//                  │           ║ BOSS ║          │  ← Boss kun ved FREE END
//                  │           ╚══[M4 bolt ↓]    │     (hænger ned)
//                                  ║
//                          air gap ║  ← cellen bøjer her
//                                  ║
//                  ╔═══════════════╩════════════════════╗  ← Load cell
//                  ║                                    ║      (horisontal)
//                  ╚════[M4 bolt ↑]═════════════════════╝
//                       ║
//                  ╔════╩════╗
//                  ║  BOSS  ║                              ← Boss kun ved FIXED END
//                  ┌────────╩─────────────────────────────┐  ← Lower plate
//                  └──────────────────────────────────────┘
//                          (krukken hviler på upper plate via electronics_base)
//
// =============================================================================
// PRINT-STRATEGI
// =============================================================================
// Begge plader er ens (boss på ene end). Print TO identiske kopier af
// plate_with_boss(). Under samling:
//   - Lower plate: brug som den er printet (boss-side opad)
//   - Upper plate: FLIP den 180° så boss-side vender NEDAD
//                  + roter så boss-end er over cellens FREE END
//
// PRINT: PLA eller PETG. 30% gyroid infill er fint. Ingen support
// (boss er flad-top). Print boss-side UP.
// =============================================================================

include <params.scad>

// ─── Render-mode selector ───────────────────────────────────────────────────
// "assembled" = vis hele samlingen (lower + cell + upper)
// "plate"     = vis kun ÉN plade i print-orientation (boss-side up)
render_mode = "assembled";

// ─── Bygge-blok: en plade med boss ved FIXED-end position ───────────────────
// Bossens CENTER ligger ved loadcell_fixed_x, så når cellens M4-huller er
// præcis ved loadcell_fixed_x, sidder bolt-hullerne i pladen lige under dem.
module plate_with_boss() {
    difference() {
        union() {
            // Hoved-plade
            cylinder(d = platform_d, h = platform_thickness);

            // Standoff boss — CENTRERET på loadcell_fixed_x
            translate([loadcell_fixed_x - boss_l / 2,
                       -boss_w / 2,
                       platform_thickness - 0.01])
                cube([boss_l, boss_w, boss_height + 0.01]);
        }

        // M4-bolt huller PRÆCIS ved loadcell_fixed_x (matcher cellens huller)
        for (dy = [-loadcell_screw_spacing / 2,
                    loadcell_screw_spacing / 2]) {
            translate([loadcell_fixed_x, dy, -0.5])
                cylinder(d = 4.2,
                         h = platform_thickness + boss_height + 1);
        }
    }
}

// ─── Samlet visualisering ───────────────────────────────────────────────────
module load_cell_assembly() {
    // Lower plate — brug som den er
    plate_with_boss();

    // Load cell visualisering (background — printes ikke)
    %translate([0, 0, platform_thickness + boss_height])
        load_cell_dummy();

    // Upper plate — flippet 180° om Y-aksen (mirrors X og Z)
    // Translateret op så bossen netop rører cellens FREE-end top
    upper_z_offset = 2 * (platform_thickness + boss_height) + loadcell_height;
    translate([0, 0, upper_z_offset])
        rotate([0, 180, 0])
            plate_with_boss();
}

// ─── Load cell visualization (kun til preview, ikke printet) ────────────────
module load_cell_dummy() {
    color([0.5, 0.5, 0.55])
        translate([-loadcell_length / 2, -loadcell_width / 2, 0])
            cube([loadcell_length, loadcell_width, loadcell_height]);

    // Marker fixed end med rødt
    color([0.8, 0.2, 0.2])
        translate([loadcell_fixed_x - 2, -loadcell_width / 2 - 0.1, 0])
            cube([4, loadcell_width + 0.2, loadcell_height]);

    // Marker free end med grønt
    color([0.2, 0.8, 0.2])
        translate([loadcell_free_x - 2, -loadcell_width / 2 - 0.1, 0])
            cube([4, loadcell_width + 0.2, loadcell_height]);
}

// ─── Output baseret på render_mode ──────────────────────────────────────────
if (render_mode == "assembled") {
    load_cell_assembly();
} else if (render_mode == "plate") {
    plate_with_boss();
} else {
    echo("ERROR: render_mode skal være 'assembled' eller 'plate'");
}
