# PAC AssetLib v0.1

Purpose: reusable, textured 3D game assets for Project Alien Crisis (PAC), Godot 4.

## Style
Used retro-industrial research facility. Functional machinery, dark painted steel, worn surfaces, cool work lights, amber/red emergency lights. No default glossy/clean or cartoon look.

## Rules
- 1 Godot unit = 1 metre. Positive Y up.
- Real imported 3D meshes with materials; code-generated boxes are prototypes only.
- Prefer glTF/GLB with PBR materials. Keep model, textures, and attribution/licence records together.
- Static environment: StaticBody3D and explicit simplified collision. Physical props: RigidBody3D when interaction is required.
- Save reusable scenes under assets/library/<category>/<asset_id>/asset.tscn.
- Gate: candidate -> downloaded -> imported -> checked -> PAC-ready. Never label an absent asset as ready.
- Confirm commercial use permissions for each downloaded asset and save source URL and licence at time of acquisition.

## Verified pack candidates (not yet downloaded)
1. Quaternius Modular Sci-Fi MEGAKIT: https://quaternius.com/packs/modularscifimegakit.html . CC0. Modular environment, over 270 models in full offering. Select only PAC-appropriate parts.
2. Quaternius Ultimate Modular Sci-Fi Pack: https://quaternius.com/packs/ultimatemodularscifi.html . CC0, 46 models, textured.
3. Poly Haven: https://polyhaven.com/ . CC0 textures, HDRIs, and individual models.

Do not copy Valve/Alien Swarm/Source game files into PAC without a valid separate licence.

## First milestone
Select, import, inspect, and register the first 10 assets in FIRST_TEN.md. Replace primitive command deck props only after asset passes PAC-ready review.

## Implementation
The Godot editor remains the visual level editor. This library makes model placement repeatable; it does not require a custom level editor.
