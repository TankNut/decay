AddCSLuaFile()

PLAYER.ShortUseThreshold = 0.25

if CLIENT then
	local circle = Circles.New(CIRCLE_OUTLINED, 32, 0, 0, 10)
	circle:SetStartAngle(-90)

	function PLAYER:DrawUseHUD()
		local ply = self.Player
		local start = ply:GetStartUseTime()

		if start == 0 or CurTime() - start < self.ShortUseThreshold then
			return
		end

		local fraction = math.TimeFraction(start + self.ShortUseThreshold, ply:GetEndUseTime(), CurTime())

		circle:SetEndAngle(Lerp(fraction, -90, 270))
		circle:SetPos(ScrW() * 0.5, ScrH() * 0.5)

		draw.NoTexture()
		surface.SetDrawColor(HSVToColor((CurTime() * 13) % 360, 1, 1))
		circle()
	end
else
	function PLAYER:ClearUseTarget()
		local ply = self.Player

		ply:SetUseTarget(NULL)
		ply:SetStartUseTime(0)
		ply:SetEndUseTime(0)
	end

	function PLAYER:CheckEntityUse()
		local ply = self.Player

		if ply:GetStartUseTime() == 0 then
			return
		end

		local ent = ply:GetUseTarget()

		if not IsValid(ent) then
			self:ClearUseTarget()

			return
		end

		local held = ply:KeyDown(IN_USE)
		local time = CurTime() - ply:GetStartUseTime()

		-- Dead, no longer our target, we've released and held for longer than the short use threshold or the entity kicks us out
		if not ply:Alive() or ply:GetUseEntity() != ent or (not held and time > self.ShortUseThreshold) or not ent:CheckUse(ply) then
			self:ClearUseTarget()
			ent:AbortUse(ply)

			return
		end

		if not ply:KeyDown(IN_USE) and time <= self.ShortUseThreshold then
			self:ClearUseTarget()
			ent:ShortUse(ply)

			return
		end

		if ply:GetEndUseTime() <= CurTime() then
			self:ClearUseTarget()
			ent:LongUse(ply)

			return
		end
	end
end
