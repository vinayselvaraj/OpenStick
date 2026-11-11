// ===================================================================
// Project: OpenStickFPV
// Component: Ultralight Wing Saddle Mount (Full-Edge Gusset Reinforcement)
// - Diagonal structural gussets extend to the absolute outer edge of the
//   dowel holders (X = +/- 60mm), providing direct shear reinforcement
//   against rubber band tension
// - Gussets terminate on the collar above Z=0, preserving a clean lip
// - 10mm extended bottom clamp with lateral zip-tie slots (left & right)
// - Full-length bottom longitudinal compression slit for solid spar lock
// - Reversible print-twice design: Identical front and rear wing saddles
// - 120mm span with inverted bottom-open cradles for 4.0-4.5mm chopsticks/dowels
// - 4.0mm square wing retaining stop lip (leading/trailing edge stop)
// - Dual weight-saving windows per wing side across the bed
// - 100% support-free 3D printing
// ===================================================================

$fn = 50;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 1.8;    // Structural collar wall thickness
mount_length         = 20.0;   // Chord along fuselage (Y-axis)

// --- Extended Bottom Zip-Tie Clamping Spec ---
clamp_drop           = 10.0;   // Extended 10mm lower below the collar base
ziptie_slot_w        = 3.6;    // Slot length along fuselage (fits <=3mm ties)
ziptie_slot_h        = 1.8;    // Slot vertical clearance (Z-axis)
pinch_slit_w         = 1.5;    // Bottom longitudinal compression slit

// --- Gusset Termination & Outreach Spec ---
gusset_termination_z = 3.5;    // Gusset terminates above collar base (Z=0)

// --- Wing Saddle Platform Spec ---
saddle_span_x        = 120.0;  // Span across fuselage (outermost tip is +/-60mm)
saddle_bed_thick     = 1.8;    // Shelf thickness
saddle_riser_height  = 4.0;    // Lift above spar collar

// --- Wing Retaining Lip (Square Stop Fence) ---
lip_height           = 4.0;    // Height above wing bed to capture foam edge
lip_thickness_y      = 2.0;    // Thickness of vertical stop wall

// --- Inverted Dowel Cradle Spec (Bottom-Open) ---
dowel_dia            = 4.8;    // Fits ~4.0-4.5mm chopsticks / wooden dowels
cradle_wall          = 1.6;    // Structural wall surrounding cradle
dowel_x_offset       = 55.0;   // Centerline of dowel (+/- X)

// Derived Dimensions
collar_w       = spar_width + 2 * sleeve_wall;  // ~13.75mm
collar_h       = spar_height + 2 * sleeve_wall; // ~13.75mm

spar_bottom_z  = 0;
spar_top_z     = spar_bottom_z + collar_h;
saddle_top_z   = spar_top_z + saddle_riser_height;
dowel_center_z = saddle_top_z - saddle_bed_thick - dowel_dia / 2;

clamp_bottom_z = spar_bottom_z - clamp_drop;
ziptie_z       = clamp_bottom_z + clamp_drop / 2;

// Full outer boundary of the dowel holder boss
dowel_outer_x  = dowel_x_offset + dowel_dia / 2 + cradle_wall; // 60.0mm (extreme edge)

module wing_saddle_full_edge_gusset() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES
        // -------------------------------------------------------------
        union() {
            // A. Central 10x10mm spar sleeve core
            translate([-collar_w/2, -mount_length/2, spar_bottom_z])
                cube([collar_w, mount_length, collar_h]);

            // B. Extended bottom clamp body (10mm lower, exact collar width)
            translate([-collar_w/2, -mount_length/2, clamp_bottom_z])
                cube([collar_w, mount_length, clamp_drop]);

            // C. Solid vertical riser post connecting collar to wing bed
            translate([-collar_w/2, -mount_length/2, collar_h - 0.1])
                cube([collar_w, mount_length, saddle_riser_height + 0.1]);

            // D. Unbroken horizontal wing shelf
            translate([-saddle_span_x/2, -mount_length/2, saddle_top_z - saddle_bed_thick])
                cube([saddle_span_x, mount_length, saddle_bed_thick]);

            // E. Clean 90-degree square wing retaining stop lip
            translate([-saddle_span_x/2, mount_length/2 - lip_thickness_y, saddle_top_z])
                cube([saddle_span_x, lip_thickness_y, lip_height]);

            // F. Full-Edge Diagonal Structural Truss Braces
            // Extends from collar side wall directly to the absolute outer tip of the dowel boss
            for (sx = [-1, 1]) {
                hull() {
                    // Inner root: lands on collar side wall above clamp area
                    translate([sx * (collar_w/2 - 0.1), -mount_length/2, gusset_termination_z])
                        cube([0.1, mount_length, collar_h + saddle_riser_height - gusset_termination_z]);

                    // Extreme outer termination: extends to the very outer edge of the dowel housing
                    translate([sx > 0 ? (dowel_outer_x - 0.2) : (-dowel_outer_x), -mount_length/2, saddle_top_z - saddle_bed_thick])
                        cube([0.2, mount_length, saddle_bed_thick]);

                    // Tie in to the underside of the outer dowel cradle cylinder
                    translate([sx * dowel_x_offset, 0, dowel_center_z])
                        rotate([90, 0, 0])
                        cylinder(d = dowel_dia + 2 * cradle_wall, h = mount_length, center = true);
                }
            }

            // G. Downward cradle bosses underneath the wing bed
            for (sx = [-1, 1]) {
                translate([sx * dowel_x_offset, 0, dowel_center_z])
                    rotate([90, 0, 0])
                    cylinder(d = dowel_dia + 2 * cradle_wall, h = mount_length, center = true);

                hull() {
                    translate([sx * dowel_x_offset, 0, dowel_center_z])
                        rotate([90, 0, 0])
                        cylinder(d = dowel_dia + 2 * cradle_wall, h = mount_length, center = true);
                    translate([
                        sx > 0 ? (dowel_x_offset - dowel_dia/2 - cradle_wall) : (-saddle_span_x/2),
                        -mount_length/2,
                        saddle_top_z - saddle_bed_thick
                    ])
                        cube([dowel_dia + 2 * cradle_wall, mount_length, saddle_bed_thick]);
                }
            }
        }

        // -------------------------------------------------------------
        // 2. 10x10mm SPAR CAVITY (Clean square carbon tunnel)
        // -------------------------------------------------------------
        translate([-spar_width/2, -mount_length/2 - 1, spar_bottom_z + sleeve_wall])
            cube([spar_width, mount_length + 2, spar_height]);

        // -------------------------------------------------------------
        // 3. BOTTOM-OPEN DOWEL CRADLES
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            translate([sx * dowel_x_offset, 0, dowel_center_z])
                rotate([90, 0, 0])
                cylinder(d = dowel_dia, h = mount_length + 2, center = true);

            translate([sx * dowel_x_offset - dowel_dia/2, -mount_length/2 - 1, dowel_center_z - 10.0])
                cube([dowel_dia, mount_length + 2, 10.0]);
        }

        // -------------------------------------------------------------
        // 4. STANDARD DUAL LIGHTENING WINDOWS PER SIDE
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            translate([sx * 22.0, -lip_thickness_y / 2, saddle_top_z - saddle_bed_thick - 1])
                cube([15.0, mount_length - lip_thickness_y - 6.0, saddle_bed_thick + 2], center = true);

            translate([sx * 41.0, -lip_thickness_y / 2, saddle_top_z - saddle_bed_thick - 1])
                cube([15.0, mount_length - lip_thickness_y - 6.0, saddle_bed_thick + 2], center = true);
        }

        // -------------------------------------------------------------
        // 5. EXTENDED LATERAL ZIP-TIE SLOTS (Right & Left)
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            translate([sx * collar_w/4, 0, ziptie_z])
                cube([collar_w/2 + 2, ziptie_slot_w, ziptie_slot_h], center = true);
        }

        // -------------------------------------------------------------
        // 6. BOTTOM LONGITUDINAL COMPRESSION SLIT
        // -------------------------------------------------------------
        translate([-pinch_slit_w/2, -mount_length/2 - 1, clamp_bottom_z - 1])
            cube([pinch_slit_w, mount_length + 2, clamp_drop + sleeve_wall + 1.2]);
    }
}

wing_saddle_full_edge_gusset();