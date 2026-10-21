// =============================================================================
// GreenThumbs Pot-Orchid v1 — Centrale parametre (ADR 012)
// =============================================================================
// Orkideen bliver i sin dyrkningspotte (12cm), som står i en konisk SKÅL.
// Lageret er en RING rundt om skålen; elektronik + batteri i BAY'en under.
// Det hele står i en pyntepotte.
//
//   ┌ ring-låg ─┐   ┌─ dyrkningspotte ─┐   ┌ ring-låg ┐
//   │  LAGER-   │   │     (bark)       │   │  RING    │
//   │  RING     │ ~~│~~ soak-niveau ~~~│~~ │          │  ← skålens kant =
//   │ ~~~~~~~~  │ S K Å L (konisk)     │   │ ~~~~~~~~ │    fysisk soak-loft
//   ╞═══════════╧══════════════════════╧═══╧══════════╡  ← tank-gulv
//   │  BAY: 2× 18650, pumpe, XIAO, H-bro, boost       │
//   └─────────────────────────────────────────────────┘
//
// Soak: pumpen fylder skålen fra ringen, til vandet løber over skålens kant
// og tilbage i ringen (selvnivellerende). Dræn: pumpen baglæns, til den
// berøringsfri sensor under skålens bund melder tom.
//
// Konvention: mm, grader. z = 0 er bunden af hver del.
// =============================================================================

$fn = 96;
print_tolerance = 0.3;

// ----------------------------------------------------------------------------
// 1. Pyntepotte (konvolut) — fra produktside, IKKE målt (bruger, 2026-10-21)
// ----------------------------------------------------------------------------
cachepot_inner_d    = 210;      // indvendig diameter ved åbningen
cachepot_max_pot_d  = 190;      // "maks. diameter urtepotte" ifølge produktsiden
cachepot_inner_h    = 185;      // anslået: ydre 200mm minus bund
cachepot_bottom_r   = 15;       // anslået radius på den buede bund-kant

// ----------------------------------------------------------------------------
// 2. Dyrkningspotte (12cm Phalaenopsis) — MÅL DIN POTTE og ret her
// ----------------------------------------------------------------------------
pot_top_d    = 120;
pot_bottom_d = 90;
pot_h        = 110;
function pot_r(h) = pot_bottom_d / 2 + (pot_top_d - pot_bottom_d) / 2 * h / pot_h;

// ----------------------------------------------------------------------------
// 3. Tank: skål (center) + lager-ring, ét print med fælles gulv
// ----------------------------------------------------------------------------
tower_d      = 180;             // ≤ cachepot_max_pot_d; plads til luft om tårnet
tank_wall    = 2.5;
tank_floor_t = 4;              // barrieren mellem vand og elektronik — massivt
ring_outer_r = tower_d / 2 - tank_wall;   // ringens indvendige yderradius

// Skål: konisk, følger pottens taper med fast spalte (spalten = vand-vej ind
// til pottens side-slidser og plads til at løfte potten)
bowl_gap    = 4;
bowl_wall   = 2.5;
feet_h      = 2;                // radiale ribber på skålens bund (potten må
                                // ikke tætne sine bundhuller mod gulvet)
soak_depth  = 68;               // over pottens bund = ~62% af pottehøjden
z_pot_bottom = tank_floor_t + feet_h;
bowl_rim_z   = z_pot_bottom + soak_depth;  // skålens kant = soak-loft

bowl_r_in_bottom = pot_r(0) + bowl_gap;
bowl_r_in_top    = pot_r(soak_depth) + bowl_gap;

// Slange-kanal: lodret udbuling i skålens væg ved 180° — slange A går ned
// her til sumpen (spalten på 4mm er for smal til en Ø6-slange)
hose_ch_angle = 180;
hose_ch_w     = 10;             // tangentielt
hose_ch_depth = 8;              // radialt ud over skålens indervæg
sump_d        = 10;
sump_depth    = 1.5;

// Lager-ring: max vandstand SKAL ligge under skålens kant (ellers løber
// lageret tilbage i skålen). Overløb udad som sidste udvej.
ring_overflow_z     = bowl_rim_z - 6;
ring_overflow_d     = 5;
ring_overflow_angle = 0;
ring_wall_h         = bowl_rim_z + 9;      // ringens ydervæg op til låget
float_full_z        = ring_overflow_z - 5; // "lager fuldt"-float (refill-bip)
float_low_z         = tank_floor_t + 15;   // "lager lavt"-float

// Float-beslag på ringens YDERVÆG (ringen er bredest dér). Mini-float med
// M8-stamme skrues i hullet og hænger float_hang under armen. Kablet føres
// langs ringen til skaktens top.
float_angle      = 125;
float_arm_l      = 18;          // radialt ind fra ydervæggen
float_arm_w      = 14;
float_arm_t      = 3;
float_hang       = 10;          // arm over flyderens koblingspunkt (mini-float)
float_hole_d     = 8.5;         // M8-stamme
float_hole_from_wall = 11.5;    // flyder Ø~18 går fri af væg og skål

// Tør skakt i ringen: fra bay'en op til over ringens max — slanger og
// kabler går her (ingen huller under vandlinjen ud mod elektronikken)
conduit_angle = 160;
conduit_od    = 17;
conduit_id    = 13;
conduit_r     = ring_outer_r - conduit_od / 2 - 1;
conduit_top_z = ring_overflow_z + 8;

// Ring-låg: hviler på ringens ydervæg, går fri af potten
lid_t          = 3;
lid_inner_r    = pot_r(ring_wall_h + lid_t - z_pot_bottom) + 2;
refill_hole_d  = 25;
refill_angle   = 270;

// ----------------------------------------------------------------------------
// 4. Bay (elektronik + batteri) — åben top, tank-gulvet er loftet
// ----------------------------------------------------------------------------
bay_wall      = 2.5;
bay_floor_t   = 3;
bay_h         = 47;             // NKP-pumpe ~41mm høj liggende (forhandler-mål)
bay_chamfer   = 10;             // 45° fas forneden mod pyntepottens buede bund
collar_h      = 4;              // krave på bay-rimmen centrerer tanken

cell_d   = 18.6;                // 18650
cell_l   = 65;
cell_count = 2;                 // 1S2P
cradle_y   = 40;                // batteriet på den ene side, pumpen på den anden

// ----------------------------------------------------------------------------
// 5. Beregnede størrelser
// ----------------------------------------------------------------------------
bark_porosity = 0.55;           // vandfyldt andel af barken (antagelse)
pump_ml_min   = 75;             // Kamoer NKP-DC-S10B: 70-80 ml/min (forhandlere)

// Soak-volumen: vand i potten (bark) + spalten + under potten
function frustum_v(r1, r2, h) = PI * h / 3 * (r1*r1 + r1*r2 + r2*r2);
pot_water_ml  = frustum_v(pot_r(0) - 1.5, pot_r(soak_depth) - 1.5, soak_depth)
                * bark_porosity / 1000;
gap_water_ml  = (frustum_v(bowl_r_in_bottom, bowl_r_in_top, soak_depth)
                 - frustum_v(pot_r(0), pot_r(soak_depth), soak_depth)) / 1000;
under_pot_ml  = PI * pow(bowl_r_in_bottom, 2) * feet_h / 1000;
soak_volume_ml = pot_water_ml + gap_water_ml + under_pot_ml;

// Lager-ring: ringvolumen fra gulv til overløb minus skålens ydre og skakten
ring_h = ring_overflow_z - tank_floor_t;
bowl_outer_v = frustum_v(bowl_r_in_bottom + bowl_wall,
                         pot_r(ring_overflow_z - z_pot_bottom) + bowl_gap + bowl_wall,
                         ring_h);
ring_capacity_ml = (PI * pow(ring_outer_r, 2) * ring_h - bowl_outer_v
                    - PI * pow(conduit_od / 2, 2) * ring_h) / 1000;

total_h_to_lid = bay_h + ring_wall_h + lid_t;
pot_top_z      = bay_h + z_pot_bottom + pot_h;

echo("=== Pot-Orchid v1 (ADR 012) ===");
echo("soak-volumen (BEREGNET):", soak_volume_ml, "ml");
echo("lager-ring (BEREGNET):", ring_capacity_ml, "ml");
echo("reserve efter én soak:", ring_capacity_ml - soak_volume_ml, "ml");
echo("fyld/dræn pr. retning:", soak_volume_ml / pump_ml_min, "min");
echo("højde til ring-låg:", total_h_to_lid, "mm");
echo("pottens top:", pot_top_z, "mm  (pyntepotte indv. ca.", cachepot_inner_h, "mm)");
echo("tårn Ø:", tower_d, "mm  (pyntepotte max", cachepot_max_pot_d, "mm)");
