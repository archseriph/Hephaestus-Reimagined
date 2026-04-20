# Hephaestus Reimagined - Crafting Overhaul

So you want to actually *earn* the right to forge Daedric armor, huh? Good. You should.

Hephaestus Reimagined is a Synthesis patcher that strips away your innate knowledge of every crafting recipe in the game and hands it back to you piece by piece — through schematics, loot, merchants, and the deeply satisfying act of dismantling things to figure out how they were made.

## What it does

- Removes default crafting and tempering knowledge from all items
- Schematics for weapons, armor, and jewelry are found in loot or unlocked by breaking items down at a **smelter**
- Food recipes are unlocked by recreating the dish at a **cooking pot**
- Crafting knowledge must come first — you can't master tempering an item you don't know how to make
- Unique items and artifacts skip the crafting gate and unlock tempering through bench study alone
- Works across SkyrimLE, SkyrimSE, SkyrimVR, Enderal, and the GOG edition

The first time you stumble across a Dwarven Sword Schematic tucked in a chest you weren't even looking in — that's the moment. That's what this is for.

## Requirements

- [Synthesis](https://github.com/Mutagen-Modding/Synthesis)
- [SKSE64](https://skse.silverlock.org/) (or the equivalent for your Skyrim release — SKSEVR, etc.)
- A Skyrim installation. That's it. No base mod, no patches, no prerequisites to hunt down.

## Installation

1. Drop the `Data/Scripts/` folder from the download into your Skyrim `Data/` directory
2. Open Synthesis and import the included `.synth` file — it'll pull the patcher straight from GitHub
3. Run Synthesis as normal

After it finishes, open the generated patch in SSEEdit, find `HEP_MasteryQuest`, and in the **DNAM** section check the **Start Game Enabled** flag so the quest kicks off automatically.

That's it. No fussing around.

## Notes

This is a Synthesis patcher, not a traditional ESP replacer. That means it reads your full load order and generates a patch on the fly — so it plays nicely with other mods that touch crafting recipes, as long as you run Synthesis after them.

If something looks wrong, check your load order first. It's always the load order.
