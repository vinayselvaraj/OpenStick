// ===================================================================
// Project: OpenStickFPV
// Component: Ultra-Slim Open-Frame 9g Servo Mount for 10x10mm Spar
// - Minimalist open mounting tabs with low-profile thickness (1.8mm)
// - Sized for short servo screws (5mm-6mm thread length)
// - Opposed transverse mounting for direct rudder & elevator pushrod runs
// - Dual zip-tie retention channels around 10x10mm spar
// - Full-length longitudinal pinch slit for compression clamping
// - 100% support-free 3D printing
// ===================================================================

$fn = 50;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 1.5;    // Thin structural collar wall
sleeve_length        = 34.0;   // Length along fuselage (Y-axis)

// --- Spar Zip-Tie Clamp Spec ---
ziptie_width         = 3.4;    // Fits up to 2.8mm cable ties
ziptie_depth         = 0.8;    // Recessed channel depth
ziptie_inset         = 5.5;    // Inset from ends
slit_width           = 1.4;    // Top compression slit

// --- 9g Servo Low-Profile Tab Geometry ---
servo_tab_spacing    = 28.0;   // Standard 9g center-to-center hole pitch
lug_thickness_y      = 4.2;    // Width of mounting lug along fuselage (Y-axis)
lug_outreach_x       = 12.5;   // Extension from collar side wall
lug_height_z         = 1.8;    // Reduced pad thickness for short screws
servo_screw_d        = 1.7;    // Pilot hole for micro servo screws
screw_hole_inset_x   = 6.5;    // Hole center from collar wall

// Derived Collar Dimensions
collar_w = spar_width + 2 * sleeve_wall;  // ~13.15mm
collar_h = spar_height + 2 * sleeve_wall; // ~13.15mm

module ultra_slim_9g_servo_mount() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES (Spar Collar + Slim Mounting Lugs)
        // -------------------------------------------------------------
        union() {
            // Main central 10x10mm spar collar
            translate([-collar_w/2, -sleeve_length/2, 0])
                cube([collar_w, sleeve_length, collar_h]);

            // Low-profile mounting lugs extending out left (-X) and right (+X)
            for (sx = [-1, 1]) {
                for (sy = [-1, 1]) {
                    // Slim mounting tab pad
                    translate([
                        sx > 0 ? collar_w/2 : -collar_w/2 - lug_outreach_x,
                        sy * (servo_tab_spacing / 2) - lug_thickness_y / 2,
                        collar_h - lug_height_z
                    ])
                        cube([lug_outreach_x, lug_thickness_y, lug_height_z]);

                    // Low-angle stiffening gusset directly beneath the thin pad
                    hull() {
                        translate([
                            sx > 0 ? collar_w/2 : -collar_w/2 - lug_outreach_x,
                            sy * (servo_tab_spacing / 2) - lug_thickness_y / 2,
                            collar_h - lug_height_z
                        ])
                            cube([lug_outreach_x, lug_thickness_y, 0.1]);

                        translate([
                            sx > 0 ? collar_w/2 : -collar_w/2 - 0.1,
                            sy * (servo_tab_spacing / 2) - lug_thickness_y / 2,
                            collar_h - lug_height_z - 4.5
                        ])
                            cube([0.1, lug_thickness_y, 0.1]);
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 2. 10x10mm SPAR CAVITY (Centered along Y-axis)
        // -------------------------------------------------------------
        translate([-spar_width/2, -sleeve_length/2 - 1, sleeve_wall])
            cube([spar_width, sleeve_length + 2, spar_height]);

        // -------------------------------------------------------------
        // 3. DUAL ZIP-TIE RETENTION GROOVES
        // -------------------------------------------------------------
        for (sy = [-1, 1]) {
            translate([0, sy * (sleeve_length/2 - ziptie_inset), collar_h/2])
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
        // 4. LONGITUDINAL TOP COMPRESSION SLIT
        // -------------------------------------------------------------
        translate([-slit_width/2, -sleeve_length/2 - 1, spar_height/2])
            cube([slit_width, sleeve_length + 2, collar_h]);

        // -------------------------------------------------------------
        // 5. SERVO MOUNTING SCREW PILOT HOLES
        // -------------------------------------------------------------
        // Clean through-holes through the slim pads
        for (sx = [-1, 1]) {
            for (sy = [-1, 1]) {
                translate([
                    sx * (collar_w/2 + screw_hole_inset_x),
                    sy * (servo_tab_spacing / 2),
                    collar_h - lug_height_z - 10
                ])
                    cylinder(d = servo_screw_d, h = lug_height_z + 20);
            }
        }

        // -------------------------------------------------------------
        // 6. OUTER CORNER CHAMFERS
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            for (sy = [-1, 1]) {
                translate([
                    sx * (collar_w/2 + lug_outreach_x),
                    sy * (servo_tab_spacing / 2 + lug_thickness_y / 2),
                    collar_h
                ])
                    rotate([0, 0, 45])
                    cube([2.5, 2.5, lug_height_z * 4], center = true);
            }
        }
    }
}

ultra_slim_9g_servo_mount();