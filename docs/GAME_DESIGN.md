# Game Design Direction

## Core fantasy
A story-driven 2D sci-fi RPG with base building, raids, companions, exploration and consequences.

## Core loop
Prepare → Raid → Discover/Decide → Return → Improve → Prepare harder raid.

## Pillars
- Meaningful decisions with delayed consequences
- Optional companions discovered through exploration
- Alien technology without magic; psionic/sci-fi phenomena are allowed
- Base progression tied to raid success and world state
- Multiple endings: heroic, selfish, fatal, sacrificial and mixed outcomes

## References
Final Fantasy, Mass Effect, RimWorld, Fallout 1–2.

## Scope target
Approx. 20–30 hours for one playthrough, with replay value through branching outcomes.


## Binding gameplay direction (2026-10-16)

- **Engine:** Godot 4. All commercial game code and artwork must have appropriate rights.
- **Exploration:** Characters move freely through fixed-camera, oblique **2.5D environments with pre-rendered backgrounds**, inspired by Final Fantasy VIII. A walk/collision map, foreground occlusion and interactive hotspots support each scene. The presentation may use live effects over the pre-rendered image.
- **Encounters:** Ordinary enemies are **visible during exploration**, with no random encounters. In addition, **scripted narrative encounters** may trigger through story events, dialogue, discoveries, choices, ambushes or mission milestones, even when no enemy was visible beforehand. Both use the same CTB combat core, but can define different introductions, participants, initiative, front/back positions, environmental conditions, and aftermath. Scripted encounters must be authored and contextual rather than arbitrary random battles. Position, approach and detection can influence ordinary combat starts.
- **Combat:** **CTB-style conditional turn-based combat**, inspired by Final Fantasy X, not real-time action combat and not classic time-filling ATB. The upcoming action order is visible and depends on actions and character statistics.
- **Combat party:** All participants in the raid fight; there is **no mid-combat party swapping** and **no Overdrive bar**.
- **Action categories:** normal action / talent or ability / special action. Limited action points for specials recover only at rare checkpoints, artifacts or between raids (not on each turn).
- **Positioning:** front/back roles affect targeting, protection and reach.
- **Campaign:** walkable, upgradable base -> raids -> consequential choices -> return to base; companion and resource progression persist.
- **Companions:** initial Medic and Mechanic; intro/tutorial concludes with choosing one; unchosen character may return later.
- **Co-op goal:** two players; player 1 controls the protagonist, player 2 controls a companion, who remains AI-controlled when solo or disconnected. Campaign state is authoritative on a local dedicated server run by the host.
- **Workflow:** assistant develops and commits code, scenes, automated tests and art integration via GitHub; user pulls, launches and playtests with minimal PowerShell work.
- **Scope safety:** retain the existing Godot scenes and prototype; new exploration/battle systems should be built incrementally and tested before changing the project's main scene.

These decisions supersede the earlier experiments with real-time top-down combat or full 3D/FPS presentation. Inspiration does not authorize copying third-party game art, source code or protected assets.


## Persistent locations and revisits (2026-10-16)

- **Locations are persistent places, not disposable one-shot levels.** Raids may return to previously explored locations on later missions.
- **Consequences persist:** defeated or surviving enemies, rescued or abandoned NPCs, unlocked or sealed doors, repaired or broken systems, depleted supplies and recovered information affect subsequent visits.
- **New objectives in familiar places:** story developments or leads can direct the party back to an area, revealing new routes, hidden records, threats or contacts.
- **Equipment gating without arbitrary walls:** some hazards, sealed sections and optional routes require better protection, tools, key information or companion expertise. The player can withdraw and return prepared.
- **Backtracking should be meaningful:** world states and objectives change, rather than forcing repeated traversal of an identical map. Avoid respawning defeated enemies without an in-world explanation.
- **Threats can persist between visits:** avoiding an alien leaves it present; sealing it in a sector changes available paths; fighting may cost valuable resources. A later visit may reveal how the situation evolved.
- **Technical requirement:** assign stable location/entity IDs and store persistent world-state deltas separately from the base scene. On loading a location, apply those deltas; keep temporary encounter/session state distinct. Dedicated server remains authoritative in co-op.
- **Prototype priority:** Outpost A-17 should retain meaningful gate, generator, encounter and recovery state when evacuated and revisited, while supporting a new objective on a later visit.
