// ===================================================================
// Project: OpenStickFPV
// Component: Standalone Landing Gear Mount (20mm Clear Pocket + Wall Offset)
// - Sized gear_plate_y dynamically so the inner pocket between the front
//   and rear retaining walls fits a 20.0mm landing gear + tolerance:
//     * gear_pocket_y = 20.0 + 0.4 (tolerance) = 20.4mm
//     * gear_plate_y  = 20.4 + 2 * 1.8 (walls) = 24.0mm (Y = +/- 12.0mm)
// - Matched mount_length = gear_plate_y (24.0mm) so front/rear faces
//   remain 100% coplanar for support-free sideways 3D printing
// - Dual upper spar clamp zip-tie slots automatically scale to
//   +/- 6.0mm (halfway from center to the +/- 12.0mm edges)
// - Compact 75.0mm lateral gear plate with outboard zip-tie channel
//   guides at X = +/- 28.0mm and continuous 1.0mm downward retaining lips
// ===================================================================

$fn = 50;

// --- Landing Gear Pocket & Wall Spec (20mm Gear + Walls + Tolerance) ---
gear_strut_y         = 20.0;   // Actual landing gear width along Y-axis
gear_pocket_tol      = 0.4;    // Fit clearance (+0.2mm per side)
gear_wall_thick      = 1.8;    // Front/rear retaining wall thickness
gear_wall_height     = 2.0;    // Low-profile 1.0mm downward lip below plate

// Derived total Y-width: 20.0 + 0.4 + 2*(1.8) = 24.0mm
gear_plate_y         = gear_strut_y + gear_pocket_tol + 2 * gear_wall_thick;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 1.8;    // Structural collar wall thickness
mount_length         = gear_plate_y; // 24.0mm (coplanar with gear plate Y = +/- 12.0mm)

// --- Top Zip-Tie Clamping System (Halfway from Center to Side Edges) ---
clamp_rise           = 10.0;   // Extension above the collar top for zip-tie slots
ziptie_slot_w        = 5.0;    // Slot width along fuselage (fits up to 4.8mm ties)
ziptie_slot_h        = 2.8;    // Slot vertical clearance (Z-axis)
pinch_slit_w         = 1.5;    // Top longitudinal compression slit

// Halfway between center (0) and side edges (+/- mount_length/2 = +/- 12.0mm)
ziptie_y_positions   = [
    -mount_length / 4,  // -6.0mm
     mount_length / 4   // +6.0mm
];

// --- Bottom Landing Gear Plate Spec ---
gear_plate_x         = 75.0;   // 75.0mm span (outer edges at X = +/- 37.5mm)
gear_plate_thick     = 3.4;    // Full unbroken thickness across entire plate

// --- Raised Zip-Tie Channel Guides (Seated Flat on Plate Deck) ---
gear_tie_width       = 5.2;    // Channel clearance width (fits up to 4.8mm ties)
guide_rib_height     = 1.8;    // Height of raised guide walls above plate
guide_rib_thick      = 2.2;    // Thickness of each raised guide wall along X-axis
gear_tie_edge_margin = 4.7;    // Margin from plate outer edge to outer rib edge
gear_tie_offset_x    = gear_plate_x/2 - gear_tie_edge_margin - guide_rib_thick - gear_tie_width/2; // +/- 28.0mm
gear_tie_x_offsets   = [-gear_tie_offset_x, gear_tie_offset_x];

// --- Gusset Termination Spec ---
gusset_top_offset    = 3.5;    // Terminates below collar top so clamping leaves stay flexible

// Derived Dimensions
collar_w          = spar_width + 2 * sleeve_wall;   // ~13.75mm
collar_h          = spar_height + 2 * sleeve_wall;  // ~13.75mm

gear_bottom_z     = 0;
gear_top_z        = gear_bottom_z + gear_plate_thick;

spar_collar_bot_z = gear_top_z;
spar_collar_top_z = spar_collar_bot_z + collar_h;

clamp_top_z       = spar_collar_top_z + clamp_rise;
ziptie_z          = spar_collar_top_z + clamp_rise / 2;
gusset_end_z      = spar_collar_top_z - gusset_top_offset;

// Inner edge of the inboard raised zip-tie guide rib (~23.2mm)
inner_guide_x     = gear_tie_offset_x - gear_tie_width/2 - guide_rib_thick;

module standalone_landing_gear_mount_v17() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES
        // -------------------------------------------------------------
        union() {
            // A. Full-Thickness Widened Landing Gear Plate (75mm x 24.0mm x 3.4mm)
            translate([-gear_plate_x/2, -gear_plate_y/2, gear_bottom_z])
                cube([gear_plate_x, gear_plate_y, gear_plate_thick]);

            // B. Raised Zip-Tie Guide Ribs (Seated Flat on Top Face at X = +/- 28.0mm)
            for (gx = gear_tie_x_offsets) {
                for (side = [-1, 1]) {
                    translate([
                        gx + side * (gear_tie_width/2 + guide_rib_thick/2),
                        0,
                        gear_top_z + guide_rib_height/2 - 0.1
                    ])
                        cube([guide_rib_thick, gear_plate_y, guide_rib_height + 0.1], center = true);
                }
            }

            // C. Continuous Front (+Y) & Rear (-Y) Downward Retaining Walls (1.0mm)
            // Leaves a 20.4mm inner pocket (20.0mm gear + 0.4mm fit tolerance)
            for (sy = [-1, 1]) {
                translate([
                    -gear_plate_x/2,
                    sy > 0 ? (gear_plate_y/2 - gear_wall_thick) : (-gear_plate_y/2),
                    gear_bottom_z - gear_wall_height
                ])
                    cube([gear_plate_x, gear_wall_thick, gear_wall_height + 0.1]);
            }

            // D. Central 10x10mm Spar Sleeve Core (24.0mm Length, Flush with Plate)
            translate([-collar_w/2, -mount_length/2, spar_collar_bot_z])
                cube([collar_w, mount_length, collar_h]);

            // E. Extended Top Zip-Tie Clamp Body (10mm rise, flush collar width)
            translate([-collar_w/2, -mount_length/2, spar_collar_top_z - 0.1])
                cube([collar_w, mount_length, clamp_rise + 0.1]);

            // F. Diagonal Gussets Flush with Front/Rear Faces (Y = +/- 12.0mm)
            for (sx = [-1, 1]) {
                hull() {
                    // Inner root: lands on collar side wall & ends (Y = +/- 12.0mm)
                    translate([sx * (collar_w/2 - 0.1), -mount_length/2, spar_collar_bot_z])
                        cube([0.1, mount_length, gusset_end_z - spar_collar_bot_z]);

                    // Outboard foot: ties straight into the inner zip-tie guide rib (~23.2mm)
                    // while staying flush with the front/rear faces (Y = +/- 12.0mm)
                    translate([sx * (inner_guide_x + 0.2), -mount_length/2, gear_top_z - 0.1])
                        cube([0.1, mount_length, 0.1]);
                }
            }
        }

        // -------------------------------------------------------------
        // 2. 10x10mm CARBON SPAR CAVITY
        // -------------------------------------------------------------
        translate([-spar_width/2, -mount_length/2 - 1, spar_collar_bot_z + sleeve_wall])
            cube([spar_width, mount_length + 2, spar_height]);

        // -------------------------------------------------------------
        // 3. DUAL TOP LATERAL ZIP-TIE SLOTS (Halfway from Center to Edges)
        // -------------------------------------------------------------
        for (zy = ziptie_y_positions) {
            for (sx = [-1, 1]) {
                translate([sx * collar_w/4, zy, ziptie_z])
                    cube([collar_w/2 + 2, ziptie_slot_w, ziptie_slot_h], center = true);
            }
        }

        // -------------------------------------------------------------
        // 4. TOP LONGITUDINAL COMPRESSION SLIT
        // -------------------------------------------------------------
        translate([-pinch_slit_w/2, -mount_length/2 - 1, spar_collar_top_z - sleeve_wall - 0.2])
            cube([pinch_slit_w, mount_length + 2, clamp_rise + sleeve_wall + 1.2]);
    }
}

standalone_landing_gear_mount_v17();