AddCSLuaFile()
DEFINE_BASECLASS("player_base")

local PLAYER = {}

PLAYER.Model            = Model("models/Gibs/HGIBS.mdl")

PLAYER.Hull             = {Vector(-8, -8, -8), Vector(8, 8, 8)}
PLAYER.DuckHull         = {Vector(-8, -8, -8), Vector(8, 8, 8)}

PLAYER.ViewOffset       = Vector(0, 0, 0)
PLAYER.ViewOffsetDucked = Vector(0, 0, 0)

PLAYER.WalkSpeed        = 100
PLAYER.RunSpeed         = 200

PLAYER.DrawShadow       = false

PLAYER.InventoryRows    = 0
PLAYER.InventoryColumns = 0

function PLAYER:Init()
	BaseClass.Init(self)

	self.Player:CollisionRulesChanged()
end

function PLAYER:GetMoveDirection(cmd)
	local dir = Vector(cmd:GetForwardMove(), -cmd:GetSideMove(), cmd:GetUpMove())
	dir:Rotate(cmd:GetViewAngles())

	if cmd:KeyDown(IN_JUMP) then
		dir.z = dir.z + 10000
	elseif cmd:KeyDown(IN_DUCK) then
		dir.z = dir.z - 10000
	end

	return dir:GetNormalized()
end

function PLAYER:MoveInDirection(vel, dir, speed, accel)
	local target = dir * speed
	local force = (target - vel) * FrameTime()

	vel:Add(force * accel)
end

function PLAYER:StartMove(mv, cmd)
	local ply = self.Player
	local vel = mv:GetVelocity()

	local speed = ply:KeyDown(IN_SPEED) and ply:GetRunSpeed() or ply:GetWalkSpeed()

	self:MoveInDirection(vel, self:GetMoveDirection(cmd), speed, 3)

	vel.z = vel.z + FrameTime() * 2 * math.cos(ply:GetCreationTime() + CurTime())

	mv:SetVelocity(vel)
end

function PLAYER:FinishMove(mv)
	self.Player:SetGravity(1e-06) -- 0 doesn't work
	self.Player:SetGroundEntity(NULL)
end

function PLAYER:ClassChanged()
	self.Player:SetGravity(1)
	self.Player:CollisionRulesChanged()
end

if CLIENT then
	local rt = GetRenderTarget("ghost_blur", ScrW(), ScrH())
	local rtMat = CreateMaterial("ghost_blur", "unlitgeneric", {
		["$basetexture"] = rt:GetName(),
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$translucent"] = 1,
		["$ignorez"] = 1
	})

	function PLAYER:PrePlayerDraw(flags)
		if player_manager.GetPlayerClass(lp) != "player_ghost" then
			return
		end

		local ply = self.Player

		ply:SetRenderAngles(ply:EyeAngles() + Angle(30, 0, 0))

		render.PushRenderTarget(rt)
		render.Clear(0, 0, 0, 255, true, true)

		render.SuppressEngineLighting(true)
	end

	function PLAYER:PostPlayerDraw(flags)
		render.SuppressEngineLighting(false)
		render.BlurRenderTarget(rt, 1, 1, 1)

		render.PopRenderTarget()

		cam.Start2D()
			render.OverrideBlend(true, BLEND_SRC_COLOR, BLEND_ONE, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_SUBTRACT)

			render.SetMaterial(rtMat)
			render.DrawScreenQuad()

			render.OverrideBlend(false)
		cam.End2D()
	end
else
	function PLAYER:Spawn()
		BaseClass.Spawn(self)

		self.Player:SetPos(self.Player:GetPos() + Vector(0, 0, 64))
	end

	function PLAYER:GetChatColor()
		return HSVToColor(0, 0, math.Rand(0.8, 1))
	end
end

player_manager.RegisterClass("player_ghost", PLAYER, "player_base")
