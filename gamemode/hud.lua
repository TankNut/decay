surface.CreateFont("SpleenChatSmall", {
	font = "Spleen 8x16",
	size = ScreenScale(8),
	weight = 500
})

function GM:HUDPaint()
	lp:RunPlayerClass("HUDPaint")
end

function GM:HUDPaintBackground()
	self:DrawBubbles()
end
