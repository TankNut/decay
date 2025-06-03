AddCSLuaFile()
DEFINE_BASECLASS("player_humanoid")

local PLAYER = {}

PLAYER.Team      = GM:AddTeam("Proletariat", Color(20, 150, 20))

PLAYER.Model     = Model("models/liver_failure/liverish/liverish.mdl")

PLAYER.ChatSound = "player_prole.chat"

sound.Add({
	name = "player_prole.chat",
	sound = {
		")placenta/speech/prole1.wav",
		")placenta/speech/prole2.wav",
		")placenta/speech/prole3.wav"
	},
	pitch = {85, 115},
	volume = 0.8,
	level = 65
})

if SERVER then
	function PLAYER:SetModel()
		self.Player:SetModel(self.Model)
		self.Player:SetSkin(math.random(10))

		self.Player:SetBodygroupList({
			headgear = table.Random({0, 2, 6, 9}),
			glasses = math.random(0, 5)
		})
	end

	function PLAYER:GetChatColor()
		return HSVToColor(math.random(359), math.Rand(0.2, 0.4), math.Rand(0.8, 1))
	end
end

player_manager.RegisterClass("player_prole", PLAYER, "player_humanoid")
