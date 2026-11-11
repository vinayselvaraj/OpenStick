// ===================================================================
// Project: OpenStickFPV
// Component: Empennage Mount - Clean Through-Hole Grid (No Fastener Ears)
// - Clamping tabs and bolt/nut pockets completely removed
// - Uniform wall thickness throughout (no thickened pads or lugs)
// - V-Stab: Left-to-right cross-clamping grid of clean 3.3mm M3 through-holes
// - H-Stab: Underslung 136mm bed with vertical grid of clean 3.3mm M3 through-holes
// - Direct slip-fit onto 10x10mm carbon spar with top longitudinal slit
// - Sized for folded double-layer laminated Dollar Tree Foam (~10.5mm)
// ===================================================================

$fn = 60;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 1.8;    // Structural collar wall thickness
sleeve_length        = 48.0;   // Length along fuselage (Y-axis)
slit_width           = 1.6;    // Top longitudinal slit

// --- Folded Dollar Tree Foam Board (DTFB) Spec ---
foam_thick_double    = 10.5;   // Width of V-stab slot for folded DTFB (~10.5mm)
vstab_depth          = 28.0;   // Tall vertical support slot
vstab_wall           = 1.8;    // Vertical fin spine outer wall thickness
hstab_span_x         = 136.0;  // 136mm total width across fuselage
hstab_chord_y        = sleeve_length;
hstab_bed_thick      = 1.8;    // Uniform slim plate thickness (matches sleeve wall)

// --- Fastener Hardware Spec ---
screw_hole_d         = 3.3;    // Uniform clean M3 clearance through-hole

// --- Evenly Spaced H-Stab Hole Grid (Vertical Axis) ---
hstab_x_positions    = [-56.0, -42.0, -28.0, -14.0, 14.0, 28.0, 42.0, 56.0]; // 14mm pitch across wings
hstab_y_positions    = [-12.0, -24.0, -36.0];                                  // 12mm pitch along chord

// --- Evenly Spaced V-Stab Hole Grid (Horizontal Axis) ---
vstab_y_positions    = [-10.0, -20.0, -30.0, -40.0];                           // 10mm pitch along chord
vstab_z_levels       = [7.0, 14.0, 21.0];                                      // 7mm vertical tier spacing

// Derived Dimensions
collar_w       = spar_width + 2 * sleeve_wall;       // ~13.75mm
collar_h       = spar_height + 2 * sleeve_wall;      // ~13.75mm
vstab_spine_w  = foam_thick_double + 2 * vstab_wall; // ~14.1mm

// Vertical reference levels
hstab_plate_top_z    = 0;
hstab_plate_bottom_z = -hstab_bed_thick;
spar_bottom_z        = 0;
spar_top_z           = collar_h;
vstab_top_z          = spar_top_z + vstab_depth;

module empennage_mount_clean() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES (Clean Monolithic Profile - No Ears/Pockets)
        // -------------------------------------------------------------
        union() {
            // A. Central 10x10mm Spar Sleeve (Middle Core)
            translate([-collar_w/2, -sleeve_length, spar_bottom_z])
                cube([collar_w, sleeve_length, collar_h]);

            // B. Deck-Top Vertical Stabilizer Channel (Above Spar)
            translate([-vstab_spine_w/2, -sleeve_length, spar_top_z])
                cube([vstab_spine_w, sleeve_length, vstab_depth]);

            // C. Underslung Horizontal Stabilizer Bed (Flat 136mm Bed)
            translate([-hstab_span_x/2, -sleeve_length, hstab_plate_bottom_z])
                cube([hstab_span_x, hstab_chord_y, hstab_bed_thick]);

            // Clean 45-degree gussets between collar and bed
            for (sx = [-1, 1]) {
                hull() {
                    translate([sx * (collar_w/2 - 0.1), -sleeve_length, spar_bottom_z])
                        cube([0.1, sleeve_length, collar_h * 0.5]);
                    translate([sx * (collar_w/2 + 4.0), -sleeve_length, spar_bottom_z])
                        cube([0.1, sleeve_length, 0.1]);
                }
            }
        }

        // -------------------------------------------------------------
        // 2. 10x10mm SPAR CAVITY (Clean, continuous carbon rod tunnel)
        // -------------------------------------------------------------
        translate([-spar_width/2, -sleeve_length - 1, spar_bottom_z + sleeve_wall])
            cube([spar_width, sleeve_length + 2, spar_height]);

        // -------------------------------------------------------------
        // 3. DECK-TOP VERTICAL FIN SLOT (10.5mm Wide x 28mm Tall)
        // -------------------------------------------------------------
        translate([-foam_thick_double/2, -sleeve_length - 1, spar_top_z])
            cube([foam_thick_double, sleeve_length + 2, vstab_depth + 1]);

        // -------------------------------------------------------------
        // 4. EVENLY SPACED V-STAB M3 CROSS-HOLES (Left-to-Right)
        // -------------------------------------------------------------
        // Clean 3.3mm cross-drilled holes in a 3x4 grid (12 holes total)
        for (z_lvl = vstab_z_levels) {
            for (y_pos = vstab_y_positions) {
                translate([-vstab_spine_w/2 - 1, y_pos, spar_top_z + z_lvl])
                    rotate([0, 90, 0])
                    cylinder(d = screw_hole_d, h = vstab_spine_w + 2);
            }
        }

        // -------------------------------------------------------------
        // 5. EVENLY SPACED H-STAB M3 THROUGH-HOLES (Top-to-Bottom)
        // -------------------------------------------------------------
        // Clean 3.3mm vertical through-holes in a 3x8 grid (24 holes total)
        for (hx = hstab_x_positions) {
            for (hy = hstab_y_positions) {
                translate([hx, hy, hstab_plate_bottom_z - 2])
                    cylinder(d = screw_hole_d, h = hstab_bed_thick + 4);
            }
        }

        // -------------------------------------------------------------
        // 6. LONGITUDINAL TOP COMPRESSION SLIT
        // -------------------------------------------------------------
        translate([-slit_width/2, -sleeve_length - 1, spar_bottom_z + sleeve_wall + spar_height * 0.5])
            cube([slit_width, sleeve_length + 2, collar_h + vstab_depth]);

        // -------------------------------------------------------------
        // 7. H-STAB BED CORNER CHAMFERS
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            for (sy = [0, -sleeve_length]) {
                translate([sx * hstab_span_x/2, sy, hstab_plate_bottom_z])
                    rotate([0, 0, 45])
                    cube([10.0, 10.0, hstab_bed_thick * 4], center = true);
            }
        }
    }
}

empennage_mount_clean();