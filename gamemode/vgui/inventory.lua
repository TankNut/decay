local PANEL = {}

function PANEL:Init()
	if IsValid(GAMEMODE.InventoryPanel) then
		GAMEMODE.InventoryPanel:Remove()
	end

	local w, h = ScrW(), ScrH()

	self:SetSize(w, h)
	self:MakePopup()
	self:Center()
	self:SetCloseOnPause(true)

	local spacing = DecayScale(3)
	local padding = DecayScale(2)
	local size = DecayScale(64)

	self.InventoryRows, self.InventoryColumns = lp:GetInventorySize()

	self.Layout = self:Add("DIconLayout")
	self.Layout:SetSpaceX(spacing)
	self.Layout:SetSpaceY(spacing)
	self.Layout:SetSize(size * self.InventoryRows + spacing * (self.InventoryRows - 1), size * self.InventoryColumns + spacing)

	for i = 1, self.InventoryRows * self.InventoryColumns do
		local panel = self.Layout:Add("DPanel")
		panel:SetSize(size, size)
		panel:DockPadding(padding, padding, padding, padding)

		panel.Paint = self.PaintSlot
	end

	self.Layout:Center()
	self.Layout:SetY(self.Layout:GetY() - size * 0.5)

	local dropHeight = DecayScale(256)

	self.Drop = self:Add("DPanel")
	self.Drop:SetBackgroundColor(Color(255, 0, 0, 20))
	self.Drop:SetSize(DecayScale(640), DecayScale(256))
	self.Drop:Center()
	self.Drop:SetY(ScrH() - dropHeight - DecayScale(64))
	self.Drop:Receiver("Item", function(_, ...) self:DropItem(...) end)

	self:FillSlots()

	GAMEMODE.InventoryPanel = self

	hook.Add("PostDrawHUD", self, function()
		draw.DrawBackgroundBlur(1, 0, 0, ScrW(), ScrH())
	end)
end

function PANEL:FillSlots()
	if self.ItemPanels then
		for _, v in ipairs(self.ItemPanels) do
			v:Remove()
		end
	end

	self.ItemPanels = {}

	local items = lp:GetItems()

	for i = 1, self.InventoryRows * self.InventoryColumns do
		local item = items[i]

		if item then
			local itemPanel = self.Layout:GetChildren()[i]:Add("DecayItemIcon")
			itemPanel:Setup(item)
			itemPanel:Dock(FILL)
			itemPanel:Droppable("Item")

			table.insert(self.ItemPanels, itemPanel)
		end
	end
end

function PANEL:DropItem(panels, dropped)
	if not dropped then
		return
	end

	local panel = panels[1]
	local ent = panel:GetEntity()

	-- So GetItems() immediately filters out the item we're dropping
	ent:SetParent(NULL)

	net.Start("DropItem")
		net.WriteEntity(ent)
	net.SendToServer()

	self:FillSlots()
end

function PANEL:PaintSlot(w, h)
	local offset = DecayScale(2)

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(offset, offset, w - offset * 2, h - offset * 2)

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawOutlinedRect(0, 0, w, h, DecayScale(1))
end

function PANEL:OnRemove()
	GAMEMODE.InventoryPanel = nil
end

function PANEL:OnKeyCodePressed(key)
	if input.LookupKeyBinding(key) == "gm_showspare1" then
		self:Remove()
	end
end

function PANEL:Think()
	if not lp:Alive() then
		self:Remove()
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("DecayInventory", PANEL, "EditablePanel")

net.Receive("OpenInventory", function()
	vgui.Create("DecayInventory")
end)
