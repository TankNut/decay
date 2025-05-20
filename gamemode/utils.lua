if CLIENT then
	local matBlurScreen = Material("pp/blurscreen")

	function draw.DrawBackgroundBlur(frac, x, y, w, h)
		local was = DisableClipping(true)

		surface.SetMaterial(matBlurScreen)
		surface.SetDrawColor(255, 255, 255, 255)

		for i = 1, 3 do
			matBlurScreen:SetFloat("$blur", frac * 5 * (i / 3))
			matBlurScreen:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x or 0, y or 0, w or ScrW(), h or ScrH())
		end

		DisableClipping(was)
	end

	function DecayScale(w)
		return math.max(math.Round(w * (ScrW() / 1920)), 1)
	end

	local PANEL = FindMetaTable("Panel")

	function PANEL:SetCloseOnPause(bool)
		if bool then
			hook.Add("OnPauseMenuShow", self, function()
				if vgui.FocusedHasParent(self) then
					if isfunction(self.Close) then
						self:Close()
					else
						self:Remove()
					end

					return false
				end
			end)
		else
			hook.Remove("OnPauseMenuShow", self)
		end
	end
end
