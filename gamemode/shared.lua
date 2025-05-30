-- 06/05/2025
AddCSLuaFile()
DeriveGamemode("sandbox")

GM.Name   = "Decay"
GM.Author = "TankNut"

local function includeClient(path)
	if CLIENT then
		return include(path)
	else
		AddCSLuaFile(path)
	end
end

local function includeShared(path)
	AddCSLuaFile(path)
	return include(path)
end

local function includeServer(path)
	if SERVER then
		return include(path)
	end
end

GM.RootFolder = engine.ActiveGamemode() .. "/gamemode"

includeShared("teams.lua")
includeShared("binds.lua")
includeShared("utils.lua")

includeClient("cl_outline.lua")
Circles = includeClient("cl_circles.lua")

includeShared("player_class/player_base/shared.lua")
includeShared("player_class/player_humanoid.lua")

includeShared("player_class/player_ghost.lua")
includeShared("player_class/player_prole.lua")

includeShared("entity_meta.lua")
includeShared("player_meta.lua")

includeShared("map.lua")

includeClient("hud.lua")
includeClient("vgui/inventory.lua")
includeClient("vgui/item_icon.lua")

includeServer("death.lua")
includeServer("integration.lua")
includeServer("net.lua")
includeServer("player.lua")

for _, path in ipairs(file.Find(GM.RootFolder .. "/items/*.lua", "LUA")) do
	includeShared("items/" .. path)
end

local mapFile = GM.RootFolder .. "/maps/" .. game.GetMap() .. ".lua"

if file.Exists(mapFile, "LUA") then
	includeShared(mapFile)
end

function GM:ShouldCollide(a, b)
	local aCallback = a.ShouldNotCollide

	if aCallback and aCallback(a, b) then
		return false
	end

	local bCallback = b.ShouldNotCollide
	if bCallback and bCallback(b, a) then
		return false
	end

	return true
end

function GM:OnEntityCreated(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then
			return
		end

		self:SetupEntity(ent, ent:GetClass())
	end)
end

function GM:SetupEntity(ent, class)
	if ent:GetClass() == "prop_ragdoll" then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

function GM:OnReloaded()
	for _, ply in player.Iterator() do
		ply.m_CurrentPlayerClass = nil
	end
end

function GM:InitPostEntity()
	self:LoadMapFile()
end

function GM:PostCleanupMap()
	self:LoadMapFile()
end
