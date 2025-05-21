local PANEL = {}

function PANEL:Setup(ent)
	self:SetEntity(ent)
	self:SetLookAt(Vector(0, 0, 0))
	self:SetFOV(45)
end

function PANEL:LayoutEntity(ent)
	local pos = ent:WorldSpaceCenter()

	self:SetLookAt(pos)
	self:SetCamPos(pos + Vector(1, 1, 0.5) * ent:GetModelRadius() * 2)

	self:SetColor(ent:GetColor())
end

function PANEL:PreDrawModel(ent)
	self.ItemOwner = ent:GetParent()

	-- Kill me
	ent:SetParent(NULL)
	ent:SetRenderAngles(angle_zero)

	return true
end

function PANEL:PostDrawModel(ent)
	ent:SetRenderAngles(nil)
	ent:SetParent(self.ItemOwner)

	self.ItemOwner = nil
end

function PANEL:OnRemove()
end

vgui.Register("DecayItemIcon", PANEL, "DModelPanel")
