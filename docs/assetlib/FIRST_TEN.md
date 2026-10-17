# PAC AssetLib — first 10 production candidates

A row describes an acquisition target, **not an installed model**. Final measurements are approximate design targets; adapt imported mesh and collisions without stretching it unnaturally.

| ID | Asset | Design size (m) | Intended use | Appearance / acceptance test | Collision / physics | Priority |
|---|---|---:|---|---|---|---|
| arch_wall_panel_a | Modular wall panel | 2w x 3.4h | Command deck, corridors | Repeating painted steel, mounting rails, seam lines; can tile with no visible gap | static box or concave static collision | P0 |
| arch_floor_panel_a | Floor panel | 2 x 2 | Base room footprint | Worn dark metal, inset edge or grate; walkable, no clipping seams | static plane/box | P0 |
| arch_ceiling_panel_a | Ceiling panel | 2 x 2 | Interior roofing | Cable/service recess and lamp sockets; matching grid | no dynamic collision needed | P1 |
| arch_door_security_slide_a | Security sliding door | 1.6-2w x 2.5h | Room transitions | Credible frame, tracks, mechanical door leaf, hazard details | animated leaf: AnimatableBody3D; trigger Area3D | P0 |
| mach_generator_medium_a | Backup generator | approx 2.2w x 1.6h x 1.1d | Engineering room | Detailed textured machine: casing, ventilation, fuel/electrical hookups, exhaust | simplified static collision, interactive control as Area3D | P0 |
| mach_console_wall_a | Wall control station | approx 1.5w x 1.5h x 0.5d | Command deck | Physical keys, screens and bezels, readable silhouette from fixed cameras | static collision, UI trigger | P0 |
| mach_server_rack_a | Server / comm rack | approx 0.8w x 2.1h x 1.0d | Command deck / IT | Drawers, service lights, dense detailing; not a plain box | static box collision | P1 |
| infra_pipe_straight_a | Industrial pipe segment | 2m long | Engineering dressing | Metallic pipe + clamps; rotate and tile reliably | static collision only if accessible | P1 |
| prop_crate_large_a | Cargo crate | approx 1 x 1 x 1 | Storage / cover | Worn rugged container with hardware and clear silhouette | RigidBody3D if movable; otherwise StaticBody3D | P0 |
| light_emergency_red_a | Emergency lamp | approx 0.35m | Corridors / alarms | Actual lamp housing, emissive surface, separate light node | no collision; OmniLight3D | P0 |

## Review checklist for each model
- [ ] Source page and author saved
- [ ] Commercially usable licence identified
- [ ] True textured mesh available in original format (GLB preferred)
- [ ] Correct scale and pivot
- [ ] PBR materials and textures load in Godot
- [ ] Similar design language to other PAC assets
- [ ] Collision appropriate to function; movable physics tested if applicable
- [ ] Good visual quality from PAC fixed cameras
- [ ] Added to inventory with 'PAC-ready' status
