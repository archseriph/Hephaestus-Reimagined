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

    public class Settings
    {
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

        [SynthesisSettingName("Faction keywords (blocks crafting unless item is obtainable in the world)")]
        [SynthesisDescription("Items carrying any of these keywords will be hidden from the crafting table unless they appear in leveled lists. Players must find or buy them from faction members to unlock the recipe via breakdown.")]
        public List<IFormLinkGetter<IKeywordGetter>> FactionKeywords { get; set; } = new();

        [SynthesisSettingName("(Debug) Show patched item info")]
        public bool ShowDebugLogs { get; set; } = false;
    }
}
