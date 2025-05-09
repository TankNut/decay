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
end
