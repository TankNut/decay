surface.CreateFont("SpleenChatSmall", {
	font = "Spleen 8x16",
	size = ScreenScale(8),
	weight = 500
})

function GM:DrawBubble(text, pos)
	surface.SetTextColor(255, 255, 255)
	surface.SetFont("SpleenChatSmall")

	local width = 0
	local height = 0

	local _, lineHeight = surface.GetTextSize("W")

	for str in string.gmatch(text, "[^\n]*") do
		if #str > 0 then
			local lineWidth = surface.GetTextSize(str)

			width = math.max(width, lineWidth)
		end

		height = height + lineHeight
	end

	height = height - lineHeight

	local screen = pos:ToScreen()
	local x = screen.x - (width * 0.5)
	local y = screen.y - (height * 0.5)

	local radius = ScreenScale(16)

	x = math.floor(math.Clamp(x, radius, ScrW() - width - radius))
	y = math.floor(math.Clamp(y, radius, ScrH() - height - radius))

	for str in string.gmatch(text, "[^\n]*") do
		surface.SetTextPos(x, y)
		surface.DrawText(str)

		y = y + lineHeight
	end
end

GM.MessageBubbles = GM.MessageBubbles or {}
GM.BubbleRadius = 128

function GM:DrawBubbles()
	local bubbles = {}

	for bubble in pairs(self.MessageBubbles) do
		table.insert(bubbles, bubble)
	end

	local eye = EyePos()

	table.sort(bubbles, function(a, b)
		return a.Pos:DistToSqr(eye) > b.Pos:DistToSqr(eye)
	end)

	for _, bubble in ipairs(bubbles) do
		self:DrawBubble(bubble.Text, bubble.Pos)
	end
end

function GM:HUDPaint()
	lp:RunPlayerClass("HUDPaint")
end

function GM:HUDPaintBackground()
	self:DrawBubbles()
end
