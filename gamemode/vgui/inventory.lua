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

	hook.Add("PostDrawHUD", base, function()
		draw.DrawBackgroundBlur(1, 0, 0, ScrW(), ScrH())
	end)
end

net.Receive("OpenInventory", function()
	GAMEMODE:OpenInventory()
end)
