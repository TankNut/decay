AddCSLuaFile()

SWEP.UseHands = true

SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:SetNextFire(time)
	self:SetNextPrimaryFire(time)
	self:SetNextSecondaryFire(time)
end

function SWEP:PlayAnimation(animation, rate)
	rate = rate or 1

	local vm = self:GetOwner():GetViewModel()
	local index

	if istable(animation) then
		animation = animation[math.random(#animation)]
	end

	if isnumber(animation) then
		index = vm:SelectWeightedSequence(animation)
	else
		index = vm:LookupSequence(animation)
	end

	local duration = vm:SequenceDuration(index) / rate

	vm:SendViewModelMatchingSequence(index)
	vm:SetPlaybackRate(rate)

	self:SetNextIdle(CurTime() + duration)

	return duration
end

function SWEP:OnReloaded()
	self:SetWeaponHoldType(self:GetHoldType())
end
