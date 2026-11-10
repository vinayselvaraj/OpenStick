// ===================================================================
// Project: OpenStickFPV
// Centered Motor Mount for 10x10mm Spar (Single-Screw Clamp)
// - Motor Bolt Pattern: 22mm x 22mm Square (Cross Mount / X-Mount)
// - Extended collar (34mm total) with dedicated rear pinch clamp
// - Single M3 bolt clamp isolated from the rigid front faceplate
// - 4 identical cardinal gussets (0°, 90°, 180°, 270°) for 4-way rigidity
// - Full-through rear clearance tunnels for motor bolt screwdrivers
// - Rounded faceplate corners for minimum weight and propwash drag
// ===================================================================

$fn = 60;

// --- Motor Spec (22mm Cross Mount) ---
motor_bolt_spacing   = 22.0;   // 22mm square bolt spacing (X & Y)
motor_bolt_dia       = 3.3;    // M3 bolt clearance
motor_center_hole    = 9.5;    // Center shaft/circlip/boss clearance
faceplate_thick      = 4.2;    // Faceplate thickness
faceplate_w          = 36.0;   // Outer width (X) tailored for 22mm pattern
faceplate_h          = 36.0;   // Outer height (Y) tailored for 22mm pattern
faceplate_corner_r   = 5.5;    // Corner rounding radius

// --- Spar Sleeve Spec ---
spar_dim             = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_depth           = 34.0;   // Extended length for clamp section
spar_wall            = 2.2;    // Structural wall thickness

// --- Rear Single-Screw Clamp Spec ---
clamp_length         = 12.0;   // Length of rear clamp zone (Z = 22 to 34)
clamp_lug_h          = 8.5;    // Height of clamp lug above top spar wall
clamp_screw_dia      = 3.3;    // M3 bolt clearance
clamp_nut_dia        = 6.5;    // M3 hex nut trap
clamp_nut_depth      = 3.0;    // Hex nut pocket depth
clamp_slit_w         = 1.4;    // Compression slit width

// Calculated Dimensions
collar_w = spar_dim + 2 * spar_wall;
collar_h = spar_dim + 2 * spar_wall;

// Clamp screw sits 4.3mm above the top face of the carbon spar
clamp_screw_y = (collar_h / 2) + 4.3;
clamp_screw_z = spar_depth - (clamp_length / 2); // Centered in rear clamp zone (Z = 28)

// Rounded faceplate profile module
module rounded_faceplate() {
    translate([0, 0, -faceplate_thick])
        linear_extrude(height = faceplate_thick)
            hull() {
                for (sx = [-1, 1]) {
                    for (sy = [-1, 1]) {
                        translate([
                            sx * (faceplate_w / 2 - faceplate_corner_r),
                            sy * (faceplate_h / 2 - faceplate_corner_r)
                        ])
                            circle(r = faceplate_corner_r);
                    }
                }
            }
}

// Cardinal triangular gusset definition (symmetric on all 4 faces)
module cardinal_gusset(length_z = 15.0, width = 2.8) {
    reach_x = (faceplate_w / 2) - (collar_w / 2) - 1.5; 
    
    translate([collar_w / 2, -width / 2, 0])
        polyhedron(
            points = [
                [0,       0,     0],          // 0: inner base at faceplate
                [reach_x, 0,     0],          // 1: outer base at faceplate
                [0,       0,     length_z],   // 2: apex along spar collar
                [0,       width, 0],          // 3: inner base (+Y)
                [reach_x, width, 0],          // 4: outer base (+Y)
                [0,       width, length_z]    // 5: apex along spar collar (+Y)
            ],
            faces = [
                [0, 1, 2],       // Side 1
                [5, 4, 3],       // Side 2
                [0, 3, 4, 1],    // Base on faceplate
                [1, 4, 5, 2],    // Diagonal slope
                [3, 0, 2, 5]     // Contact wall on spar collar
            ]
        );
}

module motor_mount() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES (Faceplate, Sleeve, Gussets, Clamp Lug)
        // -------------------------------------------------------------
        union() {
            // Front Faceplate with Rounded Corners
            rounded_faceplate();

            // Extended Spar Collar
            translate([-collar_w/2, -collar_h/2, 0])
                cube([collar_w, collar_h, spar_depth]);

            // Rear Single-Clamp Ear (Top side only, at the back)
            translate([-collar_w/2, collar_h/2 - 0.2, spar_depth - clamp_length])
                cube([collar_w, clamp_lug_h, clamp_length]);

            // Cardinal Triangular Gussets (0°, 90°, 180°, 270°)
            // 15mm long, completely forward of the rear clamp zone
            for (ang = [0, 90, 180, 270]) {
                rotate([0, 0, ang])
                    cardinal_gusset(length_z = 15.0, width = 2.8);
            }
        }

        // -------------------------------------------------------------
        // 2. SPAR SOCKET (10x10mm)
        // -------------------------------------------------------------
        translate([-spar_dim/2, -spar_dim/2, 0])
            cube([spar_dim, spar_dim, spar_depth + 1]);

        // -------------------------------------------------------------
        // 3. REAR CLAMPING SLIT (Isolated to clamp section)
        // -------------------------------------------------------------
        // Longitudinal slit through the top ear and top wall
        translate([-clamp_slit_w/2, 0, spar_depth - clamp_length - 0.5])
            cube([clamp_slit_w, collar_h/2 + clamp_lug_h + 1, clamp_length + 1]);

        // Small transverse relief slot to let the clamp ears flex freely
        translate([-(collar_w + 1)/2, spar_dim/2 - 0.1, spar_depth - clamp_length - 0.5])
            cube([collar_w + 1, clamp_lug_h + spar_wall + 1, clamp_slit_w]);

        // -------------------------------------------------------------
        // 4. SINGLE M3 CLAMP BOLT & NUT TRAP
        // -------------------------------------------------------------
        // Horizontal screw hole
        translate([-collar_w/2 - 1, clamp_screw_y, clamp_screw_z])
            rotate([0, 90, 0])
            cylinder(d = clamp_screw_dia, h = collar_w + 2);

        // Hex nut trap on +X side
        translate([collar_w/2 - clamp_nut_depth, clamp_screw_y, clamp_screw_z])
            rotate([0, 90, 0])
            cylinder(d = clamp_nut_dia, h = clamp_nut_depth + 1, $fn = 6);

        // Bolt head counterbore on -X side
        translate([-collar_w/2 - 0.1, clamp_screw_y, clamp_screw_z])
            rotate([0, 90, 0])
            cylinder(d = 6.2, h = 3.0);

        // -------------------------------------------------------------
        // 5. MOTOR BOLT HOLES & REAR SCREWDRIVER CHANNELS (22mm SQUARE)
        // -------------------------------------------------------------
        // Center motor shaft & circlip relief
        translate([0, 0, -faceplate_thick - 1])
            cylinder(d = motor_center_hole, h = faceplate_thick + 2);

        // 4x Motor Bolt Holes (22x22mm Square Pattern) + Driver Clearance
        for (sx = [-1, 1]) {
            for (sy = [-1, 1]) {
                // Bolt hole through faceplate
                translate([sx * motor_bolt_spacing/2, sy * motor_bolt_spacing/2, -faceplate_thick - 1])
                    cylinder(d = motor_bolt_dia, h = faceplate_thick + 2);

                // Rear clearance tunnel for screwdriver / hex bit access
                translate([sx * motor_bolt_spacing/2, sy * motor_bolt_spacing/2, -0.1])
                    cylinder(d = 5.8, h = spar_depth + 2);
            }
        }
    }
}

motor_mount();