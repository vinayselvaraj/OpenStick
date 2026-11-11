// ===================================================================
// Project: OpenStickFPV
// Component: Underslung H-Stab & Deck-Top V-Stab Tail Mount (Extended Skid)
// - Extended Tail Skid: Rear extension doubled to 32mm past collar rear face
// - Fixed hole spacing: Inner set (X = +/- 20mm), Outer set (X = +/- 52mm)
// - Fixed hole diameter: Clean 3.3mm M3 clearance with separate 6.2mm counterbores
// - Clear overhead driver access for all 8 top-down screw holes
// - Underslung 136mm wide bed for folded double-layer DTFB (~10.5mm)
// - Deck-Top 28mm vertical slot with dual-tier M3 cross-clamp holes
// - Dual zip-tie clamping around 10x10mm spar with full longitudinal slit
// ===================================================================

$fn = 60;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 1.6;    // Structural wall thickness
sleeve_length        = 48.0;   // Length along fuselage (Y-axis)

// --- Folded Dollar Tree Foam Board (DTFB) Spec ---
foam_thick_double    = 10.5;   // Width of V-stab slot for folded DTFB (~10.5mm)
vstab_depth          = 28.0;   // Tall vertical support slot
vstab_wall           = 1.8;    // Vertical fin spine outer wall thickness
hstab_span_x         = 136.0;  // 136mm total width across fuselage
hstab_chord_y        = sleeve_length;
hstab_bed_thick      = 2.4;    // Plate thickness

// --- Fastener Hardware Spec (M3 Sizing) ---
screw_hole_d         = 3.3;    // Clean M3 clearance through-hole
round_pocket_d       = 6.2;    // Clean round counterbore for M3 screw head
round_pocket_depth   = 1.2;    // Recess depth into the top face of the bed

// Discrete Fastener Coordinates (8 distinct holes on the H-Stab bed)
hstab_holes = [
    // Left Wing (-X)
    [-20.0, -14.0], [-20.0, -34.0],   // Inner set
    [-52.0, -14.0], [-52.0, -34.0],   // Outer set

    // Right Wing (+X)
    [ 20.0, -14.0], [ 20.0, -34.0],   // Inner set
    [ 52.0, -14.0], [ 52.0, -34.0]    // Outer set
];

vstab_screw_y        = [-14.0, -34.0]; // Y positions along vertical spine
vstab_screw_z_levels = [8.0, 21.0];    // Dual vertical clamping tiers

// --- Dual Zip-Tie Clamp Spec ---
ziptie_width         = 3.4;    // Fits up to 2.8mm cable ties
ziptie_depth         = 0.8;    // Retention channel depth
ziptie_inset         = 7.0;    // Inset from ends
slit_width           = 1.4;    // Compression pinch slit

// --- Extended Tail Skid Spec ---
skid_width           = 5.0;    // Runner thickness across X
skid_drop_below_bed  = 22.0;   // Ground clearance drop below the H-stab bed
skid_heel_radius     = 7.0;    // Rounded ground contact curvature
skid_extension_rear  = 32.0;   // Extended length rearward past collar rear (was 16mm)

// Derived Dimensions
collar_w       = spar_width + 2 * sleeve_wall; // ~13.35mm
collar_h       = spar_height + 2 * sleeve_wall; // ~13.35mm
vstab_spine_w  = foam_thick_double + 2 * vstab_wall; // ~14.1mm

// Vertical reference levels (Z=0 is the top face of the H-stab bed plate)
hstab_plate_top_z    = 0;
hstab_plate_bottom_z = -hstab_bed_thick;
spar_bottom_z        = 0;
spar_top_z           = collar_h;
vstab_top_z          = spar_top_z + vstab_depth;
skid_lowest_z        = hstab_plate_bottom_z - skid_drop_below_bed;

// Monotonic ramp profile for the elongated tail skid
module underslung_skid_profile() {
    polygon(points = [
        [-sleeve_length, hstab_plate_bottom_z],
        [-sleeve_length * 0.65, hstab_plate_bottom_z - skid_drop_below_bed * 0.35],
        [-sleeve_length * 0.20, hstab_plate_bottom_z - skid_drop_below_bed * 0.70],
        [skid_extension_rear - skid_heel_radius * 2.5, skid_lowest_z],
        [skid_extension_rear - 1.0, skid_lowest_z + 1.0],
        [skid_extension_rear, skid_lowest_z + skid_heel_radius],
        [skid_extension_rear - 3.0, skid_lowest_z + skid_heel_radius * 1.5],
        [0, hstab_plate_bottom_z - 2.0],
        [0, hstab_plate_bottom_z]
    ]);
}

module empennage_underslung_extended_skid() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES
        // -------------------------------------------------------------
        union() {
            // A. Central 10x10mm Spar Sleeve (Middle Core)
            translate([-collar_w/2, -sleeve_length, spar_bottom_z])
                cube([collar_w, sleeve_length, collar_h]);

            // B. Deck-Top Vertical Stabilizer Channel (Above Spar)
            translate([-vstab_spine_w/2, -sleeve_length, spar_top_z])
                cube([vstab_spine_w, sleeve_length, vstab_depth]);

            // C. Underslung Horizontal Stabilizer Bed (136mm Span)
            translate([-hstab_span_x/2, -sleeve_length, hstab_plate_bottom_z])
                cube([hstab_span_x, hstab_chord_y, hstab_bed_thick]);

            // Stiffening gussets - narrow footprint leaving inner holes accessible
            for (sx = [-1, 1]) {
                hull() {
                    translate([sx * (collar_w/2 - 0.1), -sleeve_length, spar_bottom_z])
                        cube([0.1, sleeve_length, collar_h * 0.6]);
                    translate([sx * (collar_w/2 + 5.0), -sleeve_length, spar_bottom_z])
                        cube([0.1, sleeve_length, 0.1]);
                }
            }

            // D. Lower Tail Skid Runner (Extended 32mm rearward)
            translate([-skid_width/2, 0, 0])
                rotate([90, 0, 90])
                linear_extrude(height = skid_width)
                    underslung_skid_profile();

            // Smooth forward transition blending skid to H-stab bed bottom
            hull() {
                translate([-skid_width/2, -sleeve_length, hstab_plate_bottom_z])
                    cube([skid_width, 4.0, 0.8]);
                translate([-skid_width/2, -sleeve_length * 0.5, hstab_plate_bottom_z - skid_drop_below_bed * 0.35])
                    cube([skid_width, 4.0, 0.8]);
            }
        }

        // -------------------------------------------------------------
        // 2. 10x10mm SPAR CAVITY
        // -------------------------------------------------------------
        translate([-spar_width/2, -sleeve_length - 1, spar_bottom_z + sleeve_wall])
            cube([spar_width, sleeve_length + 2, spar_height]);

        // -------------------------------------------------------------
        // 3. DECK-TOP VERTICAL FIN SLOT (10.5mm Wide x 28mm Tall)
        // -------------------------------------------------------------
        translate([-foam_thick_double/2, -sleeve_length - 1, spar_top_z])
            cube([foam_thick_double, sleeve_length + 2, vstab_depth + 1]);

        // -------------------------------------------------------------
        // 4. VERTICAL STABILIZER DUAL-TIER HORIZONTAL CROSS-HOLES
        // -------------------------------------------------------------
        for (z_lvl = vstab_screw_z_levels) {
            for (y_pos = vstab_screw_y) {
                translate([-vstab_spine_w/2 - 1, y_pos, spar_top_z + z_lvl])
                    rotate([0, 90, 0])
                    cylinder(d = screw_hole_d, h = vstab_spine_w + 2);
            }
        }

        // -------------------------------------------------------------
        // 5. UNDERSLUNG H-STAB HOLES (8 SEPARATE FASTENER LOCATIONS)
        // -------------------------------------------------------------
        for (pos = hstab_holes) {
            hx = pos[0];
            hy = pos[1];

            // Clean 3.3mm through-hole passing completely through the bed
            translate([hx, hy, hstab_plate_bottom_z - 2])
                cylinder(d = screw_hole_d, h = hstab_bed_thick + 4);

            // Shallow 6.2mm counterbore recessed 1.2mm into the top face
            translate([hx, hy, hstab_plate_top_z - round_pocket_depth])
                cylinder(d = round_pocket_d, h = round_pocket_depth + 0.05);
        }

        // -------------------------------------------------------------
        // 6. DUAL ZIP-TIE RETENTION GROOVES (On Spar Sleeve)
        // -------------------------------------------------------------
        for (y_pos = [-ziptie_inset, -(sleeve_length - ziptie_inset)]) {
            translate([0, y_pos, spar_bottom_z + collar_h/2])
                difference() {
                    cube([collar_w + 3, ziptie_width, collar_h + 3], center = true);
                    cube([
                        collar_w - 2 * ziptie_depth,
                        ziptie_width + 1,
                        collar_h - 2 * ziptie_depth
                    ], center = true);
                }
        }

        // -------------------------------------------------------------
        // 7. LONGITUDINAL TOP COMPRESSION SLIT
        // -------------------------------------------------------------
        translate([-slit_width/2, -sleeve_length - 1, spar_bottom_z + sleeve_wall + spar_height/2])
            cube([slit_width, sleeve_length + 2, collar_h + vstab_depth]);

        // -------------------------------------------------------------
        // 8. H-STAB BED CORNER CHAMFERS
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            for (sy = [0, -sleeve_length]) {
                translate([sx * hstab_span_x/2, sy, hstab_plate_bottom_z])
                    rotate([0, 0, 45])
                    cube([12.0, 12.0, hstab_bed_thick * 4], center = true);
            }
        }
    }
}

empennage_underslung_extended_skid();