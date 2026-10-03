# Roadmap

## v0.2.1 — Baseline
- Base scene
- Raid scene
- First branching story choice
- Nyra companion outcome
- Persistent world state during session

## v0.3 — Walkable Raid
Goal: replace menu-only raid choices with spatial gameplay.

Implemented in this branch:
- Player enters a walkable raid map
- Two visually and physically distinct routes
- Route choice is made by movement, not a route-selection menu
- Left endpoint represents the rescue signal
- Right endpoint represents the alien artifact
- E resolves the encountered objective
- Outcome persists when returning to base

Test criteria:
- Player can reach both endpoints
- E only resolves an objective while inside its encounter zone
- Nyra route gives 0 Alien-Tech
- Artifact route gives +3 Alien-Tech and +20 resources
- Base reflects the selected outcome after return

## Later milestones
- v0.4 General interaction system
- v0.5 Basic combat
- v0.6 Companion behavior
- v0.7 Save/load
- v0.8 Base building
- v0.9 Complete vertical slice
