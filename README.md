# Project Alien Crisis

2D story-driven sci-fi RPG with base building, raids, companions and consequential decisions.

## Current prototype
**v0.3 development — Walkable Raid**

- Base → Raid → Choice → Consequence → Base
- Persistent in-session world state
- First companion outcome: Nyra
- Walkable Raid 01 with two physical routes
- Left route: rescue signal / Nyra
- Right route: alien signal / artifact

## Controls
- WASD / Arrow keys: movement
- E: interact at an encounter point

## Test flow for v0.3
1. Start the project.
2. In the base, choose **STORY-RAID STARTEN**.
3. Walk left or right through the raid map.
4. Enter the highlighted encounter zone.
5. Press **E**.
6. Return to base and verify that the consequence persists.
7. Reset the demo and test the other route.

## Project structure
- `autoload/` global game state
- `scenes/` Godot scenes
- `scripts/` gameplay logic
- `docs/` design and roadmap
- `assets/` art/audio/shaders as production starts

See [docs/ROADMAP.md](docs/ROADMAP.md).
