function GM:PlayerInitialSpawn(ply)
	ply:SetCustomCollisionCheck(true)
	ply:SetNoCollideWithTeammates(false)

	ply:SetPlayerClass(ply:IsBot() and "player_prole" or "player_ghost")
	ply:AddEFlags(EFL_IN_SKYBOX) -- Always in PVS
end

function GM:PlayerSpawn(ply)
	ply:UnSpectate()

	player_manager.OnPlayerSpawn(ply, transition)

	ply:RunPlayerClass("Spawn")
	ply:CheckModel()

	hook.Run("PlayerLoadout", ply)
end

function GM:PlayerSetModel(ply)
	ply:RunPlayerClass("SetModel")
end

function GM:PlayerLoadout(ply)
	ply:RemoveAllAmmo()
	ply:RunPlayerClass("Loadout")
end

function GM:PlayerPostThink(ply)
	ply:RunPlayerClass("Think")
end

GM.PlayerCache = GM.PlayerCache or {}

function GM:SavePlayer(ply)
	local items = {}

	for _, item in ipairs(ply:GetItems()) do
		item:SetInventory(game.GetWorld())

		table.insert(items, item)
	end

	self.PlayerCache[ply:SteamID64()] = {
		Class = ply:GetPlayerClass(),
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

	ply:SetPlayerClass(data.Class)

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

function GM:ShowSpare1(ply) ply:RunPlayerClass("Spare1") end
function GM:ShowSpare2(ply) ply:RunPlayerClass("Spare2") end
