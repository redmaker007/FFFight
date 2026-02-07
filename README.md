FFFight

FFFight is a 2D auto-battler / tower-defense inspired roguelike prototype built with Godot.
The game focuses on system-driven gameplay, where combat, economy, and global modifiers interact through a clean event-based architecture.

This project is a long-term experimental game design playground rather than a finished product.

Core Gameplay Loop
Battle → Level Clear → Choose Hex (Global Modifier) → Next Level → … → Game Over → Restart


Each run starts from Level 1

After clearing a level, the player chooses Hex upgrades that alter global rules

On failure, the run resets (roguelike structure)

Current Features
Economy System

Automatic gold income

Upgradable Bank (income scaling)

Spending gold to spawn units

After each level:

Bank level resets

Player receives a base gold bonus (100)

Gold persists across levels within a run

Units

Currently implemented unit archetypes:

Red – Tank unit with high HP

Blue – High movement speed & attack speed

Boxer – High damage, low survivability

Snow Ball Shooter – Ranged unit with crowd control

All unit stats are being migrated to Resource-based data definitions for scalability.

Abilities & Debuffs

Ability system (event-driven)

Example: apply_slow on hit

Debuff system

Currently implemented: slow

Designed for modular extension (on_spawn / on_attack / on_death hooks)

Hex System (Global Modifiers)

Hex selection flow is implemented

Hexes are designed as global rule modifiers

Each Hex has positive and negative effects

Effects are applied through signals rather than direct coupling

Content expansion in progress

Architecture Highlights

GameManager State Machine

init

play

hex_select

game_over

Signal-based communication

Decouples systems (units, economy, hexes, UI)

Separation of concerns

Units handle local behavior

Hexes and rules operate at the global level

Ongoing refactor toward Resource-driven content

Tech Stack

Engine: Godot

Language: GDScript

Architecture patterns:

State Machine

Event / Signal-driven systems

Data-oriented design with Resources

Project Status

🚧 Active Development

Planned next steps:

Implement functional Hex effects (combat / economy / rules)

Expand debuff & ability variety

Add enemy-only units with unique mechanics

Further balance & iteration

Notes

This project prioritizes:

System clarity over visual polish

Horizontal content expansion over power creep

Iterative design through playable prototypes
