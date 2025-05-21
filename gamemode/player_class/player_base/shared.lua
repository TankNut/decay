AddCSLuaFile()
DEFINE_BASECLASS("player_default")

_G.PLAYER = {}

PLAYER.Team             = TEAM_UNASSIGNED

PLAYER.Weapons          = {
	"decay_hands",
	"weapon_physgun",
	"gmod_tool"
}

PLAYER.Hull             = {Vector(-16, -16, 0), Vector(16, 16, 72)}
PLAYER.DuckHull         = {Vector(-16, -16, 0), Vector(16, 16, 36)}

PLAYER.ViewOffset       = Vector(0, 0, 64)
PLAYER.ViewOffsetDucked = Vector(0, 0, 28)

PLAYER.CanUseFlashlight = false

PLAYER.DuckSpeed        = 0.1
PLAYER.UnDuckSpeed      = 0.1

PLAYER.SlowWalkSpeed    = 100
PLAYER.WalkSpeed        = 200
PLAYER.RunSpeed         = 400

PLAYER.DrawShadow       = true

include("use.lua")

function PLAYER:Init()
	if SERVER then
		self.Player:SetTeam(self.Team)
	end

	self.Player:DrawShadow(self.DrawShadow)

	self.Player:SetHull(unpack(self.Hull))
	self.Player:SetHullDuck(unpack(self.DuckHull))

	self.Player:SetViewOffset(self.ViewOffset)
	self.Player:SetViewOffsetDucked(self.ViewOffsetDucked)
end

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Entity", "HeldEntity")
	self.Player:NetworkVar("Entity", "Corpse")

	self.Player:NetworkVar("Entity", "UseTarget")
	self.Player:NetworkVar("Float", "StartUseTime")
	self.Player:NetworkVar("Float", "EndUseTime")
end

if CLIENT then
	function PLAYER:HUDPaint()
		self:DrawUseHUD()
	end

	function PLAYER:PrePlayerDraw(flags) end
	function PLAYER:PostPlayerDraw(flags) end
else
	function PLAYER:Think()
		self:CheckEntityUse()
	end

	function PLAYER:Spawn()
		self.Player:SetCorpse(NULL)
	end

	function PLAYER:SetModel()
		local mdl = player_manager.TranslatePlayerModel(self.Player:GetInfo("cl_playermodel"))

		util.PrecacheModel(mdl)

		self.Player:SetModel(mdl)
	end

	function PLAYER:Loadout()
		for _, weapon in pairs(self.Weapons) do
			self.Player:Give(weapon)
		end

		if self.Weapons[1] then
			self.Player:SelectWeapon(self.Weapons[1])
		end
	end

	function PLAYER:Death(inflictor, attacker)
	end
end

player_manager.RegisterClass("player_base", PLAYER, "player_default")
_G.PLAYER = nil
