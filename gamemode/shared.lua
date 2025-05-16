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

includeShared("binds.lua")
includeShared("entity_meta.lua")
includeShared("player_meta.lua")

includeClient("cl_outline.lua")

includeServer("death.lua")
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
	elseif class == "env_ragdoll_boogie" then
		ent:Remove()
	end
end
