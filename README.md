# Project Alien Crisis

2D story-driven sci-fi RPG with base building, raids, companions and consequential decisions.

## Current prototype
**v0.4 development — Interaction System**

- Base → Raid → Choice → Consequence → Base
- Walkable Raid 01
- Reusable Area2D interaction component
- Context-sensitive E prompts
- First companion outcome: Nyra
- Persistent in-session world state

## Controls
- WASD / Arrow keys: movement
- E: interact with the currently focused object

## v0.4 test flow
1. Start the project.
2. Enter Raid 01.
3. Walk near the rescue or artifact objective.
4. Verify the prompt appears only in range.
5. Walk away and verify the exploration prompt returns.
6. Re-enter and press E.
7. Return to base and verify the same outcome logic as v0.3.

## Project structure
- `autoload/` global game state
- `scenes/` Godot scenes
- `scripts/` gameplay logic and reusable components
- `docs/` design and roadmap
- `assets/` art/audio/shaders as production starts

See [docs/ROADMAP.md](docs/ROADMAP.md).
