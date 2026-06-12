// =============================================================================
// Reservoir — Vand-beholder som plant cup hænger nedsænket i (Variant A)
// =============================================================================
// STACK VARIANT A (valgt 2026-06): høj cylinder hvor cuppen hænger fra
// top-rimmen via sin flange. Vandet lever i zonen UNDER cup-bunden
// (water_zone_h) og i ringen omkring cuppen. Højde og kapacitet beregnes
// i params.scad ud fra cup-størrelse:
//   M-cup: reservoir ~199mm høj, kapacitet ~1018 ml
//
// Indhold:
//   - Lodret slot til kapacitiv water level strip (i ring-zonen)
//   - Bund-niche til float switch (under cuppen, i vand-zonen)
//   - Lodret pump-port gennem bunden ved pump_port_x=85 (i ring-gabet,
//     flugter med electronics_base port + plant_cup flange-hul)
//
// Refill: gennem plant_cup'ens flange-åbning ved 270° → vandet falder
// direkte ned i ring-gabet. (Tidligere rim-notch fjernet — flangen
// dækker nu hele rimmen.)
//
// PRINT: PETG. 3 perimeters minimum. 100% bund. Print upright med brim.
// Høj print (~200mm) — Prusa XL klarer det fint; brug draft shield ved træk.
// =============================================================================

include <params.scad>

module reservoir() {
    difference() {
        // ─── Solid outer body ───────────────────────────────────────────────
        cylinder(d = reservoir_outer_d, h = reservoir_height);

        // ─── Subtractions ───────────────────────────────────────────────────
        // Hovedhulrum (vand + plads til nedsænket cup)
        translate([0, 0, reservoir_wall])
            cylinder(d = reservoir_inner_d,
                     h = reservoir_height + 1);

        // Water level strip slot (vertikal kanal i indervæggen, ring-zonen)
        // Dækker vand-zonen (0-40mm) + margin; bunder 5mm over reservoir-bund
        translate([reservoir_inner_d / 2 - waterlevel_strip_t,
                   -waterlevel_strip_w / 2 - print_tolerance / 2,
                   reservoir_wall + 5])
            cube([waterlevel_strip_t + reservoir_wall + 1,
                  waterlevel_strip_w + print_tolerance,
                  waterlevel_strip_h]);

        // Float switch niche (bund-monteret, lodret, UNDER cuppen)
        // Roteret 90° fra water level strip så de ikke overlapper
        rotate([0, 0, 90])
            translate([float_switch_x, 0, reservoir_wall - 0.5])
                cylinder(d = float_switch_d + print_tolerance,
                         h = float_switch_h);

        // Pump output port (lodret hul gennem reservoir bund, i ring-gabet)
        // Pumpe sidder i electronics base nedenunder; slangen går op her,
        // op gennem ring-gabet, gennem flange-hullet, og ind i cup-toppen.
        // Fælles pump_port_x sikrer alignment hele vejen (audit-fix).
        rotate([0, 0, 180])
            translate([pump_port_x, 0, -0.5])
                cylinder(d = pump_port_d + 1,
                         h = reservoir_wall + 1);
    }
}

// Render reservoir når filen åbnes direkte
reservoir();
