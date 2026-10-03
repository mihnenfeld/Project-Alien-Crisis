# Project Alien Crisis

2D story-driven sci-fi RPG with base building, raids, companions and consequential decisions.

## Current prototype
**v0.2.1 baseline**

- Base → Raid → Choice → Consequence → Base
- Persistent in-session world state
- First companion outcome: Nyra
- Artifact route grants Alien-Tech
- Rescue route preserves Nyra but grants no Alien-Tech

## Controls
- WASD / Arrow keys: movement
- E: reserved for interaction

## Project structure
- `autoload/` global game state
- `scenes/` Godot scenes
- `scripts/` gameplay logic
- `docs/` design and roadmap
- `assets/` will hold art/audio/shaders as production starts

## Next milestone
See [docs/ROADMAP.md](docs/ROADMAP.md).

**v0.3 goal:** make the first raid physically walkable with two spatial routes instead of menu-only route selection.
