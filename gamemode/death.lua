function GM:CreateCorpse(ply)
	local ragdoll = ents.Create("prop_ragdoll")

	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetSkin(ply:GetSkin())

	for i = 0, ply:GetNumBodyGroups() - 1 do
		ragdoll:SetBodygroup(i, ply:GetBodygroup(i))
	end

	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:AddEFlags(EFL_IN_SKYBOX)

	local color = ply:GetPlayerColor()

	ragdoll.GetPlayerColor = function()
		return color
	end

	local vel = ply:GetVelocity()

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local phys = ragdoll:GetPhysicsObjectNum(i)
		local boneId = ply:TranslatePhysBoneToBone(i)
		local pos, ang = ply:GetBonePosition(boneId)

		phys:SetPos(pos)
		phys:SetAngles(ang)

		phys:SetVelocity(vel)
	end

	return ragdoll
end

function GM:CanPlayerSuicide(ply)
	return not ply:IsGhost()
end

function GM:DoPlayerDeath(ply, attacker, dmg)
	ply:SetCorpse(self:CreateCorpse(ply))
	ply.NextSpawnTime = CurTime() + 2
end

function GM:PlayerDeath(ply, inflictor, attacker)
	ply:RunPlayerClass("Death", inflictor, attacker)
end

function GM:PlayerDeathThink(ply)
	local ready = not ply.NextSpawnTime or ply.NextSpawnTime <= CurTime()

	if ply:IsGhost() or ply:IsBot() then
		if ready then
			ply:Spawn()
		end

		return
	end

	local corpse = ply:GetCorpse()

	if IsValid(corpse) then
		ply:SetPos(corpse:GetPos())
	end

	if not IsValid(corpse) or (ready and ply:KeyDown(IN_ATTACK)) then
		local pos = ply:GetPos()
		local ang = ply:EyeAngles()

		ply:SetPlayerClass("player_ghost")

		ply:Spawn()
		ply:SetPos(pos + Vector(0, 0, 64))
		ply:SetEyeAngles(ang)
	end
end
