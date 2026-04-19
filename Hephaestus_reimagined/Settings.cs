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

        [SynthesisSettingName("(Debug) Show patched item info")]
        public bool ShowDebugLogs { get; set; } = false;
    }
}
