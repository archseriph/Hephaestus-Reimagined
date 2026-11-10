Scriptname HEP_MCM extends SKI_ConfigBase
{Hephaestus recipe tracker: browse schematic progress and learned recipes. Needs SkyUI.}

; Parallel registries written by the Hephaestus Synthesis patcher (one entry per craftable item).
FormList Property HEP_SchematicItems Auto
FormList Property HEP_SchematicBooks Auto
FormList Property HEP_SchematicProgress Auto
FormList Property HEP_SchematicThreshold Auto
FormList Property HEP_SchematicPerks Auto
GlobalVariable Property HEP_ShowOtherBreakdowns Auto
Actor Property PlayerRef Auto

int PAGE_SIZE = 80

; filter state (persisted in the save)
int statusIdx = 1       ; 0 all, 1 in progress, 2 learned, 3 not started
int categoryIdx = 0     ; 0 all, 1 weapons, 2 armor, 3 helmets, 4 shields, 5 jewelry, 6 food
int pageIdx = 1
int maxPage = 1
int matchCount = 0

int oStatus
int oCategory
int oPage
int oMatches
int oShowOther

string[] statusNames
string[] categoryNames

Event OnConfigInit()
    ModName = "Hephaestus"
    Pages = new string[2]
    Pages[0] = "Recipes"
    Pages[1] = "Settings"
    BuildNames()
EndEvent

Event OnConfigOpen()
    BuildNames()
EndEvent

Function BuildNames()
    statusNames = new string[4]
    statusNames[0] = "All"
    statusNames[1] = "In progress"
    statusNames[2] = "Learned"
    statusNames[3] = "Not started"
    categoryNames = new string[7]
    categoryNames[0] = "All"
    categoryNames[1] = "Weapons"
    categoryNames[2] = "Armor"
    categoryNames[3] = "Helmets"
    categoryNames[4] = "Shields"
    categoryNames[5] = "Jewelry"
    categoryNames[6] = "Food"
EndFunction

; 0 not started, 1 in progress, 2 learned
int Function RecipeStatus(int i)
    Perk p = HEP_SchematicPerks.GetAt(i) as Perk
    if p && PlayerRef.HasPerk(p)
        return 2
    endIf
    GlobalVariable g = HEP_SchematicProgress.GetAt(i) as GlobalVariable
    if g && g.GetValue() > 0.0
        return 1
    endIf
    return 0
EndFunction

; 1 weapon, 2 armor, 3 helmet, 4 shield, 5 jewelry, 6 food
int Function RecipeCategory(Form f)
    int t = f.GetType()
    if t == 41
        return 1
    elseIf t == 46
        return 6
    elseIf t == 26
        int mask = (f as Armor).GetSlotMask()
        if Math.LogicalAnd(mask, 0x00000200) != 0
            return 4
        elseIf Math.LogicalAnd(mask, 0x00000060) != 0
            return 5
        elseIf Math.LogicalAnd(mask, 0x00001003) != 0 && Math.LogicalAnd(mask, 0x0000008C) == 0
            return 3
        endIf
        return 2
    endIf
    return 2
EndFunction

bool Function Matches(int i)
    if statusIdx > 0
        int st = RecipeStatus(i)
        if statusIdx == 1 && st != 1
            return false
        elseIf statusIdx == 2 && st != 2
            return false
        elseIf statusIdx == 3 && st != 0
            return false
        endIf
    endIf
    if categoryIdx > 0
        Form f = HEP_SchematicItems.GetAt(i)
        if !f || RecipeCategory(f) != categoryIdx
            return false
        endIf
    endIf
    return true
EndFunction

Event OnPageReset(string page)
    if page == ""
        return
    endIf

    if page == "Settings"
        ShowSettings()
    else
        ShowRecipes()
    endIf
EndEvent

Function ShowSettings()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Smelter")
    bool showOther = HEP_ShowOtherBreakdowns.GetValue() >= 1.0
    oShowOther = AddToggleOption("Show other mods' breakdown recipes", showOther)
    AddEmptyOption()

    int total = HEP_SchematicItems.GetSize()
    int learned = 0
    int started = 0
    int i = 0
    while i < total
        int st = RecipeStatus(i)
        if st == 2
            learned += 1
        elseIf st == 1
            started += 1
        endIf
        i += 1
    endWhile
    AddHeaderOption("Totals")
    AddTextOption("Craftable items with a schematic", total, OPTION_FLAG_DISABLED)
    AddTextOption("Recipes learned", learned, OPTION_FLAG_DISABLED)
    AddTextOption("Recipes in progress", started, OPTION_FLAG_DISABLED)
EndFunction

Function ShowRecipes()
    int total = HEP_SchematicItems.GetSize()
    ; pass 1: count the matches so the page slider has a range
    matchCount = 0
    int i = 0
    while i < total
        if Matches(i)
            matchCount += 1
        endIf
        i += 1
    endWhile
    maxPage = ((matchCount - 1) / PAGE_SIZE) + 1
    if maxPage < 1
        maxPage = 1
    endIf
    if pageIdx > maxPage
        pageIdx = maxPage
    endIf
    if pageIdx < 1
        pageIdx = 1
    endIf

    SetCursorFillMode(LEFT_TO_RIGHT)
    oStatus = AddMenuOption("Show", statusNames[statusIdx])
    oCategory = AddMenuOption("Type", categoryNames[categoryIdx])
    oPage = AddSliderOption("Page (of " + maxPage + ")", pageIdx, "{0}")
    oMatches = AddTextOption("Recipes listed", matchCount, OPTION_FLAG_DISABLED)

    if matchCount == 0
        AddHeaderOption("Nothing matches this filter")
        AddEmptyOption()
        return
    endIf
    AddHeaderOption("Recipe")
    AddHeaderOption("Schematics / status")

    ; pass 2: list this page
    int first = (pageIdx - 1) * PAGE_SIZE
    int seen = 0
    int shown = 0
    i = 0
    while i < total && shown < PAGE_SIZE
        if Matches(i)
            if seen >= first
                Form f = HEP_SchematicItems.GetAt(i)
                string label = f.GetName()
                if label == ""
                    label = "(unnamed)"
                endIf
                float need = (HEP_SchematicThreshold.GetAt(i) as GlobalVariable).GetValue()
                string value
                if RecipeStatus(i) == 2
                    value = "Learned"
                else
                    float have = (HEP_SchematicProgress.GetAt(i) as GlobalVariable).GetValue()
                    value = (have as int) + " / " + (need as int)
                endIf
                AddTextOption(label, value, OPTION_FLAG_DISABLED)
                shown += 1
            endIf
            seen += 1
        endIf
        i += 1
    endWhile
EndFunction

Event OnOptionMenuOpen(int option)
    if option == oStatus
        SetMenuDialogOptions(statusNames)
        SetMenuDialogStartIndex(statusIdx)
        SetMenuDialogDefaultIndex(1)
    elseIf option == oCategory
        SetMenuDialogOptions(categoryNames)
        SetMenuDialogStartIndex(categoryIdx)
        SetMenuDialogDefaultIndex(0)
    endIf
EndEvent

Event OnOptionMenuAccept(int option, int index)
    if index < 0
        return
    endIf
    if option == oStatus
        statusIdx = index
    elseIf option == oCategory
        categoryIdx = index
    else
        return
    endIf
    pageIdx = 1
    ForcePageReset()
EndEvent

Event OnOptionSliderOpen(int option)
    if option == oPage
        SetSliderDialogStartValue(pageIdx)
        SetSliderDialogDefaultValue(1)
        SetSliderDialogRange(1, maxPage)
        SetSliderDialogInterval(1)
    endIf
EndEvent

Event OnOptionSliderAccept(int option, float value)
    if option == oPage
        pageIdx = value as int
        ForcePageReset()
    endIf
EndEvent

Event OnOptionSelect(int option)
    if option == oShowOther
        bool nowShown = HEP_ShowOtherBreakdowns.GetValue() < 1.0
        if nowShown
            HEP_ShowOtherBreakdowns.SetValue(1.0)
        else
            HEP_ShowOtherBreakdowns.SetValue(0.0)
        endIf
        SetToggleOptionValue(option, nowShown)
    endIf
EndEvent

Event OnOptionDefault(int option)
    if option == oShowOther
        HEP_ShowOtherBreakdowns.SetValue(0.0)
        SetToggleOptionValue(option, false)
    endIf
EndEvent

Event OnOptionHighlight(int option)
    if option == oStatus
        SetInfoText("Filter recipes by how far along you are. A recipe unlocks once you have read enough of its schematics.")
    elseIf option == oCategory
        SetInfoText("Filter recipes by item type.")
    elseIf option == oPage
        SetInfoText("Recipes are listed " + PAGE_SIZE + " per page, sorted as the patcher generated them.")
    elseIf option == oShowOther
        SetInfoText("Other mods (e.g. Paths of Empyrean) add smelter recipes that break down the same items Hephaestus turns into schematics. They are hidden by default so each item has one smelter entry. Turn this on to bring them back.")
    endIf
EndEvent
