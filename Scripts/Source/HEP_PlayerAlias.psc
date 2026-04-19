Scriptname HEP_PlayerAlias extends Quest

FormList Property HEP_TrackedItems Auto
FormList Property HEP_MasteryPerks Auto
FormList Property HEP_ProgressGlobals Auto
FormList Property HEP_ThresholdGlobals Auto
Actor Property PlayerRef Auto

Event OnInit()
    RegisterForMenu("Crafting Menu")
EndEvent

Event OnPlayerLoadGame()
    RegisterForMenu("Crafting Menu")
EndEvent

Event OnMenuOpen(string menuName)
    if menuName != "Crafting Menu"
        return
    endIf

    float smithingSkill = PlayerRef.GetActorValue("Smithing")
    float skillMult = Math.Sqrt(smithingSkill / 20.0)
    if skillMult < 0.5
        skillMult = 0.5
    endIf

    int count = HEP_TrackedItems.GetSize()
    int i = 0
    while i < count
        Form trackedItem = HEP_TrackedItems.GetAt(i)
        if PlayerRef.GetItemCount(trackedItem) > 0
            Perk masteryPerk = HEP_MasteryPerks.GetAt(i) as Perk
            if !PlayerRef.HasPerk(masteryPerk)
                GlobalVariable progressGlobal = HEP_ProgressGlobals.GetAt(i) as GlobalVariable
                GlobalVariable thresholdGlobal = HEP_ThresholdGlobals.GetAt(i) as GlobalVariable
                float threshold = thresholdGlobal.GetValue()
                float oldProgress = progressGlobal.GetValue()
                float newProgress = oldProgress + skillMult
                progressGlobal.SetValue(newProgress)
                if newProgress >= threshold
                    PlayerRef.AddPerk(masteryPerk)
                    Debug.Notification("Mastered tempering: " + trackedItem.GetName())
                else
                    int oldPct = (oldProgress / threshold * 100.0) as int
                    int newPct = (newProgress / threshold * 100.0) as int
                    if newPct >= 75 && oldPct < 75
                        Debug.Notification(trackedItem.GetName() + " tempering study: 75%")
                    elseif newPct >= 50 && oldPct < 50
                        Debug.Notification(trackedItem.GetName() + " tempering study: 50%")
                    elseif newPct >= 25 && oldPct < 25
                        Debug.Notification(trackedItem.GetName() + " tempering study: 25%")
                    endIf
                endIf
            endIf
        endIf
        i += 1
    endWhile
EndEvent
