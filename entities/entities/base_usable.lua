AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.UseTime = 1

function ENT:Initialize()
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

if SERVER then
	function ENT:CheckUse(ply)
		return true
	end

	function ENT:StartUse(ply)
	end

	function ENT:DenyUse(ply)
	end

	function ENT:ShortUse(ply)
	end

	function ENT:LongUse(ply)
	end

	function ENT:AbortUse(ply)
	end

	function ENT:Use(ply)
		if not self:CheckUse(ply) then
			self:DenyUse(ply)

			return
		end

		ply:SetUseTarget(self)
		ply:SetStartUseTime(CurTime())
		ply:SetEndUseTime(CurTime() + self.UseTime)

		self:StartUse(ply)
	end
end
