// ===================================================================
// Project: OpenStickFPV
// Component: Integrated Empennage & Tail Skid Assembly (Dual-Layer DTFB)
// - Sized for folded/double-layer laminated Dollar Tree Foam Board (~10.5mm)
// - Round counterbore recesses on underside for screw heads / round nuts / washers
// - Left-to-right horizontal cross-holes for vertical fin clamping
// - Dual zip-tie clamp around 10x10mm spar with full longitudinal slit
// - Seamless monolithic ramp-blended tail skid (zero-support 3D print)
// ===================================================================

$fn = 60;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 1.5;    // Sleeve wall thickness
sleeve_length        = 48.0;   // Length along fuselage (Y-axis)

// --- Folded Dollar Tree Foam Board (Dual-Layer DTFB) Spec ---
foam_thick_double    = 10.5;   // Width of vertical fin channel for folded double DTFB
vstab_depth          = 14.0;   // Vertical slot depth holding fin upright
vstab_wall           = 1.8;    // Wall thickness of vertical guide spine
hstab_tape_span_x    = 66.0;   // Overall width across fuselage (X-axis)
hstab_tape_chord_y   = sleeve_length;
tape_shelf_thick     = 2.2;    // Shelf thickness reinforced for fasteners

// --- Fastener Hardware Spec (M3 Sizing with Round Pockets) ---
screw_hole_d         = 3.3;    // M3 clearance through-hole
round_pocket_d       = 6.5;    // Round counterbore diameter (fits M3 socket head / locknut / washer)
round_pocket_depth   = 1.8;    // Counterbore recess depth on underside

// Fastener Locations
hstab_screw_y        = [-14.0, -34.0]; // Y positions along horizontal shelves
hstab_screw_x_dist   = 20.0;           // Distance from centerline (+/- X)
vstab_screw_y        = [-14.0, -34.0]; // Y positions along vertical spine
vstab_screw_z        = 6.5;            // Height above horizontal shelf

// --- Dual Zip-Tie Clamp Spec ---
ziptie_width         = 3.4;    // Sized for standard small zip-ties (2.5mm wide)
ziptie_depth         = 0.8;    // Retention channel depth
ziptie_inset         = 7.0;    // Inset from collar front and rear ends
slit_width           = 1.4;    // Top compression pinch slit

// --- Tail Skid Spec ---
skid_width           = 5.0;    // Runner thickness across X
skid_drop            = 22.0;   // Ground clearance drop below spar
skid_heel_radius     = 6.0;    // Rounded ground contact curvature
skid_extension_rear  = 16.0;   // Rearward extension past collar rear face

// Derived Dimensions
collar_w = spar_width + 2 * sleeve_wall;
collar_h = spar_height + 2 * sleeve_wall;
vstab_spine_w = foam_thick_double + 2 * vstab_wall;

// Continuous ramp profile blending into collar
module slim_skid_profile() {
    polygon(points = [
        [-sleeve_length, 0],
        [-sleeve_length * 0.65, -skid_drop * 0.38],
        [-sleeve_length * 0.25, -skid_drop * 0.75],
        [skid_extension_rear - skid_heel_radius * 2, -skid_drop],
        [skid_extension_rear - 1.0, -skid_drop + 1.0],
        [skid_extension_rear, -skid_drop + skid_heel_radius],
        [skid_extension_rear - 2.0, -skid_drop + skid_heel_radius * 1.5],
        [0, -1.5],
        [0, 0]
    ]);
}

module empennage_tail_assembly_round_recess() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES (Collar, Runner, Shelves, Vertical Spine)
        // -------------------------------------------------------------
        union() {
            // Main rectangular 10x10mm spar sleeve
            translate([-collar_w/2, -sleeve_length, 0])
                cube([collar_w, sleeve_length, collar_h]);

            // Lower Ground Runner (5mm wide, smooth ramp)
            translate([-skid_width/2, 0, 0])
                rotate([90, 0, 90])
                linear_extrude(height = skid_width)
                    slim_skid_profile();

            // Blended transition merging runner into front collar lip
            hull() {
                translate([-collar_w/2, -sleeve_length, 0])
                    cube([collar_w, 3.0, 0.8]);
                translate([-skid_width/2, -sleeve_length * 0.5, -skid_drop * 0.35])
                    cube([skid_width, 3.0, 0.8]);
            }

            // Horizontal Stabilizer Shelves
            translate([-hstab_tape_span_x/2, -sleeve_length, collar_h - tape_shelf_thick])
                cube([hstab_tape_span_x, hstab_tape_chord_y, tape_shelf_thick]);

            // Stiffening gussets supporting H-stab platforms from collar
            for (sx = [-1, 1]) {
                hull() {
                    translate([sx * (collar_w/2 - 0.1), -sleeve_length, collar_h - tape_shelf_thick])
                        cube([0.1, sleeve_length, tape_shelf_thick]);
                    translate([sx * (collar_w/2), -sleeve_length, collar_h - tape_shelf_thick - 3.5])
                        cube([0.1, sleeve_length, 0.1]);
                    translate([sx * (hstab_tape_span_x/2 - 6.0), -sleeve_length, collar_h - tape_shelf_thick])
                        cube([0.1, sleeve_length, tape_shelf_thick]);
                }
            }

            // Vertical Stabilizer Channel Spine
            translate([-vstab_spine_w/2, -sleeve_length, collar_h])
                cube([vstab_spine_w, sleeve_length, vstab_depth]);
        }

        // -------------------------------------------------------------
        // 2. 10x10mm SPAR CAVITY
        // -------------------------------------------------------------
        translate([-spar_width/2, -sleeve_length - 1, sleeve_wall])
            cube([spar_width, sleeve_length + 2, spar_height]);

        // -------------------------------------------------------------
        // 3. FOLDED DUAL-SHEET V-STAB CHANNEL (10.5mm Wide)
        // -------------------------------------------------------------
        translate([-foam_thick_double/2, -sleeve_length - 1, collar_h])
            cube([foam_thick_double, sleeve_length + 2, vstab_depth + 1]);

        // -------------------------------------------------------------
        // 4. HORIZONTAL STABILIZER VERTICAL THROUGH-HOLES & ROUND POCKETS
        // -------------------------------------------------------------
        // 4 M3 clearance holes with circular counterbore recesses on underside
        for (sx = [-1, 1]) {
            for (y_pos = hstab_screw_y) {
                // 3.3mm M3 through-hole
                translate([sx * hstab_screw_x_dist, y_pos, collar_h - tape_shelf_thick - 5])
                    cylinder(d = screw_hole_d, h = tape_shelf_thick + 10);

                // 6.5mm circular counterbore recess on bottom face
                translate([sx * hstab_screw_x_dist, y_pos, collar_h - tape_shelf_thick - 0.01])
                    cylinder(d = round_pocket_d, h = round_pocket_depth);
            }
        }

        // -------------------------------------------------------------
        // 5. VERTICAL STABILIZER HORIZONTAL CROSS-HOLES
        // -------------------------------------------------------------
        // 2 M3 through-bolts passing left-to-right across the V-fin slot
        for (y_pos = vstab_screw_y) {
            translate([-vstab_spine_w/2 - 1, y_pos, collar_h + vstab_screw_z])
                rotate([0, 90, 0])
                cylinder(d = screw_hole_d, h = vstab_spine_w + 2);
        }

        // -------------------------------------------------------------
        // 6. DUAL ZIP-TIE RETENTION GROOVES
        // -------------------------------------------------------------
        for (y_pos = [-ziptie_inset, -(sleeve_length - ziptie_inset)]) {
            translate([0, y_pos, collar_h/2])
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
        translate([-slit_width/2, -sleeve_length - 1, sleeve_wall + spar_height/2])
            cube([slit_width, sleeve_length + 2, collar_h + vstab_depth]);

        // -------------------------------------------------------------
        // 8. CORNER CHAMFERS
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            for (sy = [0, -sleeve_length]) {
                translate([sx * hstab_tape_span_x/2, sy, collar_h])
                    rotate([0, 0, 45])
                    cube([8.0, 8.0, tape_shelf_thick * 5], center = true);
            }
        }
    }
}

empennage_tail_assembly_round_recess();