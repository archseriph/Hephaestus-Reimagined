Scriptname HEP_SchematicScript extends ObjectReference

GlobalVariable Property HEP_CraftingProgress Auto
GlobalVariable Property HEP_CraftingThreshold Auto
Perk Property HEP_CraftingUnlockedPerk Auto
String Property HEP_RecipeName Auto

Event OnRead()
    RegisterForMenu("Book Menu")
EndEvent

Event OnMenuClose(string menuName)
    UnregisterForMenu("Book Menu")
    string itemName = HEP_RecipeName
    if itemName == ""
        itemName = self.GetDisplayName()
    endIf
    Actor player = Game.GetPlayer()
    player.RemoveItem(self.GetBaseObject(), 1, true)

    float threshold = HEP_CraftingThreshold.GetValue()
    if player.HasPerk(HEP_CraftingUnlockedPerk)
        Debug.Notification(itemName + ": recipe already known")
        return
    endIf

    float progress = HEP_CraftingProgress.GetValue() + 1.0
    HEP_CraftingProgress.SetValue(progress)

    if progress >= threshold
        player.AddPerk(HEP_CraftingUnlockedPerk)
        Debug.Notification("Recipe learned: " + itemName)
    else
        Debug.Notification(itemName + " schematics: " + (progress as int) + "/" + (threshold as int))
    endIf
EndEvent
