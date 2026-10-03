# Roadmap

## v0.2.1 — Baseline
- Base scene
- Raid scene
- First branching story choice
- Nyra companion outcome
- Persistent world state during session

## v0.3 — Walkable Raid
Completed:
- Walkable raid map
- Two physically distinct routes
- Movement-driven route choice
- Persistent route outcome in base

## v0.4 — Interaction System
Goal: replace raid-specific interaction-zone code with a reusable interaction component.

Implemented in this branch:
- Generic `interactable.gd` Area2D component
- Exported prompt text and action ID
- Shared E-key interaction flow
- Raid objectives use the same reusable component
- Gameplay scene handles actions separately from proximity detection

Acceptance criteria:
- Entering an interactable shows its prompt
- Leaving it restores exploration text
- E only works while an interactable is focused
- Rescue and artifact outcomes remain unchanged
- No route-specific body-entered/body-exited wiring remains in `raid.gd`

## Later milestones
- v0.5 Basic combat
- v0.6 Companion behavior
- v0.7 Save/load
- v0.8 Base building
- v0.9 Complete vertical slice
