Scriptname HEP_SchematicScript extends ObjectReference

GlobalVariable Property HEP_CraftingProgress Auto
GlobalVariable Property HEP_CraftingThreshold Auto
Perk Property HEP_CraftingUnlockedPerk Auto
String Property HEP_RecipeName Auto

; DESIGN NOTE: a schematic in the player's inventory is an item with no world reference behind it ("Item 2 in
; container"), so this script has NO native object. Any call on the book itself (RegisterForMenu, GetBaseObject,
; GetDisplayName, ...) fails with "no native object bound to the script object", and the version that did that
; never removed the book or counted progress. So this script only reads its own properties and hands the read to
; HEP_MCM (a running quest, found with the global Quest.GetQuest, so nothing has to be registered on each load).
; Only the STRING property is passed: on an inventory item the form properties above arrive as None (seen live).
; HEP_MCM waits for the Book Menu to close, then removes the book and counts the progress.
Event OnRead()
    Debug.Trace("HEP: OnRead " + HEP_RecipeName)
    HEP_MCM mcm = Quest.GetQuest("HEP_MCMQuest") as HEP_MCM
    if mcm
        mcm.SchematicOpened(HEP_RecipeName)
    endIf
EndEvent
