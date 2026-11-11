# OpenStick

Open source 3D model designs for the **Slow Stick FPV** RC airplane.

This repository hosts the parametric [OpenSCAD](https://openscad.org/) source files for the printed structural components of the airframe, plus the build pipeline that turns them into ready-to-print STL files.

## Repository Layout

```
OpenStick/
├── scad/                 # OpenSCAD source files (the canonical designs)
│   ├── motor_mount.scad                    # Centered motor mount, single-screw clamp
│   ├── landing_gear_bottom_attachment.scad # Wide-base landing gear mount
│   └── tail_skid.scad                      # Monolithic ramp-blended tail skid
├── .github/workflows/
│   └── release.yml         # Renders scad/ → STL and publishes a GitHub Release
├── LICENSE                 # GNU GPL v3
└── README.md
```

Generated STL files are **not** stored in the repo. They are published as GitHub Release artifacts (see [Getting the Files](#getting-the-files)).

## Designs

| Component | Source | Description |
| --------- | ------ | ----------- |
| Motor mount | [`scad/motor_mount.scad`](scad/motor_mount.scad) | Centered mount for a 10×10 mm spar with slotted 21.5–22.5 mm cross motor bolt pattern, extended 34 mm collar with a dedicated rear single-M3 pinch clamp, and 4 identical cardinal gussets for 4-way rigidity. |
| Landing gear bottom attachment | [`scad/landing_gear_bottom_attachment.scad`](scad/landing_gear_bottom_attachment.scad) | Flat-printing (no overhangs) wide-base landing gear mount: 50 mm gear contact span with a 20 mm gear channel and front/rear retaining lips, plus a centered 10×10 mm spar saddle on top. |
| Tail skid | [`scad/tail_skid.scad`](scad/tail_skid.scad) | Monolithic ramp-blended tail skid: a single continuous wedge from the front rim down to an 8 mm ground runner (no intermediate steps or floating lugs), rounded 7 mm ground-contact heel extended 20 mm past the collar, flanking gusset ramps blending the runner into the sleeve, dual zip-tie retention channels and a full-length longitudinal pinch slit; prints support-free (flat on its side or inverted). |

All three components are built around a **10×10 mm spar** airframe and include small printing-tolerance allowances in their channel dimensions (e.g. `10.15 mm`, `20.2 mm`).

## Getting the Files

### From the GitHub Release (easiest)

Every push to `main` runs the [Build & Release workflow](.github/workflows/release.yml), which renders all `.scad` files in [`scad/`](scad) to STL with OpenSCAD and publishes a GitHub Release (tagged `v<commit-sha>`) containing the STL downloads.

Grab the STLs from the [releases page](https://github.com/vinayselvaraj/OpenStick/releases) — the latest release always corresponds to the newest commit on `main`.

### Render Locally

If you want to tweak parameters (all dimensions are variables at the top of each file) and print your own STL:

```sh
# macOS
brew install openscad
# Debian/Ubuntu
sudo apt-get install openscad

openscad -o dist/motor_mount.stl scad/motor_mount.scad
```

Or, faster for iteration, render a preview inside OpenSCAD itself:

```sh
openscad scad/motor_mount.scad
```

## Contributing

Contributions are welcome:

1. Fork the repo and create a feature branch.
2. Add or modify OpenSCAD designs in [`scad/`](scad). Keep new designs self-contained single files, with dimensions defined as commented variables at the top.
3. Keep designs print-friendly: avoid overhangs where possible, and bake in realistic FDM tolerances in the channel/slot dimensions.
4. Open a pull request — the STL in the release is regenerated automatically on merge.

Please keep new designs compatible with the 10×10 mm spar airframe, or clearly document the spar/fitment they target.

## License

All designs in this repository are licensed under the [GNU General Public License v3](LICENSE). You are free to use, modify, and share them — including printed parts — provided you keep them under the same license.
