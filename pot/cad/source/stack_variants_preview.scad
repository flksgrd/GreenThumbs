// =============================================================================
// STACK-VARIANT PREVIEW — beslutningsgrundlag, IKKE print-geometri
// =============================================================================
// Audit 2026-06 fandt at cup (M=160mm) ikke kan hænge i det beregnede
// reservoir (57.5mm for 700ml). To redesign-varianter visualiseres her som
// halv-snit, side om side:
//
//   VARIANT A (venstre): cup hænger NEDSÆNKET i et højt reservoir.
//     Klassisk self-watering design. Vand-zone under cup-bunden.
//     + Wick altid tæt på vand (20-50mm)
//     + Stort vandvolumen (~1000 ml under cup)
//     + Fugtigt mikroklima omkring cup (godt for rødder)
//     - Reservoir er stort print (~200mm høj cylinder)
//     - Cup drypper når den løftes ud
//
//   VARIANT B (højre): cup står OVENPÅ et lukket lavt reservoir.
//     Reservoir beholder sin lave form (57mm), lukket top med dræn-rist.
//     + Reservoir-print uændret lille; cup kan løftes af uden dryp
//     + Enklere at adskille/rengøre
//     - Wick-afstand fra cup-bund til vandoverflade: 30-55mm (afhænger
//       af vandstand) — wick skal være lang og virker dårligere
//     - Mindre vandvolumen (700 ml) medmindre reservoir gøres højere
//     - Højere total stak (~295mm vs ~280mm)
//
// Farver: grøn=cup, blå=reservoir, cyan=vand, grå=electronics base+lid
//
// Render: åbn i OpenSCAD og F5. Eller:
//   openscad --imgsize 1400,800 --camera 0,-450,140,75,0,0,900 \
//            -o preview.png stack_variants_preview.scad
// =============================================================================

include <params.scad>

// Forenklede dimensioner (M-cup)
pv_cup_d = 140;
pv_cup_h = 160;
pv_res_d = 186;
pv_wall = 3;
pv_ebase_h = 40;
pv_lid_h = 5;

// Halv-snit: fjern Y<0 halvdelen så indre geometri ses
module half(){ difference(){ children(); translate([-200, -400, -10]) cube([400, 400, 400]); } }


// ─────────────────────────────────────────────────────────────────────────────
// VARIANT A: cup hænger nedsænket — højt reservoir
// ─────────────────────────────────────────────────────────────────────────────
A_water_zone = 40;                       // vand-zone under cup-bund
A_res_h = pv_cup_h - 4 + A_water_zone;   // flange-top flugter reservoir-rim → 196mm

module variant_A() {
    // Electronics base + lid (grå)
    color("dimgray") cylinder(d = pv_res_d, h = pv_lid_h);
    color("gray") translate([0, 0, pv_lid_h])
        difference() {
            cylinder(d = pv_res_d, h = pv_ebase_h);
            translate([0,0,-1]) cylinder(d = pv_res_d - 2*pv_wall, h = pv_ebase_h - pv_wall + 1);
        }

    z0 = pv_lid_h + pv_ebase_h;  // reservoir-bund

    // Reservoir (blå) — HØJT: 196mm
    color("steelblue", 0.85) translate([0, 0, z0])
        difference() {
            cylinder(d = pv_res_d, h = A_res_h);
            translate([0,0,pv_wall]) cylinder(d = pv_res_d - 2*pv_wall, h = A_res_h + 1);
        }

    // Vand (cyan, fuldt niveau = lige under cup-bund)
    color("cyan", 0.5) translate([0, 0, z0 + pv_wall])
        cylinder(d = pv_res_d - 2*pv_wall, h = A_water_zone - pv_wall);

    // Cup (grøn) — hænger fra flangen på reservoir-rim, bund 40mm over res-bund
    color("yellowgreen", 0.9) translate([0, 0, z0 + A_water_zone])
        difference() {
            union() {
                cylinder(d = pv_cup_d, h = pv_cup_h);
                translate([0, 0, pv_cup_h - 4])
                    cylinder(d = pv_res_d + 14, h = 4);  // flange på rim
            }
            translate([0,0,2.4]) cylinder(d = pv_cup_d - 4.8, h = pv_cup_h + 1);
        }

    // Wick (brun) — fra cup-bund ned i vandet
    color("peru") translate([0, 0, z0 + 10]) cylinder(d = 4, h = A_water_zone + 20);
}


// ─────────────────────────────────────────────────────────────────────────────
// VARIANT B: cup står ovenpå lukket lavt reservoir
// ─────────────────────────────────────────────────────────────────────────────
B_res_h = 58;          // nuværende lave form (700ml)
B_water_h = 28;        // vandsøjle ved fuldt

module variant_B() {
    // Electronics base + lid (grå)
    color("dimgray") cylinder(d = pv_res_d, h = pv_lid_h);
    color("gray") translate([0, 0, pv_lid_h])
        difference() {
            cylinder(d = pv_res_d, h = pv_ebase_h);
            translate([0,0,-1]) cylinder(d = pv_res_d - 2*pv_wall, h = pv_ebase_h - pv_wall + 1);
        }

    z0 = pv_lid_h + pv_ebase_h;

    // Reservoir (blå) — LAVT med LUKKET top (dræn-rist antydet med huller)
    color("steelblue", 0.85) translate([0, 0, z0])
        difference() {
            cylinder(d = pv_res_d, h = B_res_h);
            // indre hulrum
            translate([0,0,pv_wall]) cylinder(d = pv_res_d - 2*pv_wall, h = B_res_h - 2*pv_wall);
            // dræn-rist huller i toppen
            for (r = [20, 40, 60])
                for (a = [0:45:315])
                    rotate([0,0,a]) translate([r, 0, B_res_h - pv_wall - 0.5])
                        cylinder(d = 5, h = pv_wall + 1);
            // wick-gennemføring center
            translate([0,0,B_res_h - pv_wall - 0.5]) cylinder(d = 8, h = pv_wall + 1);
        }

    // Vand (cyan)
    color("cyan", 0.5) translate([0, 0, z0 + pv_wall])
        cylinder(d = pv_res_d - 2*pv_wall, h = B_water_h);

    // Cup (grøn) — står OVENPÅ reservoir-toppen
    color("yellowgreen", 0.9) translate([0, 0, z0 + B_res_h])
        difference() {
            cylinder(d = pv_cup_d, h = pv_cup_h);
            translate([0,0,2.4]) cylinder(d = pv_cup_d - 4.8, h = pv_cup_h + 1);
        }

    // Wick (brun) — fra cup-bund gennem rist ned mod vandet (langt!)
    color("peru") translate([0, 0, z0 + pv_wall + 5])
        cylinder(d = 4, h = B_res_h - pv_wall + 10);
}


// ─── Side om side, halv-snit ────────────────────────────────────────────────
half() variant_A();
translate([280, 0, 0]) half() variant_B();
