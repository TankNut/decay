AddCSLuaFile()
DEFINE_BASECLASS("player_default")

_G.PLAYER = {}

PLAYER.Team             = TEAM_UNASSIGNED

PLAYER.Model            = Model("models/liver_failure/liverish/liverish.mdl")

PLAYER.Weapons          = {}

PLAYER.Max              = 0

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

PLAYER.InventoryRows    = 0
PLAYER.InventoryColumns = 0

PLAYER.ChatFont         = "SpleenChatSmall"
PLAYER.ChatSound        = nil

include("use.lua")

function PLAYER:Init()
	if CLIENT then
		self:CreateChatBubble()
	else
		self.Player:SetTeam(self.Team)
	end

	self.Player:DrawShadow(self.DrawShadow)
	self:SetHull()
end

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Entity", "HeldEntity")
	self.Player:NetworkVar("Entity", "Corpse")

	self.Player:NetworkVar("Entity", "UseTarget")
	self.Player:NetworkVar("Float", "StartUseTime")
	self.Player:NetworkVar("Float", "EndUseTime")

	self.Player:NetworkVar("Vector", "ChatColor")
	self.Player:NetworkVar("String", "ChatFont")
end

function PLAYER:SetHull()
	self.Player:SetHull(unpack(self.Hull))
	self.Player:SetHullDuck(unpack(self.DuckHull))

	self.Player:SetViewOffset(self.ViewOffset)
	self.Player:SetViewOffsetDucked(self.ViewOffsetDucked)
end

function PLAYER:GetInventorySize()
	if self.InventoryRows > 0 and self.InventoryColumns > 0 then
		return self.InventoryRows, self.InventoryColumns
	end
end

if CLIENT then
	function PLAYER:CreateChatBubble()
		local ply = self.Player

		if ply.ChatBubble then
			ply.ChatBubble:Remove()
		end

		local bubble = GAMEMODE:CreateBubble()
		bubble:SetEntity(ply)
		bubble:SetFont(self.ChatFont)

		ply.ChatBubble = bubble
	end

	function PLAYER:HUDPaint()
		self:DrawUseHUD()
	end

	function PLAYER:PrePlayerDraw(flags) end
	function PLAYER:PostPlayerDraw(flags) end
else
	function PLAYER:Spawn()
		self.Player:SetChatColor(self:GetChatColor():ToVector())
		self.Player:SetChatFont(self:GetChatFont())
	end

	function PLAYER:SetModel()
		self.Player:SetModel(self.Model)
	end

	function PLAYER:Loadout()
		for _, weapon in pairs(self.Weapons) do
			self.Player:Give(weapon)
		end

		if self.Weapons[1] then
			self.Player:SelectWeapon(self.Weapons[1])
		end
	end

	function PLAYER:Think()
		self:CheckEntityUse()
	end

	function PLAYER:Spare1() end
	function PLAYER:Spare2() end

	function PLAYER:GetChatColor()
		return color_white
	end

	function PLAYER:GetChatSound()
		return self.ChatSound
	end

	function PLAYER:GetChatFont()
		return self.ChatFont
	end

	function PLAYER:Death(inflictor, attacker)
	end
end

player_manager.RegisterClass("player_base", PLAYER, "player_default")

_G.PLAYER = nil
