function GM:OpenInventory()
	if IsValid(self.InventoryPanel) then
		return
	end

	self.InventoryPanel = vgui.Create("EditablePanel")
	local base = self.InventoryPanel

	base:SetSize(ScrW(), ScrH())
	base:MakePopup()

	function base.OnKeyCodePressed(pnl, key)
		if input.LookupKeyBinding(key) == "gm_showspare1" then
			pnl:Remove()
		end
	end
end

net.Receive("OpenInventory", function()
	GAMEMODE:OpenInventory()
end)
