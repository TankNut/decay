AddCSLuaFile()
local PLAYER = FindMetaTable("Player")

PLAYER.GetPlayerClass = player_manager.GetPlayerClass
PLAYER.RunPlayerClass = player_manager.RunClass

function PLAYER:IsGhost()
	return self:GetPlayerClass() == "player_ghost"
end

function PLAYER:ShouldNotCollide(other)
	return self:IsGhost()
end

function PLAYER:IsHoldingEntity()
	return IsValid(self:GetHeldEntity())
end

if SERVER then
	PLAYER.SetPlayerClass = player_manager.SetPlayerClass

	function PLAYER:CheckModel()
		hook.Run("PlayerSetModel", self)

		self:SetupHands()
	end

	local massLimit = 125
	local sizeLimit = 80

	function PLAYER:TryObjectPickup()
		local ent = self:GetUseEntity()

		if not IsValid(ent) or ent:GetMoveType() != MOVETYPE_VPHYSICS then
			return
		end

		local count = ent:GetPhysicsObjectCount()

		if count == 0 then
			return
		end

		local mass = 0

		for i = 0, count - 1 do
			local phys = ent:GetPhysicsObjectNum(i)

			if phys:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP) then
				return
			end

			mass = mass + phys:GetMass()
		end

		if mass > massLimit or ent:GetModelRadius() > sizeLimit then
			return
		end

		self:PickupObject(ent)
	end
end
