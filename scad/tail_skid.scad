// ===================================================================
// Project: OpenStickFPV
// Component: Monolithic Ramp-Blended Tail Skid for 10x10mm Spar
// - Front face forms a single continuous flat wedge from the front rim
//   (Y = -30mm) directly to the ground runner heel (zero undercut / step)
// - Runner extended rearward by 20mm past the collar rear (Y = +20mm)
// - Clean, geometric hull-based transitions with no separate floating lugs
// - Dual zip-tie retention channels and full longitudinal pinch slit
// - 100% support-free 3D printing (flat on side or inverted)
// ===================================================================

$fn = 60;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 2.2;    // Sleeve wall thickness
sleeve_length        = 30.0;   // Length along spar (Y spans -30mm to 0mm)

// --- Dual Zip-Tie Clamp Spec ---
ziptie_width         = 3.8;    // Fits standard 2.5mm to 3.5mm zip-ties
ziptie_depth         = 1.0;    // Groove depth
ziptie_positions_y   = [-7.0, -23.0]; // Clamping zones along the sleeve
slit_width           = 1.5;    // Top compression slit width

// --- Skid Geometry ---
skid_extension_rear  = 20.0;   // Extended 20mm rearward past Y = 0
skid_width           = 8.0;    // Thickness across X
skid_drop            = 22.0;   // Ground clearance drop below spar
skid_heel_radius     = 7.0;    // Rounded ground contact curvature

// Derived Dimensions
collar_w = spar_width + 2 * sleeve_wall;
collar_h = spar_height + 2 * sleeve_wall;

// 2D Profile: Pure monotonic ramp from the very front lip (Y = -30, Z = 0)
// down to the ground heel, completely eliminating any intermediate dip or gap.
module seamless_skid_profile() {
    polygon(points = [
        // 1. Front top corner (flush at sleeve forward edge)
        [-sleeve_length, 0],

        // 2. Continuous downward ramp along the belly directly to the ground shoe
        [-sleeve_length * 0.65, -skid_drop * 0.40],
        [-sleeve_length * 0.25, -skid_drop * 0.78],
        [skid_extension_rear - skid_heel_radius * 2, -skid_drop],

        // 3. Rounded rear ground-contact heel
        [skid_extension_rear - 1.0, -skid_drop + 1.0],
        [skid_extension_rear, -skid_drop + skid_heel_radius],
        [skid_extension_rear - 2.5, -skid_drop + skid_heel_radius * 1.6],

        // 4. Rear upward sweep meeting the rear edge of the sleeve
        [0, -2.0],
        [0, 0]
    ]);
}

module tail_skid_monolithic() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES (Collar + Fully Integrated Monolithic Ramp)
        // -------------------------------------------------------------
        union() {
            // Main rectangular spar sleeve
            translate([-collar_w/2, -sleeve_length, 0])
                cube([collar_w, sleeve_length, collar_h]);

            // Ground runner extruded across skid_width and merged flush with collar
            translate([-skid_width/2, 0, 0])
                rotate([90, 0, 90])
                linear_extrude(height = skid_width)
                    seamless_skid_profile();

            // Flanking triangular gusset ramps blending the 8mm runner into the 14.5mm collar
            hull() {
                translate([-collar_w/2, -sleeve_length, 0])
                    cube([collar_w, 4.0, 1.0]);
                translate([-skid_width/2, -sleeve_length * 0.5, -skid_drop * 0.35])
                    cube([skid_width, 4.0, 1.0]);
            }
        }

        // -------------------------------------------------------------
        // 2. 10x10mm SPAR CAVITY
        // -------------------------------------------------------------
        translate([-spar_width/2, -sleeve_length - 1, sleeve_wall])
            cube([spar_width, sleeve_length + 2, spar_height]);

        // -------------------------------------------------------------
        // 3. DUAL ZIP-TIE RETENTION GROOVES
        // -------------------------------------------------------------
        for (pos_y = ziptie_positions_y) {
            translate([0, pos_y, collar_h/2])
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
        // 4. FULL-LENGTH LONGITUDINAL PINCH SLIT
        // -------------------------------------------------------------
        translate([-slit_width/2, -sleeve_length - 1, spar_height/2])
            cube([slit_width, sleeve_length + 2, collar_h]);

        // -------------------------------------------------------------
        // 5. SIDE PERIMETER BEVELS (Smooth Aerodynamic Edges)
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            translate([sx * (collar_w/2 + 0.5), -sleeve_length/2, collar_h])
                rotate([0, 45, 0])
                cube([2.0, sleeve_length + 2, 2.0], center = true);
        }
    }
}

tail_skid_monolithic();