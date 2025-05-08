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

includeShared("player_class/player_base.lua")
includeShared("player_class/player_ghost.lua")

includeShared("entity_meta.lua")
includeShared("player_meta.lua")

includeClient("cl_player.lua")

includeServer("integration.lua")
includeServer("player.lua")

for _, path in ipairs(file.Find(engine.ActiveGamemode() .. "/gamemode/items/*.lua", "LUA")) do
	includeShared("items/" .. path)
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

if CLIENT then
	function GM:InitPostEntity()
		_G.lp = LocalPlayer()
	end
end
