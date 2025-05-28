DEFINE_BASECLASS("base_usable")
AddCSLuaFile()

ENT.Base = "base_usable"

ENT.Model = Model("models/props_lab/cactus.mdl")

ENT.UseTime = 1

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetModel(self.Model)
	self:PhysicsCreate()
end

function ENT:PhysicsCreate()
	if util.IsValidProp(self:GetModel()) then
		if SERVER then
			self:PhysicsInit(SOLID_VPHYSICS)
		end
	else
		self:PhysicsInitCustom(self:GetModelBounds())
	end

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function ENT:PhysicsInitCustom(mins, maxs)
	self:EnableCustomCollisions(true)
	self.PhysCollide = CreatePhysCollideBox(mins, maxs)

	if SERVER then
		self:PhysicsInitBox(mins, maxs)
		self:SetSolid(SOLID_VPHYSICS)
	end
end

function ENT:TestCollision(start, delta, isbox, extends)
	if not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end

function ENT:OnRemove()
	local phys = self.PhysCollide

	if IsValid(phys) then
		timer.Simple(0, function()
			if not IsValid(self) then
				phys:Destroy()
			end
		end)
	end
end

if SERVER then
	function ENT:InventoryUse(ply)
	end

	function ENT:CheckUse(ply)
		return ply:GetInventorySlots() > 0 and not IsValid(self:GetParent())
	end

	function ENT:ShortUse(ply)
		self:SetInventory(ply)
	end

	-- Adapted from https://github.com/ValveSoftware/source-sdk-2013/blob/master/src/game/shared/basecombatweapon_shared.cpp#L982
	function ENT:SetInventory(ent)
		if IsValid(ent) then
			self:SetAbsVelocity(vector_origin)

			self:SetParent(ent)
			self:SetMoveType(MOVETYPE_NONE)

			self:AddEffects(EF_BONEMERGE)
			self:AddSolidFlags(FSOLID_NOT_SOLID)

			self:SetLocalPos(vector_origin)
			self:SetLocalAngles(angle_zero)

			self:SetOwner(ent)
			self:PhysicsDestroy()

			self:SetNoDraw(true)
		else
			self:SetParent(nil)

			self:RemoveEffects(EF_BONEMERGE)
			self:RemoveSolidFlags(FSOLID_NOT_SOLID)

			self:SetOwner(NULL)
			self:PhysicsCreate()

			self:SetNoDraw(false)
			self:PhysWake()
		end
	end

	util.AddNetworkString("DropItem")

	net.Receive("DropItem", function(_, ply)
		local ent = net.ReadEntity()

		if ent:GetParent() != ply then
			return
		end

		ent:SetInventory(NULL)
		ent:SetPos(ply:EyePos())
	end)
end
