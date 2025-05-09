AddCSLuaFile()
local PLAYER = FindMetaTable("Player")

function PLAYER:IsGhost()
	return player_manager.GetPlayerClass(self) == "player_ghost"
end

function PLAYER:ShouldNotCollide(other)
	return self:IsGhost()
end

function PLAYER:IsHoldingEntity()
	return IsValid(self:GetHeldEntity())
end

if SERVER then
	function PLAYER:CheckModel()
		hook.Run("PlayerSetModel", self)

		self:SetupHands()
	end
end
