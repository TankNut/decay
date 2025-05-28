AddCSLuaFile()
DEFINE_BASECLASS("player_humanoid")

local PLAYER = {}

PLAYER.Team  = GM:AddTeam("Proletariat", Color(20, 150, 20))

PLAYER.Model = Model("models/liver_failure/liverish/liverish.mdl")

if SERVER then
	function PLAYER:SetModel()
		self.Player:SetModel(self.Model)
		self.Player:SetSkin(math.random(10))

		self.Player:SetBodygroupList({
			headgear = table.Random({0, 2, 6, 9}),
			glasses = math.random(0, 5)
		})
	end
end

player_manager.RegisterClass("player_prole", PLAYER, "player_humanoid")
