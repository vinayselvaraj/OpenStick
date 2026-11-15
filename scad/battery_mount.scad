// ===================================================================
// Project: OpenStickFPV
// Component: Modular 2200mAh 3S Battery Saddle Mount (Print 2x: Front & Rear)
// - Fits standard 2200mAh 3S LiPo packs (~34-36mm wide; pocket set to 36.5mm)
// - 5.0mm tall side retaining walls keep the battery centered and prevent
//   lateral sliding during rolls and rough landings
// - Recessed Velcro battery strap pass-through slot underneath the tray
//   so the battery strap wraps cleanly around the pack & tray without
//   interfering with the 10x10mm carbon spar underneath
// - Spar Attachment: Mounts to 10x10mm carbon fiber spar using the same
//   flush 10mm upper extension with lateral zip-tie slot & compression slit
// - 20.0mm fore-aft length along the carbon rod (print 2 identical units)
// - Print Orientation: Print sideways (front or rear face flat on build plate)
//   for 100% support-free 3D printing
// ===================================================================

$fn = 50;

// --- Fuselage Spar Spec (10x10mm Square) ---
spar_width           = 10.15;  // 10x10mm spar (+0.15mm printer tolerance)
spar_height          = 10.15;  // 10x10mm spar height
sleeve_wall          = 1.8;    // Structural collar wall thickness
mount_length         = 20.0;   // Fore-aft length along the carbon rod (Y-axis)

// --- Zip-Tie Clamping System (Matches Landing Gear & Wing Mounts) ---
clamp_rise           = 10.0;   // Extension from collar for zip-tie slot
ziptie_slot_w        = 5.0;    // Slot width along fuselage (fits up to 4.8mm ties)
ziptie_slot_h        = 2.8;    // Slot vertical clearance (Z-axis)
pinch_slit_w         = 1.5;    // Longitudinal compression slit

// --- 2200mAh 3S Battery Tray & Side Walls ---
// Standard 2200mAh 3S LiPo is ~34-35mm wide; 36.5mm gives a snug fit with foam/velcro
battery_pocket_w     = 36.5;   // Clear inner width between side walls (X-axis)
side_wall_thick      = 2.2;    // Thickness of left/right retaining walls
side_wall_height     = 5.0;    // 5.0mm tall side walls to prevent battery sliding out
tray_floor_thick     = 3.8;    // Thick enough to house the Velcro strap slot underneath

// --- Velcro Battery Strap Pass-Through Slot ---
strap_slot_w         = 16.5;   // Fits standard 15mm-16mm wide LiPo Velcro straps
strap_slot_h         = 1.8;    // Vertical clearance for Velcro strap pass-through

// --- Gusset Termination Spec ---
// Terminates 3.5mm away from the collar clamping end so the leaves flex easily
gusset_flex_offset   = 3.5;

// Derived Dimensions
collar_w             = spar_width + 2 * sleeve_wall;        // ~13.75mm
collar_h             = spar_height + 2 * sleeve_wall;       // ~13.75mm
tray_total_w         = battery_pocket_w + 2 * side_wall_thick; // 40.9mm

// Vertical Stack (Z-axis: Tray on top of spar, zip-tie clamp hanging below spar)
// Note: Can also be mounted inverted (battery slung below spar) with zero changes
clamp_bot_z          = 0;
spar_collar_bot_z    = clamp_bot_z + clamp_rise;
spar_collar_top_z    = spar_collar_bot_z + collar_h;

tray_bot_z           = spar_collar_top_z;
tray_bed_z           = tray_bot_z + tray_floor_thick;
side_wall_top_z      = tray_bed_z + side_wall_height;

ziptie_z             = clamp_bot_z + clamp_rise / 2;
gusset_start_z       = spar_collar_bot_z + gusset_flex_offset;

module battery_mount_2200_3s() {
    difference() {
        // -------------------------------------------------------------
        // 1. ADDITIVE SHAPES
        // -------------------------------------------------------------
        union() {
            // A. Battery Tray Floor (40.9mm wide x 20.0mm long x 3.8mm thick)
            translate([-tray_total_w/2, -mount_length/2, tray_bot_z])
                cube([tray_total_w, mount_length, tray_floor_thick]);

            // B. Left (-X) & Right (+X) 5.0mm Battery Retaining Side Walls
            for (sx = [-1, 1]) {
                translate([
                    sx > 0 ? (battery_pocket_w/2) : (-tray_total_w/2),
                    -mount_length/2,
                    tray_bed_z - 0.1
                ])
                    cube([side_wall_thick, mount_length, side_wall_height + 0.1]);
            }

            // C. Central 10x10mm Spar Sleeve Core (20.0mm Length)
            translate([-collar_w/2, -mount_length/2, spar_collar_bot_z - 0.1])
                cube([collar_w, mount_length, collar_h + 0.2]);

            // D. Extended Zip-Tie Clamp Body (10mm extension, flush collar width)
            translate([-collar_w/2, -mount_length/2, clamp_bot_z])
                cube([collar_w, mount_length, clamp_rise + 0.1]);

            // E. Coplanar Diagonal Gussets (Flush with Front/Rear Faces at Y = +/- 10.0mm)
            // Supports the outboard battery tray edges while keeping front/rear faces
            // 100% flat for support-free sideways 3D printing
            for (sx = [-1, 1]) {
                hull() {
                    // Inner root on collar side wall (stops 3.5mm clear of flex zone)
                    translate([sx * (collar_w/2 - 0.1), -mount_length/2, gusset_start_z])
                        cube([0.1, mount_length, spar_collar_top_z - gusset_start_z]);

                    // Outer edge meeting the underside of the battery tray
                    translate([
                        sx > 0 ? (tray_total_w/2 - 0.1) : (-tray_total_w/2),
                        -mount_length/2,
                        tray_bot_z
                    ])
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
        // 3. VELCRO BATTERY STRAP PASS-THROUGH SLOT (Under Tray Bed)
        // -------------------------------------------------------------
        // Allows a 15-16mm Velcro strap to pass laterally beneath the battery
        // without touching the carbon spar or gussets
        translate([0, 0, tray_bot_z + tray_floor_thick/2])
            cube([tray_total_w + 2, strap_slot_w, strap_slot_h], center = true);

        // -------------------------------------------------------------
        // 4. LATERAL ZIP-TIE SLOT (Spar Clamp)
        // -------------------------------------------------------------
        for (sx = [-1, 1]) {
            translate([sx * collar_w/4, 0, ziptie_z])
                cube([collar_w/2 + 2, ziptie_slot_w, ziptie_slot_h], center = true);
        }

        // -------------------------------------------------------------
        // 5. LONGITUDINAL COMPRESSION SLIT
        // -------------------------------------------------------------
        translate([-pinch_slit_w/2, -mount_length/2 - 1, clamp_bot_z - 1])
            cube([pinch_slit_w, mount_length + 2, clamp_rise + sleeve_wall + 1.2]);
    }
}

battery_mount_2200_3s();