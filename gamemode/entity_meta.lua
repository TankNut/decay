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

function ENTITY:HasInventory()
	return self:GetInventorySize() != nil
end

function ENTITY:GetInventorySlots()
	local w, h = self:GetInventorySize()

	if not w then
		return 0
	end

	return w * h
end

function ENTITY:GetInventorySize()
	if self:IsPlayer() then
		return self:RunPlayerClass("GetInventorySize")
	end

	local w = self:GetNWInt("InventoryRows", 0)
	local h = self:GetNWInt("InventoryColumns", 0)

	if w > 0 and h > 0 then
		return w, h
	end
end

function ENTITY:GetItems()
	local tab = {}

	for _, ent in SortedPairs(self:GetChildren(), true) do
		if ent:IsItem() then
			table.insert(tab, ent)
		end
	end

	return tab
end

function ENTITY:SetBodygroupList(data)
	for _, bodygroup in ipairs(self:GetBodyGroups()) do
		self:SetBodygroup(bodygroup.id, math.min(data[bodygroup.name] or 0, bodygroup.num - 1))
	end
end

if CLIENT then
	function ENTITY:AddChatLine(...)
		local bubble = self.ChatBubble

		if not IsValid(bubble) then
			bubble = GAMEMODE:CreateBubble()
			bubble:SetEntity(self)

			self.ChatBubble = bubble
		end

		bubble:AddLine(...)
	end
end
