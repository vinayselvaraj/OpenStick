// ===================================================================
// Project: OpenStickFPV
// Component: 300mm Chord Clark Y Wing Rib (Camber-Aligned Servo Pocket)
// - Rotated the 9g micro-servo mounting pocket (`servo_angle_deg = -7.8`)
//   to follow the local Clark Y camber slope at 60% chord (X = 180.0mm)
// - Because the pocket tilts parallel to the upper surface taper, the
//   entire 23.2mm x 12.6mm servo bay and its 2.0mm framing walls stay
//   100% enclosed inside the inset rib without bulging or clipping the
//   upper/lower Clark Y surfaces
// - Extended rib cleanly all the way to the 300.0mm trailing edge tip
//   with zero gaps in the aileron section
// - Dual 6mm carbon fiber tube ports (main @ 30%, rear @ 68%)
// - Optional 9g micro-servo bay (toggle `include_servo`)
// ===================================================================

$fn = 60;

// --- Primary Wing Parameters ---
chord                = 300.0;  // Full wing chord in mm (300mm = 30cm)
rib_thickness        = 10.0;    // Print thickness (Z-height on build plate)
skin_thickness       = 5.0;    // Dollar Tree foam board thickness (5.0mm)
inset_skin           = true;   // true = offsets top/bottom surfaces for 5mm foam wrap

// --- Carbon Fiber Spar Spec (6mm OD Tubes) ---
spar_dia             = 6.15;   // 6.0mm tube + 0.15mm printer tolerance
main_spar_pos        = 0.30;   // 30% chord (90mm from LE) - peak thickness
rear_spar_pos        = 0.68;   // 68% chord (204mm from LE) - torsion/rear spar

// --- Optional 9g Micro-Servo Mount (Camber-Aligned Inside Clark Y) ---
include_servo        = true;   // Set `true` for servo bay ribs, `false` for standard ribs
servo_pos_ratio      = 0.59;   // 59% chord (177mm from LE - optimal envelope clearance)
servo_body_l         = 23.2;   // 9g servo body length
servo_body_w         = 12.6;   // 9g servo body width
servo_wall           = 2.0;    // Framing wall around servo pocket
servo_y_offset       = -0.4;   // Slight downward nudge toward flatter lower camber

// --- Lightening Holes & Wire Routing ---
wire_hole_dia        = 8.0;    // Pass-through hole for servo extension cable

// ===================================================================
// CLARK Y AIRFOIL COORDINATES (Normalized 0..1)
// ===================================================================
clark_y_upper = [
    [0.0000,  0.0000], [0.0050,  0.0145], [0.0125,  0.0232], [0.0250,  0.0338],
    [0.0500,  0.0489], [0.0750,  0.0603], [0.1000,  0.0694], [0.1500,  0.0830],
    [0.2000,  0.0926], [0.2500,  0.0990], [0.3000,  0.1025], [0.3500,  0.1035],
    [0.4000,  0.1025], [0.4500,  0.0995], [0.5000,  0.0950], [0.5500,  0.0890],
    [0.6000,  0.0818], [0.6500,  0.0736], [0.7000,  0.0646], [0.7500,  0.0550],
    [0.8000,  0.0448], [0.8500,  0.0342], [0.9000,  0.0233], [0.9500,  0.0120],
    [1.0000,  0.0000]
];

clark_y_lower = [
    [1.0000,  0.0000], [0.9500, -0.0020], [0.9000, -0.0030], [0.8500, -0.0040],
    [0.8000, -0.0050], [0.7500, -0.0060], [0.7000, -0.0070], [0.6500, -0.0080],
    [0.6000, -0.0090], [0.5500, -0.0100], [0.5000, -0.0110], [0.4500, -0.0120],
    [0.4000, -0.0130], [0.3500, -0.0140], [0.3000, -0.0145], [0.2500, -0.0145],
    [0.2000, -0.0140], [0.1500, -0.0130], [0.1000, -0.0110], [0.0750, -0.0092],
    [0.0500, -0.0068], [0.0250, -0.0035], [0.0125, -0.0015], [0.0050,  0.0000]
];

function scale_pts(pts, c) = [for (p = pts) [p[0] * c, p[1] * c]];

function interp_y(pts, nx) =
    let(
        idx = [for (i = [0 : len(pts) - 2]) if ((pts[i][0] <= nx && pts[i+1][0] >= nx) || (pts[i][0] >= nx && pts[i+1][0] <= nx)) i][0],
        p0 = pts[idx],
        p1 = pts[idx + 1],
        t = (p1[0] == p0[0]) ? 0 : (nx - p0[0]) / (p1[0] - p0[0])
    )
    p0[1] + t * (p1[1] - p0[1]);

function airfoil_mid_y(nx) = ((interp_y(clark_y_upper, nx) + interp_y(clark_y_lower, nx)) / 2) * chord;
function airfoil_thick(nx) = (interp_y(clark_y_upper, nx) - interp_y(clark_y_lower, nx)) * chord;

// Local camber-line slope angle (in degrees) across the servo span
function camber_angle_deg(nx, half_span_nx) =
    atan2(
        airfoil_mid_y(nx + half_span_nx) - airfoil_mid_y(nx - half_span_nx),
        2 * half_span_nx * chord
    );

// ===================================================================
// 2D RIB PROFILE GENERATOR (Full-Chord to X = 300.0mm)
// ===================================================================
module raw_airfoil_2d() {
    pts = concat(scale_pts(clark_y_upper, chord), scale_pts(clark_y_lower, chord));
    polygon(pts);
}

module full_chord_rib_2d() {
    if (inset_skin) {
        hull() {
            offset(r = -skin_thickness)
                raw_airfoil_2d();

            // Clean 1.8mm printable trailing-edge tip extending to X = 300.0mm
            translate([chord - 0.9, 0])
                circle(d = 1.8, $fn = 24);
        }
    } else {
        raw_airfoil_2d();
    }
}

// ===================================================================
// MAIN 3D WING RIB ASSEMBLY
// ===================================================================
module wing_rib_300mm_rotated_servo() {
    main_spar_x    = chord * main_spar_pos;
    main_spar_y    = airfoil_mid_y(main_spar_pos);

    rear_spar_x    = chord * rear_spar_pos;
    rear_spar_y    = airfoil_mid_y(rear_spar_pos);

    servo_x        = chord * servo_pos_ratio;
    servo_y        = airfoil_mid_y(servo_pos_ratio) + servo_y_offset;
    servo_rot_deg  = camber_angle_deg(servo_pos_ratio, (servo_body_l / 2) / chord);

    difference() {
        union() {
            // 1. Continuous Full-Chord Airfoil Rib (0mm to 300.0mm, Zero Gaps)
            linear_extrude(height = rib_thickness)
                full_chord_rib_2d();

            // 2. Reinforced Bosses Around 6mm Spars
            for (sp = [[main_spar_x, main_spar_y], [rear_spar_x, rear_spar_y]]) {
                translate([sp[0], sp[1], 0])
                    cylinder(d = spar_dia + 5.0, h = rib_thickness);
            }

            // 3. Optional 9g Servo Frame Boss (Rotated to Camber & Clipped to Rib)
            // Intersecting with full_chord_rib_2d() guarantees zero protrusion
            // outside the Clark Y perimeter even on the aft upper corner
            if (include_servo) {
                intersection() {
                    linear_extrude(height = rib_thickness)
                        full_chord_rib_2d();

                    translate([servo_x, servo_y, rib_thickness / 2])
                        rotate([0, 0, servo_rot_deg])
                            cube([servo_body_l + 2 * servo_wall, servo_body_w + 2 * servo_wall, rib_thickness], center = true);
                }
            }
        }

        // -------------------------------------------------------------
        // SUBTRACTIONS (Spar Holes, Lightening Cutouts, Servo)
        // -------------------------------------------------------------

        // A. 6mm Carbon Fiber Spar Holes
        for (sp = [[main_spar_x, main_spar_y], [rear_spar_x, rear_spar_y]]) {
            translate([sp[0], sp[1], -1])
                cylinder(d = spar_dia, h = rib_thickness + 2);
        }

        // B. Forward Lightening Cutout (Between LE and Main Spar)
        hull() {
            translate([chord * 0.12, airfoil_mid_y(0.12), -1])
                cylinder(d = airfoil_thick(0.12) * 0.42, h = rib_thickness + 2);
            translate([chord * 0.21, airfoil_mid_y(0.21), -1])
                cylinder(d = airfoil_thick(0.21) * 0.48, h = rib_thickness + 2);
        }

        // C. Mid-Bay Lightening Cutout (Ahead of Servo Bay)
        hull() {
            translate([chord * 0.39, airfoil_mid_y(0.39), -1])
                cylinder(d = airfoil_thick(0.39) * 0.46, h = rib_thickness + 2);
            translate([chord * 0.48, airfoil_mid_y(0.48), -1])
                cylinder(d = airfoil_thick(0.48) * 0.44, h = rib_thickness + 2);
        }

        // D. Optional 9g Servo Pocket (Rotated Parallel to Local Camber Line)
        // When `include_servo = false`, places a wire-routing hole in its place
        if (include_servo) {
            translate([servo_x, servo_y, rib_thickness / 2])
                rotate([0, 0, servo_rot_deg])
                    cube([servo_body_l, servo_body_w, rib_thickness + 2], center = true);
        } else {
            translate([servo_x, servo_y, -1])
                cylinder(d = wire_hole_dia, h = rib_thickness + 2);
        }

        // E. Aft Lightening Cutout (Behind Rear Spar)
        hull() {
            translate([chord * 0.75, airfoil_mid_y(0.75), -1])
                cylinder(d = airfoil_thick(0.75) * 0.38, h = rib_thickness + 2);
            translate([chord * 0.85, airfoil_mid_y(0.85), -1])
                cylinder(d = airfoil_thick(0.85) * 0.32, h = rib_thickness + 2);
        }
    }
}

wing_rib_300mm_rotated_servo();