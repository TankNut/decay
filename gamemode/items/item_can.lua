local ITEM = {}

ITEM.Base = "item"

ITEM.PrintName = "Can of Soda"
ITEM.Category  = "Items"

ITEM.Spawnable = true

ITEM.Model = Model("models/props_junk/PopCan01a.mdl")

scripted_ents.Register(ITEM, "item_can")
