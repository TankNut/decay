AddCSLuaFile()

ENT.Base = "base_decay"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = Model("models/effects/intro_vortshield.mdl")

ENT.Mins = Vector(-15, -15, -15)
ENT.Maxs = Vector(15, 15, 15)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:DrawShadow(false)
	self:SetColor(Color(255, 80, 80))

	if CLIENT then
		self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
	else
		self:PhysicsInitBox(self.Mins, self.Maxs)
		self:SetMoveType(MOVETYPE_NONE)

		self:SetTrigger(true)
	end

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", "ClassID")
end

function ENT:GetPlayerClass()
	return util.NetworkIDToString(self:GetClassID())
end

if CLIENT then
	function ENT:Think()
		self:RemoveAllDecals()
	end

	local sprite = Material("sprites/light_glow02_add")
	local mat = CreateMaterial("spawn_portal", "UnlitTwoTexture", {
		["$basetexture"] = "models/effects/vortshield_color",
		["$texture2"] = "models/effects/vortshield_base",
		["$model"] = 1,
		["$nocull"] = 1,
		["$additive"] = 1,
		["Proxies"] = {
			["TextureScroll"] = {
				["texturescrollvar"] = "$texture2transform",
				["texturescrollrate"] = -0.1,
				["texturescrollangle"] = 0
			}
		}
	})

	function ENT:DrawTranslucent()
		if not lp:IsGhost() then
			return
		end

		local light = DynamicLight(self:EntIndex())
		local color = self:GetColor()
		local pos = self:GetPos()

		if light then
			light.pos = pos
			light.r = color.r
			light.g = color.g
			light.b = color.b
			light.brightness = 2
			light.Decay = 0
			light.Size = 128
			light.DieTime = CurTime() + 0.1
		end

		local size = 100

		render.OverrideBlend(true, BLEND_ZERO, BLEND_ONE_MINUS_SRC_COLOR, BLENDFUNC_ADD)
		render.SetMaterial(sprite)
		render.DrawSprite(pos, size, size)
		render.DrawSprite(pos, size, size)
		render.OverrideBlend(false)

		local ang = (EyePos() - pos):Angle()

		render.MaterialOverride(mat)

		self:SetRenderAngles(ang)
		self:SetupBones()
		self:DrawModel()

		render.MaterialOverride()
	end
else
	function ENT:SetupMapEntity(class)
		self:SetPlayerClass(class)
	end

	function ENT:SetPlayerClass(class)
		self:SetClassID(assert(util.NetworkStringToID(class), "Attempt to set unknown player class: " .. class))
	end

	function ENT:StartTouch(ply)
		local class = self:GetPlayerClass()

		if not ply:IsPlayer() or not ply:IsGhost() or IsValid(ply:GetCorpse()) then
			return
		end

		local classTable = baseclass.Get(class)

		if classTable.Max > 0 and team.NumPlayers(classTable.Team) >= classTable.Max then
			return
		end

		ply:SetPlayerClass(class)
		ply:Spawn()

		ply:ScreenFade(SCREENFADE.IN, Color(255, 0, 0), 2.5, 0)
		ply:EmitSound("npc/stalker/go_alert2.wav", 80, 40, 0.6)
	end
end
