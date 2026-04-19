# Hephaestus Reimagined - Crafting Overhaul

So you want to actually *earn* the right to forge Daedric armor, huh? Good. You should.

Hephaestus Reimagined is a Synthesis patcher that strips away your innate knowledge of every crafting recipe in the game and hands it back to you piece by piece — through schematics, loot, merchants, and the deeply satisfying act of dismantling things to figure out how they were made.

## What it does

- Removes default crafting and tempering knowledge from items
- Adds schematics and recipe notes to leveled lists so you can actually find them in the world
- Supports crafting, tempering, and food recipes
- Works across SkyrimLE, SkyrimSE, SkyrimVR, Enderal, and the GOG edition

The first time you stumble across a Dwarven Sword Schematic tucked in a chest you weren't even looking in — that's the moment. That's what this is for.

## Requirements

- [Synthesis](https://github.com/Mutagen-Modding/Synthesis)
- [SKSE64](https://skse.silverlock.org/) (or the equivalent for your Skyrim release — SKSEVR, etc.)
- A Skyrim installation. That's it. No base mod, no patches, no prerequisites to hunt down.

## Installation

Drop the `Data/Scripts/` folder into your Skyrim `Data/` directory, then add `patcher/Hephaestus_reimagined.exe` to Synthesis as a Local External Program and run it. After it finishes:

1. Open the generated patch in SSEEdit
2. Find `HEP_MasteryQuest` and check the **Start Game Enabled** flag so the quest kicks off automatically

That's it. No fussing around.

## Notes

This is a Synthesis patcher, not a traditional ESP replacer. That means it reads your full load order and generates a patch on the fly — so it plays nicely with other mods that touch crafting recipes, as long as you run Synthesis after them.

If something looks wrong, check your load order first. It's always the load order.
