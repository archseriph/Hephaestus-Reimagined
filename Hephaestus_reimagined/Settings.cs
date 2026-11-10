using Mutagen.Bethesda.FormKeys.SkyrimSE;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Synthesis.Settings;

namespace Hephaestus_reimagined
{
    public class BaseSettings
    {
        [SynthesisSettingName("The keyword your crafting furniture uses")]
        public IFormLinkGetter<IKeywordGetter> BenchKeyword { get; set; } =
            FormLinkGetter<IKeywordGetter>.Null;

        [SynthesisSettingName("The name of the crafting furniture")]
        public string objBenchName { get; set; } = string.Empty;
    }

    public class DragonMaterialGateSettings
    {
        [SynthesisSettingName("Global")]
        public IFormLinkGetter<IGlobalGetter> Global { get; set; } =
            FormLinkGetter<IGlobalGetter>.Null;

        [SynthesisSettingName("Required value")]
        public float RequiredValue { get; set; } = 0f;
    }

    public class Settings
    {
        [SynthesisSettingName("Dragon-material crafting gate (optional)")]
        [SynthesisDescription("If Global is set, crafting COBJs for Dragonplate/Dragonscale/Dragonbone items also require that Global to equal Required Value, in addition to the schematic-unlock perk. Meant for cross-mod integration — e.g. a perk overhaul's own 'Masterwork' toggle global. Leave Global unset to disable.")]
        public DragonMaterialGateSettings DragonMaterialGate { get; set; } = new();


        [SynthesisSettingName("Crafting furniture settings")]
        [SynthesisDescription("Determines which crafting stations are tracked for mastery study.")]
        public List<BaseSettings> BenchSettings { get; set; } =
            new()
            {
                new BaseSettings()
                {
                    BenchKeyword = Skyrim.Keyword.CraftingSmithingForge,
                    objBenchName = "Forge",
                },
                new BaseSettings()
                {
                    BenchKeyword = Skyrim.Keyword.CraftingTanningRack,
                    objBenchName = "Tanning Rack",
                },
                new BaseSettings()
                {
                    BenchKeyword = Skyrim.Keyword.CraftingCookpot,
                    objBenchName = "Cooking Pot",
                }
            };

        [SynthesisSettingName("Blacklist items")]
        [SynthesisDescription("Items listed here will be completely ignored by the patcher.")]
        public List<IFormLinkGetter<IItemGetter>> itemBlacklist { get; set; } = new();

        [SynthesisSettingName("Blacklist plugins")]
        [SynthesisDescription("Every item originating from any of these plugins will be completely ignored by the patcher, without needing to list items individually.")]
        public List<ModKey> PluginBlacklist { get; set; } = new();

        [SynthesisSettingName("Unique/artifact items (doubled mastery threshold)")]
        [SynthesisDescription("Items listed here require twice as many bench visits to master tempering.")]
        [SynthesisTooltip("Items listed here require twice as many bench visits to master tempering.")]
        public List<IFormLinkGetter<IItemGetter>> UniqueItemList { get; set; } = new();

        [SynthesisSettingName("Keywords that mark an item as unique (doubled threshold)")]
        [SynthesisDescription("Any item carrying one of these keywords will require twice as many bench visits to master. Defaults to MagicDisallowEnchanting, which covers most Daedric artifacts.")]
        [SynthesisTooltip("Any item carrying one of these keywords will require twice as many bench visits to master. Defaults to MagicDisallowEnchanting, which covers most Daedric artifacts.")]
        public List<IFormLinkGetter<IKeywordGetter>> UniqueItemKeywords { get; set; } =
            new()
            {
                new FormLink<IKeywordGetter>(Skyrim.Keyword.MagicDisallowEnchanting.FormKey)
            };

        [SynthesisSettingName("Keep vanilla smithing perk requirements")]
        [SynthesisDescription("If enabled, vanilla smithing perk requirements are kept alongside schematic conditions. Players need both the relevant smithing perk AND a schematic to craft.")]
        public bool KeepVanillaCraftingConditions { get; set; } = false;

        [SynthesisSettingName("Keep Paths of Empyrean's Dragonblood Masterwork condition")]
        [SynthesisDescription("Paths of Empyrean hides its normal recipes (about 2,300 of them) while the global IWP_GLO_SMITH_DragonbloodMasterworkActive is on, using the condition 'GetGlobalValue(that global) == 0'. Hephaestus replaces recipe conditions with its schematic perk, which drops that gate. Turn this on to carry the condition over onto every recipe Hephaestus patches. Ignored if 'Keep vanilla smithing perk requirements' is on, because that already keeps every original condition.")]
        public bool KeepPoEDragonbloodGate { get; set; } = false;

        [SynthesisSettingName("Other globals whose conditions are kept on patched recipes")]
        [SynthesisDescription("Any GetGlobalValue condition on one of these globals is copied from the original recipe onto the recipe Hephaestus patches (same comparison and value). Use for other mods' toggle or availability globals that Hephaestus would otherwise drop. Leave empty to keep none.")]
        public List<IFormLinkGetter<IGlobalGetter>> KeepGlobalConditions { get; set; } = new();

        [SynthesisSettingName("Faction keywords (blocks crafting unless item is obtainable in the world)")]
        [SynthesisDescription("Items carrying any of these keywords will be hidden from the crafting table unless they appear in leveled lists. Players must find or buy them from faction members to unlock the recipe via breakdown.")]
        public List<IFormLinkGetter<IKeywordGetter>> FactionKeywords { get; set; } = new();

        [SynthesisSettingName("Hide other mods' breakdown recipes when a schematic breakdown exists")]
        [SynthesisDescription("Smelter recipes from other mods (e.g. Paths of Empyrean) that break down an item Hephaestus already turns into a schematic are hidden, so the smelter shows one entry per item. The MCM has a toggle to show them again.")]
        public bool HideOtherBreakdowns { get; set; } = true;

        [SynthesisSettingName("(Debug) Show patched item info")]
        public bool ShowDebugLogs { get; set; } = false;
    }
}
