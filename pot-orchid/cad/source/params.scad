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
//   │  BAY: 2× 18650, pumpe, ESP32-H2, H-bro, boost   │
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
// 1. Pyntepotte: IKEA SANDKÖRSBÄR 19 cm — målt med målebånd 2026-10-26 (±~3mm)
// ----------------------------------------------------------------------------
//   Ø210 ┐                 ┌      Øverste del: 160mm ned til en afsats,
//        │                 │      der går 20mm ind mod midten. Derunder en
//        │   160mm         │      udhulet bund: Ø160 × 28mm.
//   Ø200 └──┐           ┌──┘ ← afsats
//           │ Ø160 ×28  │       Tårnets FOD står i fordybningen; resten af
//           └───────────┘       tårnet går fri af afsatsen.
cachepot_inner_d    = 210;      // ved åbningen (produktside)
cachepot_max_pot_d  = 190;      // "maks. diameter urtepotte" (produktside)
cachepot_ledge_z    = 160;      // fra kanten ned til afsatsen
cachepot_ledge_d    = 200;      // indv. Ø lige over afsatsen (160 + 2×20)
cachepot_recess_d   = 160;      // den udhulede bund
cachepot_recess_h   = 28;
cachepot_inner_h    = cachepot_ledge_z + cachepot_recess_h;   // 188

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
// her til sumpen (spalten på 4mm er for smal til NKP'ens Ø5-slange)
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

// USB-C-skakt (ADR 013): egen tør skakt fra bay'en op GENNEM ring-låget.
// Hun-enden af en USB-C-forlænger sidder i toppen (flugter med låget).
// Et stik under låget ville nå ned i vandet (kun ~15mm luft over max).
usbc_angle   = 60;
usbc_body_w  = 12.5;            // hun-endens overmold — VERIFICÉR mod kablet
usbc_body_t  = 6.5;
usbc_tube_id = 15;              // > overmoldens diagonal (13.6) → kan trækkes op
usbc_tube_od = usbc_tube_id + 4;
usbc_tube_r  = ring_outer_r - usbc_tube_od / 2 - 3;   // fri af lågets læbe
usbc_cap_t   = 2;               // top med slids der holder stikket

// ----------------------------------------------------------------------------
// 4. Bay (elektronik + batteri) — åben top, tank-gulvet er loftet
// ----------------------------------------------------------------------------
// Bay'ens nederste del er en FOD, der står i pyntepottens udhulede bund;
// en 45°-skulder fører ud til tårnets fulde Ø og går fri af afsatsen.
bay_wall      = 2.5;
bay_floor_t   = 3;
bay_h         = 47;             // NKP ligger 41mm høj + gulv + frigang
collar_h      = 4;              // krave på bay-rimmen centrerer tanken
foot_clear    = 4;              // radial frigang i fordybningen (målene er ca.)
foot_d        = cachepot_recess_d - 2 * foot_clear;   // 152
foot_h        = cachepot_recess_h + 2;                 // skulderen starter 2mm over afsatsen
foot_r_in     = foot_d / 2 - bay_wall;                 // indvendig radius i foden
shoulder_top  = foot_h + (tower_d - foot_d) / 2;      // 45° → fuld Ø her

// Layout i foden (set oppefra): pumpen i midten mod -y, en 18650 på hver
// side af den, Qi-spolen mod +y. Spolen kan ikke ligge i midten: med ≥10mm
// til metal ville pumpen nå r≈100 — foden har 73,5.
pump_w   = 54.5;                // Kamoer NKP-DC-S10B (forhandler-mål), langs x
pump_l   = 67.5;                // langs y (hoved + motor)
pump_h   = 41;                  // liggende, slangerne ud foroven
pump_cy  = -20;                 // centrum på y

// Pumpe-vugge (pump_cradle.scad): separat print over to pinde i bay-gulvet.
// Motoren ligger i to V-sadler (tager Ø20-30) og holdes af kabelstrips;
// hovedet står på gulvet. MÅL PUMPEN — de tre første er skøn fra produktfoto:
nkp_motor_d   = 27;             // motorens Ø
nkp_axis_h    = 20.5;           // motorakse over hovedets bund (≈ midt i hovedet)
nkp_head_d    = 27;             // hovedets dybde langs aksen inkl. sort beslag
cradle_w      = 30;             // sadlernes bredde (x)
cradle_t      = 2;              // bundplade
cradle_pin_d  = 3.5;            // pinde på bay-gulvet (op i vuggens huller)
cradle_pin_h  = 1.6;
tie_w         = 4;              // kabelstrips op til 3,6mm brede
cradle_s1     = pump_cy - pump_l / 2 + 8;   // sadlernes y-position (under motoren)
cradle_s2     = cradle_s1 + 21;
cradle_y0     = cradle_s1 - 6;
cradle_y1     = cradle_s2 + 6;
cradle_pin_y  = (cradle_y0 + cradle_y1) / 2;

cell_d   = 18.6;                // 18650, akse langs y
cell_l   = 65;
cell_count = 2;                 // 1S2P — én på hver side af pumpen
cell_x   = pump_w / 2 + 2.5 + cell_d / 2 + 0.3;
cell_y0  = -52;                 // cellernes nederste ende

// Qi-modtager (ADR 013): lomme i gulvet, off-center → ladebasen har en nøgle
qi_w       = 41;                // lomme til spolen 40×29mm (fundet modul) + 1mm
qi_l       = 30;
qi_cy      = 46;
qi_floor_t = 1.2;               // tyndt gulv under spolen (rækkevidde ~2-8mm)
key_angle  = 270;               // nøgle-ribbe på foden (passer i ladebasen)
key_w      = 8;
key_t      = 2;
key_h      = 8;

// Pasnings-tjek (radius i foden, afstand fra spole til metal)
pump_corner_r = norm([pump_w / 2, -pump_cy + pump_l / 2]);
cell_corner_r = norm([cell_x + cell_d / 2, -cell_y0]);
qi_corner_r   = norm([qi_w / 2, qi_cy + qi_l / 2]);
qi_pump_gap   = (qi_cy - qi_l / 2) - (pump_cy + pump_l / 2);
qi_cell_gap   = norm([(cell_x - cell_d / 2) - qi_w / 2,
                      (qi_cy - qi_l / 2) - (cell_y0 + cell_l)]);

// ----------------------------------------------------------------------------
// 4b. Ladebase (ADR 013) — tårnet løftes ud af pyntepotten og stilles her
// ----------------------------------------------------------------------------
// Bakke der centrerer tårnets fod (±0,5mm); en slids låser nøgle-ribben, så
// Qi-spolen (off-center) står over Apple MagSafe-laderen (25W, A2580).
magsafe_d       = 55.5;         // ChargerLab-teardown af A2580 — VERIFICÉR
magsafe_t       = 4.45;
magsafe_proud   = 0.1;          // laderen stikker lidt op → tårnet hviler på den
magsafe_cable_w = 6.5;          // flettet kabel + aflastning — VERIFICÉR
base_cable_angle = 90;          // kabel-kanalens retning fra laderen
base_clear      = 0.5;          // radial frigang mellem foden og bakken
base_wall       = 4;            // bakkens væg
base_wall_h     = 8;            // væggens højde over sædet
base_puck_floor = 1.6;          // gulv under laderen (med udskubningshul)
base_round      = 1.5;          // afrunding af synlige kanter

// ----------------------------------------------------------------------------
// 5. Beregnede størrelser
// ----------------------------------------------------------------------------
bark_porosity = 0.55;           // vandfyldt andel af barken (antagelse)
pump_ml_min   = 70;             // NKP-DC-S10B: ≥70 ml/min, 12V 0,3A, børstet DC

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
                    - PI * pow(conduit_od / 2, 2) * ring_h
                    - PI * pow(usbc_tube_od / 2, 2) * ring_h) / 1000;

total_h_to_lid = bay_h + ring_wall_h + lid_t;
pot_top_z      = bay_h + z_pot_bottom + pot_h;

echo("=== Pot-Orchid v1 (ADR 012) ===");
echo("soak-volumen (BEREGNET):", soak_volume_ml, "ml");
echo("lager-ring (BEREGNET):", ring_capacity_ml, "ml");
echo("reserve efter én soak:", ring_capacity_ml - soak_volume_ml, "ml");
echo("fyld/dræn pr. retning:", soak_volume_ml / pump_ml_min, "min");
echo("højde til ring-låg:", total_h_to_lid, "mm");
echo("pottens top under pyntepottens kant:", cachepot_inner_h - pot_top_z, "mm");
echo("tårn Ø:", tower_d, "mm  (pyntepotte max", cachepot_max_pot_d, "mm)");
echo("fod: indv. r", foot_r_in, "| pumpe", pump_corner_r, "| celler", cell_corner_r, "| Qi", qi_corner_r);
echo("Qi → pumpe:", qi_pump_gap, "mm, Qi → celle:", qi_cell_gap, "mm (mål: ≥ 10)");
if (max(pump_corner_r, cell_corner_r, qi_corner_r) > foot_r_in - 1)
    echo("ADVARSEL: noget i foden rammer væggen");
if (min(qi_pump_gap, qi_cell_gap) < 10)
    echo("ADVARSEL: Qi-spolen er for tæt på metal (pumpe/celler)");
