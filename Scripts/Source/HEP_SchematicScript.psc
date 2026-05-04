Scriptname HEP_SchematicScript extends ObjectReference

GlobalVariable Property HEP_CraftingProgress Auto
GlobalVariable Property HEP_CraftingThreshold Auto
Perk Property HEP_CraftingUnlockedPerk Auto

Event OnRead()
    RegisterForMenu("Book Menu")
EndEvent

Event OnMenuClose(string menuName)
    UnregisterForMenu("Book Menu")
    string itemName = self.GetDisplayName()
    Actor player = Game.GetPlayer()
    player.RemoveItem(self.GetBaseObject(), 1, true)

    float progress = HEP_CraftingProgress.GetValue() + 1.0
    HEP_CraftingProgress.SetValue(progress)
    float threshold = HEP_CraftingThreshold.GetValue()

    if progress >= threshold
        player.AddPerk(HEP_CraftingUnlockedPerk)
        Debug.Notification("Recipe learned: " + itemName)
    else
        Debug.Notification(itemName + " (" + (progress as int) + "/" + (threshold as int) + ")")
    endIf
EndEvent
