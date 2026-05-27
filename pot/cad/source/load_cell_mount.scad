// =============================================================================
// Load Cell Mount — Vægt-platform under hele krukken (OPTIONAL)
// =============================================================================
// OPTIONAL hardware: kun nødvendigt hvis du vil bruge orkide-profilen
// (DETECT_WEIGHT) eller HYBRID-mode på succulenter. For Monstera/Peace Lily/
// store jord-baserede planter kan du SKIPPE denne del og bare sætte stick-on
// rubber feet under electronics_base_lid. Se ADR 004 for begrundelse.
//
// To-plades sandwich der holder en bar load cell (TAL220 5kg eller equivalent).
// Hele krukken (electronics base + reservoir + plant cup) hviler på upper_plate.
// HX711 ADC sidder typisk på et lille modul der monteres på lower_plate.
//
// Vigtigt: bar load cell skal være cantilevered — ét end fast til upper plate,
// andet end fast til lower plate. Hullet i midten af cellen er strain gauge-zonen
// og må IKKE fastgøres.
//
//      ┌─────────────────┐ ← upper_plate (krukken hviler her)
//      │             ●───┼─● ← M4-bolte til ene end af load cell
//      └────────────────┬┘
//                       ║
//                       ║ Load cell bar (frit-svævende)
//                       ║
//      ┌───────────────┬─┘
//      │           ●───┼─● ← M4-bolte til ANDEN end af load cell
//      └─────────────────┘ ← lower_plate (står på bordet)
//
// PRINT: PLA eller PETG. Ikke vand-kontakt. 100% infill ikke nødvendigt;
// 30% gyroid er fint.
// =============================================================================

include <params.scad>

// ─── Hovedmodul: hele samlingen visualiseret ────────────────────────────────
module load_cell_mount() {
    // Lower plate (står på bord)
    lower_plate();

    // Load cell visualization (background — printes ikke; bare for fitting)
    %translate([0, 0, platform_thickness + 2])
        load_cell_dummy();

    // Upper plate (krukke står herpå)
    translate([0, 0, platform_separation + platform_thickness])
        upper_plate();
}

// ─── Lower plate — hviler på bord ───────────────────────────────────────────
module lower_plate() {
    difference() {
        cylinder(d = platform_d, h = platform_thickness);

        // M4-huller til load cell mounting ved ENE end af cellen
        // Cellen strækker sig fra venstre side mod højre. Lower plate
        // fastgør VENSTRE end af cellen.
        load_cell_screw_holes(x_offset = -loadcell_length / 2 + 8);

        // Rubber feet recesses (optional — eller bare flade)
        rubber_feet_recesses();
    }
}

// ─── Upper plate — krukke står herpå ────────────────────────────────────────
module upper_plate() {
    difference() {
        cylinder(d = platform_d, h = platform_thickness);

        // M4-huller til load cell mounting ved ANDEN end af cellen
        load_cell_screw_holes(x_offset = loadcell_length / 2 - 8);

        // Eventuelle anti-slip recesses (optional)
        // (Tom for v1 — kan tilføjes hvis krukken glider)
    }
}

// To M4-huller med given x-offset, langs y-aksen ved loadcell_screw_spacing
module load_cell_screw_holes(x_offset) {
    for (dy = [-loadcell_screw_spacing / 2, loadcell_screw_spacing / 2]) {
        translate([x_offset, dy, -0.5])
            cylinder(d = 4.2, h = platform_thickness + 1);
    }
}

// Tre runde recesses i bunden til gummi-fødder (Ø12mm)
module rubber_feet_recesses() {
    for (a = [0, 120, 240]) {
        rotate([0, 0, a])
            translate([platform_d / 2 - 12, 0, -0.5])
                cylinder(d = 12, h = 1.5);
    }
}

// ─── Visualization af load cell (printes ikke) ──────────────────────────────
module load_cell_dummy() {
    color([0.5, 0.5, 0.5])
        translate([-loadcell_length / 2, -loadcell_width / 2, 0])
            cube([loadcell_length, loadcell_width, loadcell_height]);
}

// ─── Render samlet visning når filen åbnes direkte ──────────────────────────
load_cell_mount();

// Til print: separat de to plader så de printes individuelt
// Uncomment disse to linjer og kommenter load_cell_mount() ud:
//   lower_plate();
//   translate([platform_d + 20, 0, 0]) upper_plate();
