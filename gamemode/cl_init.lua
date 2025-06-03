include("shared.lua")

function GM:InitPostEntity()
	_G.lp = LocalPlayer()
end

function GM:NetworkEntityCreated(ent)
	if ent == lp then
		lp:RunPlayerClass("SetHull")
	end
end

function GM:CalcView(ply, origin, angles, fov, znear, zfar)
	local view = self.BaseClass.CalcView(self, ply, origin, angles, fov, znear, zfar)

	if not ply:Alive() then
		local corpse = ply:GetCorpse()

		if IsValid(corpse) then
			local pos = corpse:GetPos()

			local tr = util.TraceLine({
				start = pos,
				endpos = pos - angles:Forward() * 96 + Vector(0, 0, 14),
				filter = {ply, corpse},
				mask = MASK_SOLID
			})

			view.origin = tr.HitPos
		end
	end

	return view
end

function GM:PreDrawOutlines()
	local corpse = lp:GetCorpse()

	if IsValid(corpse) and lp:Alive() then
		outline.Add(corpse, Color(255, 0, 0))
	end
end

function GM:PrePlayerDraw(ply, flags)
	return ply:RunPlayerClass("PrePlayerDraw", flags)
end

function GM:PostPlayerDraw(ply, flags)
	return ply:RunPlayerClass("PostPlayerDraw", flags)
end

function GM:PostDrawTranslucentRenderables(depth, skybox, skybox3D)
	if skybox or render.GetViewSetup().viewid != 0 then
		return
	end

	cam.Start2D()
		self:DrawBubbles()
	cam.End2D()
end
