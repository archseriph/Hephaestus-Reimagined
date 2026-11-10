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

; DESIGN NOTE: a Papyrus call costs a lot on a busy install. The first version walked all ~2600 recipes (about
; 4 native calls each, twice) every time a page opened, which froze the menu for minutes. So now:
;  - a background scan classifies the recipes a few at a time and caches the result as bits,
;  - HEP_SchematicScript sends the "HEP_SchematicRead" mod event, which re-classifies just that recipe,
;  - opening a page only reads the cache, and only makes native calls for the rows it actually shows.

int PAGE_SIZE = 60
int MAX_ENTRIES = 3840          ; 128 ints x 30 bits

; filter state (persisted in the save)
int statusIdx = 0       ; 0 in progress, 1 learned, 2 all tracked
int categoryIdx = 0     ; 0 all, 1 weapons, 2 armor, 3 helmets, 4 shields, 5 jewelry, 6 food
int pageIdx = 1
int maxPage = 1
int matchCount = 0

; scan cache: one bit per recipe, 30 bits per int so every value stays positive
int[] learnedBits
int[] startedBits
int[] catBits0
int[] catBits1
int[] catBits2
int[] pow2
int scanPos = 0
bool scanDone = false

int oStatus
int oCategory
int oPage
int oMatches
int oShowOther
int oRescan

string[] statusNames
string[] categoryNames

; ---------------------------------------------------------------- lifecycle

Event OnConfigInit()
    ModName = "Hephaestus"
    Pages = new string[2]
    Pages[0] = "Recipes"
    Pages[1] = "Settings"
    BuildNames()
    RegisterForModEvent("HEP_SchematicRead", "OnSchematicRead")
    StartScan()
EndEvent

Event OnGameReload()
    parent.OnGameReload()
    RegisterForModEvent("HEP_SchematicRead", "OnSchematicRead")
    EnsureCache()
    if !scanDone
        RegisterForSingleUpdate(5.0)
    endIf
EndEvent

Event OnConfigOpen()
    BuildNames()
EndEvent

Function BuildNames()
    statusNames = new string[3]
    statusNames[0] = "In progress"
    statusNames[1] = "Learned"
    statusNames[2] = "All tracked"
    categoryNames = new string[7]
    categoryNames[0] = "All"
    categoryNames[1] = "Weapons"
    categoryNames[2] = "Armor"
    categoryNames[3] = "Helmets"
    categoryNames[4] = "Shields"
    categoryNames[5] = "Jewelry"
    categoryNames[6] = "Food"
EndFunction

Actor Function Plr()
    if PlayerRef
        return PlayerRef
    endIf
    return Game.GetPlayer()
EndFunction

; ---------------------------------------------------------------- bit cache (script instructions only, no native calls)

Function EnsureCache()
    if pow2.Length == 30 && learnedBits.Length == 128 && startedBits.Length == 128 && catBits0.Length == 128 && catBits1.Length == 128 && catBits2.Length == 128
        return
    endIf
    pow2 = new int[30]
    int v = 1
    int k = 0
    while k < 30
        pow2[k] = v
        v = v * 2
        k += 1
    endWhile
    learnedBits = new int[128]
    startedBits = new int[128]
    catBits0 = new int[128]
    catBits1 = new int[128]
    catBits2 = new int[128]
    scanPos = 0
    scanDone = false
EndFunction

bool Function GetBit(int[] bits, int i)
    return ((bits[i / 30] / pow2[i % 30]) % 2) == 1
EndFunction

Function SetBit(int[] bits, int i, bool on)
    int w = i / 30
    int p = pow2[i % 30]
    bool cur = ((bits[w] / p) % 2) == 1
    if on && !cur
        bits[w] = bits[w] + p
    elseIf !on && cur
        bits[w] = bits[w] - p
    endIf
EndFunction

int Function GetCategoryBits(int i)
    int c = 0
    if GetBit(catBits0, i)
        c += 1
    endIf
    if GetBit(catBits1, i)
        c += 2
    endIf
    if GetBit(catBits2, i)
        c += 4
    endIf
    return c
EndFunction

; 1 weapon, 2 armor, 3 helmet, 4 shield, 5 jewelry, 6 food
int Function RecipeCategory(Form f)
    if !f
        return 2
    endIf
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

; Works out whether recipe i is learned / in progress and stores it in the cache.
Function ClassifyIndex(int i)
    if i < 0 || i >= MAX_ENTRIES
        return
    endIf
    bool learned = false
    Perk p = HEP_SchematicPerks.GetAt(i) as Perk
    if p
        learned = Plr().HasPerk(p)
    endIf
    bool started = false
    GlobalVariable g = HEP_SchematicProgress.GetAt(i) as GlobalVariable
    if g
        started = g.GetValue() > 0.0
    endIf
    SetBit(learnedBits, i, learned)
    SetBit(startedBits, i, started)
    if learned || started
        int c = RecipeCategory(HEP_SchematicItems.GetAt(i))
        SetBit(catBits0, i, (c % 2) == 1)
        SetBit(catBits1, i, ((c / 2) % 2) == 1)
        SetBit(catBits2, i, ((c / 4) % 2) == 1)
    endIf
EndFunction

; ---------------------------------------------------------------- background scan + live updates

Function StartScan()
    EnsureCache()
    scanPos = 0
    scanDone = false
    RegisterForSingleUpdate(5.0)
EndFunction

Event OnUpdate()
    EnsureCache()
    int total = HEP_SchematicItems.GetSize()
    int stop = scanPos + 15
    if stop > total
        stop = total
    endIf
    while scanPos < stop
        ClassifyIndex(scanPos)
        scanPos += 1
    endWhile
    if scanPos < total
        RegisterForSingleUpdate(0.6)
    else
        scanDone = true
    endIf
EndEvent

; Sent by HEP_SchematicScript after a schematic is read. a_progress is that recipe's progress global.
Function OnSchematicRead(Form a_sender, Form a_progress)
    EnsureCache()
    int i = HEP_SchematicProgress.Find(a_progress)
    if i >= 0
        ClassifyIndex(i)
    endIf
EndFunction

; ---------------------------------------------------------------- filtering

; True when recipe i passes the status and type filters. Cache reads only, except the type check on tracked items.
bool Function Matches(int i)
    bool learned = GetBit(learnedBits, i)
    bool started = GetBit(startedBits, i)
    if statusIdx == 0
        if learned || !started
            return false
        endIf
    elseIf statusIdx == 1
        if !learned
            return false
        endIf
    else
        if !learned && !started
            return false
        endIf
    endIf
    if categoryIdx > 0 && GetCategoryBits(i) != categoryIdx
        return false
    endIf
    return true
EndFunction

; ---------------------------------------------------------------- pages

Event OnPageReset(string page)
    if page == ""
        return
    endIf

    EnsureCache()
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
    AddHeaderOption("Recipe cache")
    oRescan = AddTextOption("Rescan all recipes", "Run", 0)

    int total = HEP_SchematicItems.GetSize()
    int learned = 0
    int started = 0
    int w = 0
    int words = (total + 29) / 30
    if words > 128
        words = 128
    endIf
    while w < words
        if learnedBits[w] != 0 || startedBits[w] != 0
            int i = w * 30
            int stop = i + 30
            if stop > total
                stop = total
            endIf
            while i < stop
                if GetBit(learnedBits, i)
                    learned += 1
                elseIf GetBit(startedBits, i)
                    started += 1
                endIf
                i += 1
            endWhile
        endIf
        w += 1
    endWhile
    AddHeaderOption("Totals")
    AddTextOption("Craftable items with a schematic", total, OPTION_FLAG_DISABLED)
    AddTextOption("Recipes learned", learned, OPTION_FLAG_DISABLED)
    AddTextOption("Recipes in progress", started, OPTION_FLAG_DISABLED)
    if scanDone
        AddTextOption("Recipe scan", "Done", OPTION_FLAG_DISABLED)
    else
        AddTextOption("Recipe scan", ((scanPos * 100) / (total + 1)) + "%", OPTION_FLAG_DISABLED)
    endIf
EndFunction

Function ShowRecipes()
    int total = HEP_SchematicItems.GetSize()
    int words = (total + 29) / 30
    if words > 128
        words = 128
    endIf

    ; pass 1: count the matches so the page slider has a range. Words with nothing tracked are skipped whole.
    matchCount = 0
    int w = 0
    while w < words
        if learnedBits[w] != 0 || startedBits[w] != 0
            int i = w * 30
            int stop = i + 30
            if stop > total
                stop = total
            endIf
            while i < stop
                if Matches(i)
                    matchCount += 1
                endIf
                i += 1
            endWhile
        endIf
        w += 1
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

    if !scanDone
        AddHeaderOption("Still scanning recipes (" + ((scanPos * 100) / (total + 1)) + "%)")
        AddHeaderOption("Reopen this page in a moment")
    endIf
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
    w = 0
    while w < words && shown < PAGE_SIZE
        if learnedBits[w] != 0 || startedBits[w] != 0
            int j = w * 30
            int stop2 = j + 30
            if stop2 > total
                stop2 = total
            endIf
            while j < stop2 && shown < PAGE_SIZE
                if Matches(j)
                    if seen >= first
                        AddRecipeRow(j)
                        shown += 1
                    endIf
                    seen += 1
                endIf
                j += 1
            endWhile
        endIf
        w += 1
    endWhile
EndFunction

Function AddRecipeRow(int i)
    Form f = HEP_SchematicItems.GetAt(i)
    string label = ""
    if f
        label = f.GetName()
    endIf
    if label == ""
        label = "(unnamed)"
    endIf
    string value
    if GetBit(learnedBits, i)
        value = "Learned"
    else
        float need = (HEP_SchematicThreshold.GetAt(i) as GlobalVariable).GetValue()
        float have = (HEP_SchematicProgress.GetAt(i) as GlobalVariable).GetValue()
        value = (have as int) + " / " + (need as int)
    endIf
    AddTextOption(label, value, OPTION_FLAG_DISABLED)
EndFunction

; ---------------------------------------------------------------- input

Event OnOptionMenuOpen(int option)
    if option == oStatus
        SetMenuDialogOptions(statusNames)
        SetMenuDialogStartIndex(statusIdx)
        SetMenuDialogDefaultIndex(0)
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
    elseIf option == oRescan
        StartScan()
        SetTextOptionValue(option, "Started")
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
    elseIf option == oRescan
        SetInfoText("Re-checks every recipe in the background (about a minute). Normally not needed: reading a schematic updates its recipe immediately.")
    endIf
EndEvent
