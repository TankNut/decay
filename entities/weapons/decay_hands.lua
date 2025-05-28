AddCSLuaFile()

SWEP.Base = "decay_base"

SWEP.PrintName  = "Hands"

SWEP.ViewModel  = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

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

	if SERVER then
		self:GetOwner():TryObjectPickup()
	end
end

function SWEP:PushEntity()
end

function SWEP:StartSwing()
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
