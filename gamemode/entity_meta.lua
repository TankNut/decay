AddCSLuaFile()
local ENTITY = FindMetaTable("Entity")

function ENTITY:IsType(class)
	local ourClass = self:GetClass()

	if ourClass == class then
		return true
	end

	return (self:IsWeapon() and weapons or scripted_ents).IsBasedOn(ourClass, class)
end

function ENTITY:IsItem()
	return self:IsType("item")
end

function ENTITY:GetItems()
	local tab = {}

	for _, ent in ipairs(self:GetChildren()) do
		if ent:IsItem() then
			table.insert(tab, ent)
		end
	end

	return tab
end
