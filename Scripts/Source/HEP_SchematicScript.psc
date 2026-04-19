Scriptname HEP_SchematicScript extends ObjectReference

GlobalVariable Property HEP_CraftingProgress Auto
GlobalVariable Property HEP_CraftingThreshold Auto
Perk Property HEP_CraftingUnlockedPerk Auto

Event OnRead()
    Actor player = Game.GetPlayer()
    player.RemoveItem(self.GetBaseObject(), 1, true)

    float progress = HEP_CraftingProgress.GetValue() + 1.0
    HEP_CraftingProgress.SetValue(progress)
    float threshold = HEP_CraftingThreshold.GetValue()

    if progress >= threshold
        player.AddPerk(HEP_CraftingUnlockedPerk)
        Debug.Notification("Recipe learned: " + self.GetDisplayName())
    else
        Debug.Notification(self.GetDisplayName() + " (" + (progress as int) + "/" + (threshold as int) + ")")
    endIf
EndEvent
