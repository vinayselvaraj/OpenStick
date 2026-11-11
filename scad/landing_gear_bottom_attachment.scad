// ===================================================================
// Project: OpenStickFPV
// Component: Wide-Base Landing Gear Mount for 10x10mm Spar (No Overhangs)
// - Gear attachment area: 50mm width across fuselage (X-axis)
// - Gear chord: 20mm channel bounded by front/rear retaining lips (Y-axis)
// - Top spar saddle: Centered 10x10mm channel (Y-axis)
// - All four corner overhangs/lips removed to allow flat, clean printing
// ===================================================================

$fn = 40;

// --- Fuselage Spar Spec (Y-Axis) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm tolerance)
spar_depth_seat      = 4.5;    // Saddle depth into top

// --- Landing Gear Spec (X-Axis) ---
gear_contact_width   = 50.0;   // 50mm landing gear contact span
gear_chord_y         = 20.2;   // 20mm gear width (+0.2mm tolerance, Y-axis)
gear_recess_depth    = 1.5;    // Retaining lip depth
retaining_lip_y      = 1.8;    // Front/rear retaining lip thickness

// --- Structural Web & Sizing ---
spar_gear_gap        = 1.6;    // Solid separation web between spar and gear
mount_height_total   = gear_recess_depth + spar_gear_gap + spar_depth_seat; // 7.6mm
mount_length_y       = gear_chord_y + 2 * retaining_lip_y; // 23.8mm
mount_width_x        = gear_contact_width;                 // 50.0mm

// Derived boundary coordinates
spar_channel_bottom_z = gear_recess_depth + spar_gear_gap;

module landing_gear_mount_no_overhangs() {
    difference() {
        // -------------------------------------------------------------
        // 1. MAIN BODY WITH TAPERED WINGS
        // -------------------------------------------------------------
        union() {
            // Central spar saddle column
            translate([-(spar_width + 4.0)/2, -mount_length_y/2, 0])
                cube([spar_width + 4.0, mount_length_y, mount_height_total]);

            // Full 50mm wide bottom gear plate
            translate([-mount_width_x/2, -mount_length_y/2, 0])
                cube([mount_width_x, mount_length_y, spar_channel_bottom_z + 1.0]);

            // Triangular tapers from spar collar down to 50mm wings
            hull() {
                translate([-(spar_width + 4.0)/2, -mount_length_y/2, 0])
                    cube([spar_width + 4.0, mount_length_y, mount_height_total]);
                translate([-mount_width_x/2, -mount_length_y/2, 0])
                    cube([mount_width_x, mount_length_y, spar_channel_bottom_z]);
            }
        }

        // -------------------------------------------------------------
        // 2. BOTTOM GEAR CHANNEL (Full 50mm width across X)
        // -------------------------------------------------------------
        translate([-mount_width_x/2 - 1, -gear_chord_y/2, -0.01])
            cube([mount_width_x + 2, gear_chord_y, gear_recess_depth + 0.01]);

        // -------------------------------------------------------------
        // 3. TOP SPAR SADDLE (Centered along Y)
        // -------------------------------------------------------------
        translate([-spar_width/2, -mount_length_y/2 - 1, spar_channel_bottom_z])
            cube([spar_width, mount_length_y + 2, spar_depth_seat + 1]);

        // -------------------------------------------------------------
        // 4. CORNER CUTOUTS (Removes overhanging outer lip corners)
        // -------------------------------------------------------------
        // Clears the front and rear retaining lips beyond the central tower,
        // eliminating the unsupported overhangs outside the spar width.
        for (sx = [-1, 1]) {
            translate([
                sx * (mount_width_x/2 + (spar_width + 4.0)/4), 
                0, 
                -0.01
            ])
                cube([
                    mount_width_x/2 - (spar_width + 4.0)/4 + 1, 
                    mount_length_y + 2, 
                    gear_recess_depth + 0.02
                ], center = true);
        }
    }
}

landing_gear_mount_no_overhangs();