AddCSLuaFile()

SWEP.Base = "decay_base"

SWEP.PrintName  = "Hands"

SWEP.ViewModel  = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

SWEP.MassLimit = 125
SWEP.SizeLimit = 80

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "Holstered")

	self:NetworkVar("Float", "NextIdle")
end

function SWEP:Deploy()
	self:SetHoldType("normal")
	self:SetHolstered(true)

	self:SetNextIdle(0)
	self:PlayAnimation("idle")
end

function SWEP:ToggleHolster()
	local bool = not self:GetHolstered()

	self:SetHolstered(bool)

	local duration = self:PlayAnimation(bool and "fists_holster" or "fists_draw")
	local time = CurTime()

	self:SetNextFire(time + duration)
	self:SetHoldType(bool and "normal" or "fist")

	if bool then
		self:SetNextIdle(time + duration * 0.9)
	end
end

function SWEP:CanAttack()
	local ply = self:GetOwner()

	-- Throwing/dropping an object causes the weapon to attack on the server once
	if SERVER and FrameNumber() == ply.DroppedPhysicsFrame then
		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	if not self:CanAttack() then
		return
	end

	if self:GetHolstered() then
		self:PushEntity()
	else
		self:StartSwing()
	end
end

function SWEP:SecondaryAttack()
	if not self:CanAttack() or not self:GetHolstered() then
		return
	end

	self:PickupEntity()
end

function SWEP:PushEntity()
end

function SWEP:StartSwing()
end

function SWEP:PickupEntity()
	if CLIENT then
		return
	end

	local ply = self:GetOwner()
	local ent = ply:GetUseEntity()

	if not IsValid(ent) or ent:GetMoveType() != MOVETYPE_VPHYSICS then
		return
	end

	local count = ent:GetPhysicsObjectCount()

	if count == 0 then
		return
	end

	local mass = 0

	for i = 0, count - 1 do
		local phys = ent:GetPhysicsObjectNum(i)

		if phys:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP) then
			return
		end

		mass = mass + phys:GetMass()
	end

	if mass > self.MassLimit or ent:GetModelRadius() > self.SizeLimit then
		return
	end

	ply:PickupObject(ent)
end

function SWEP:Think()
	local idle = self:GetNextIdle()
	local holstered = self:GetHolstered()

	if idle != 0 and idle <= CurTime() then
		self:PlayAnimation(self:GetHolstered() and "idle" or {"fists_idle_01", "fists_idle_02"})

		if holstered then
			self:SetNextIdle(0)
		end
	end
end

if CLIENT then
	function SWEP:PreDrawViewModel(vm, _, ply)
		if self:GetHolstered() and vm:GetCycle() > 0.9 or self:GetNextIdle() == 0 then
			return true
		end
	end
end
