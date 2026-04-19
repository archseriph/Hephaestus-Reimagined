using Mutagen.Bethesda.FormKeys.SkyrimSE;
using Mutagen.Bethesda.Plugins.Aspects;
using Mutagen.Bethesda.Skyrim;

namespace Hephaestus_reimagined
{
    public class GenData
    {
        // Returns how many schematics must be studied to unlock crafting (2–11).
        // Two components: material tier (1–7) + item complexity (1–4 per category).
        public static int GetSchematicComplexity(IItemGetter item, IKeywordedGetter keywords, string objType)
        {
            uint tier = GetMaterialTier(keywords);
            int complexity = objType switch
            {
                "Weapon" => GetWeaponComplexity(item),
                "Jewelry" => 2,
                "Armor" or "Helmet" or "Shield" => GetArmorComplexity(item),
                _ => 3
            };
            return Math.Clamp((int)tier + complexity, 2, 11);
        }

        // Weapon complexity 1–4 by animation type.
        private static int GetWeaponComplexity(IItemGetter item)
        {
            if (item is not IWeaponGetter weapon) return 2;
            return weapon.Data?.AnimationType switch
            {
                WeaponAnimationType.OneHandDagger => 1,
                WeaponAnimationType.OneHandSword
                    or WeaponAnimationType.OneHandAxe
                    or WeaponAnimationType.OneHandMace => 2,
                WeaponAnimationType.TwoHandSword or WeaponAnimationType.TwoHandAxe => 3,
                WeaponAnimationType.Bow or WeaponAnimationType.Crossbow => 4,
                _ => 2
            };
        }

        // Armor complexity 1–4 by body slot.
        // Gloves/Boots=1, Jewelry=2 (handled above), everything else=3.
        private static int GetArmorComplexity(IItemGetter item)
        {
            if (item is not IArmorGetter armor) return 3;
            var flags = armor.BodyTemplate?.FirstPersonFlags;
            if (flags.HasValue &&
                (flags.Value.HasFlag(BipedObjectFlag.Hands) || flags.Value.HasFlag(BipedObjectFlag.Feet)))
                return 1;
            return 3;
        }

        // Returns how many bench visits are required to master tempering.
        // Unique items (Daedric artifacts, etc.) require double the threshold.
        public static float GetMasteryThreshold(IKeywordedGetter keywords, string objType, bool isUnique)
        {
            float threshold;
            if (objType == "Cooking" || objType == "Misc" || objType == "Jewelry")
                threshold = 3.0f;
            else
            {
                uint tier = GetMaterialTier(keywords);
                threshold = tier switch
                {
                    1 or 2 => 3.0f,
                    3 or 4 => 5.0f,
                    5 or 6 => 8.0f,
                    _ => 12.0f
                };
            }
            if (isUnique)
                threshold *= 2.0f;
            return threshold;
        }

        private static uint GetMaterialTier(IKeywordedGetter keywords)
        {
            if (keywords.Keywords == null)
                return 3;

            var kw = keywords.Keywords;

            // Tier 7 — Endgame
            if (
                kw.Contains(Skyrim.Keyword.WeapMaterialDaedric)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialDaedric)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialDragonplate)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialDragonscale)
                || kw.Contains(Dawnguard.Keyword.DLC1WeapMaterialDragonbone)
            )
                return 7;

            // Tier 6 — Late game
            if (
                kw.Contains(Skyrim.Keyword.WeapMaterialGlass)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialGlass)
                || kw.Contains(Skyrim.Keyword.WeapMaterialEbony)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialEbony)
                || kw.Contains(Dragonborn.Keyword.DLC2ArmorMaterialStalhrimHeavy)
                || kw.Contains(Dragonborn.Keyword.DLC2ArmorMaterialStalhrimLight)
            )
                return 6;

            // Tier 5 — Advanced
            if (
                kw.Contains(Skyrim.Keyword.WeapMaterialElven)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialElven)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialElvenGilded)
                || kw.Contains(Skyrim.Keyword.WeapMaterialOrcish)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialOrcish)
                || kw.Contains(Dragonborn.Keyword.DLC2ArmorMaterialNordicHeavy)
                || kw.Contains(Dragonborn.Keyword.DLC2ArmorMaterialNordicLight)
            )
                return 5;

            // Tier 4 — Intermediate
            if (
                kw.Contains(Skyrim.Keyword.WeapMaterialDwarven)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialDwarven)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialSteelPlate)
            )
                return 4;

            // Tier 3 — Skilled
            if (
                kw.Contains(Skyrim.Keyword.WeapMaterialSteel)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialSteel)
                || kw.Contains(Skyrim.Keyword.WeapMaterialSilver)
                || kw.Contains(Skyrim.Keyword.WeapMaterialFalmer)
                || kw.Contains(Skyrim.Keyword.WeapMaterialFalmerHoned)
                || kw.Contains(Dawnguard.Keyword.DLC1ArmorMaterialFalmerHardened)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialScaled)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialIronBanded)
            )
                return 3;

            // Tier 2 — Basic smithing
            if (
                kw.Contains(Skyrim.Keyword.WeapMaterialIron)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialIron)
                || kw.Contains(Skyrim.Keyword.WeapMaterialImperial)
                || kw.Contains(Skyrim.Keyword.WeapMaterialDraugr)
                || kw.Contains(Skyrim.Keyword.WeapMaterialDraugrHoned)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialStudded)
            )
                return 2;

            // Tier 1 — Simple materials
            if (
                kw.Contains(Skyrim.Keyword.ArmorMaterialLeather)
                || kw.Contains(Skyrim.Keyword.ArmorMaterialHide)
                || kw.Contains(Skyrim.Keyword.WeapMaterialWood)
            )
                return 1;

            return 3;
        }
    }
}
