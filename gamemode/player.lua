function GM:PlayerInitialSpawn(ply)
	ply:SetCustomCollisionCheck(true)

	player_manager.SetPlayerClass(ply, "player_ghost")
end

function GM:PlayerSpawn(ply)
	ply:UnSpectate()

	player_manager.OnPlayerSpawn(ply, transition)
	player_manager.RunClass(ply, "Spawn")

	ply:CheckModel()

	hook.Run("PlayerLoadout", ply)
end

function GM:PlayerSetModel(ply)
	player_manager.RunClass(ply, "SetModel")
end

function GM:PlayerLoadout(ply)
	ply:RemoveAllAmmo()

	player_manager.RunClass(ply, "Loadout")
end

function GM:PlayerDeathThink(ply)
	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then return end

	if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then
		if ply:IsGhost() then
			ply:Spawn()

			return
		end

		local pos = ply:GetPos()
		local ang = ply:EyeAngles()

		player_manager.SetPlayerClass(ply, "player_ghost")

		ply:Spawn()
		ply:SetPos(pos + Vector(0, 0, 64))
		ply:SetEyeAngles(ang)
	end
end

function GM:CanPlayerSuicide(ply)
	return not ply:IsGhost()
end

GM.PlayerCache = GM.PlayerCache or {}

function GM:SavePlayer(ply)
	local items = {}

	for _, item in ipairs(ply:GetItems()) do
		item:SetInventory(game.GetWorld())

		table.insert(items, item)
	end

	self.PlayerCache[ply:SteamID64()] = {
		Class = player_manager.GetPlayerClass(ply),
		Items = items,

		Pos = ply:GetPos(),
		Angles = ply:EyeAngles(),

		Health = ply:Health()
	}
end

function GM:RestorePlayer(ply)
	local steam64 = ply:SteamID64()
	local data = self.PlayerCache[steam64]

	if not data then
		return
	end

	player_manager.SetPlayerClass(ply, data.Class)

	for _, item in ipairs(data.Items) do
		item:SetInventory(ply)
	end

	self.PlayerCache[steam64] = nil

	ply:Spawn()

	ply:SetPos(data.Pos)
	ply:SetEyeAngles(data.Angles)

	ply:SetHealth(data.Health)
end

function GM:PlayerDisconnected(ply)
	if ply:Alive() and not ply:IsGhost() then
		self:SavePlayer(ply)
	end
end

gameevent.Listen("player_activate")

function GM:player_activate(data)
	self:RestorePlayer(Player(data.userid))
end

function GM:OnPlayerPhysicsPickup(ply, ent)
	ply:SetHeldEntity(ent)
end

function GM:OnPlayerPhysicsDrop(ply, ent, thrown)
	ply.DroppedPhysicsFrame = FrameNumber()
	ply:SetHeldEntity(NULL)
end

-- Handled through decay_hands
function GM:AllowPlayerPickup(ply, ent)
	return false
end
