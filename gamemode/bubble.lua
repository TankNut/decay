GM.Bubbles = GM.Bubbles or {}

local meta = FindMetaTable("Bubble")

if not meta then
	meta = {}
	meta.__index = meta
	meta.__name = "Bubble"

	RegisterMetaTable("Bubble", meta)
end

AccessorFunc(meta, "Entity", "Entity")
AccessorFunc(meta, "Pos", "Pos")

AccessorFunc(meta, "AutoRemove", "AutoRemove")

function meta:Initialize()
	self.Entity = false
	self.Pos = vector_origin

	self.Lines = {}
	self.Index = 1

	self.AutoRemove = false
end

local function lastSpace(str)
	for i = #str, 1, -1 do
		if str[i] == " " then
			return i
		end
	end
end

function meta:AddLine(text, font, duration, fade, color)
	if text then
		local max = ScreenScale(90)
		local width = 0
		local chars = {}
		local buffer = {}
		local store = {}

		for _, code in utf8.codes(text) do
			local char = utf8.char(code)
			local charWidth = surface.GetTextSize(char)

			if width + charWidth > max then
				local last = lastSpace(buffer)

				if last then
					for i = last + 1, #buffer do
						table.insert(store, buffer[i])
						buffer[i] = nil
					end

					table.Add(chars, buffer)
					table.insert(chars, "\n")
					buffer = {}

					for k, v in ipairs(store) do
						if #buffer == 0 and v == " " then
							continue
						end

						table.insert(buffer, v)
					end

					width = surface.GetTextSize(table.concat(buffer))
					store = {}
				else
					table.Add(chars, buffer)
					table.insert(chars, "\n")
					buffer = {}

					width = 0
				end
			end

			if width == 0 and char == " " then
				continue
			end

			table.insert(buffer, char)

			width = width + charWidth
		end

		table.Add(chars, buffer)
		text = table.concat(chars)
	else
		text = ""
	end

	self.Lines[self.Index] = {
		Text = text,
		Font = font or "SpleenChatSmall",
		Color = color or color_white,
		StartTime = CurTime(),
		Duration = duration or 5,
		Fade = fade or 1,
		Alpha = 1
	}

	self.Index = self.Index + 1
end

function meta:Update()
	if self.Entity then
		local ent = self.Entity

		if not IsValid(ent) then
			self:Remove()

			return true
		end

		self:SetPos(ent:EyePos() + Vector(0, 0, 8))
	end

	local ct = CurTime()

	for k, line in pairs(self.Lines) do
		local endTime = line.StartTime + line.Duration

		if endTime <= ct then
			self.Lines[k] = nil

			continue
		end

		if line.Fade > 0 then
			local fade = 1 - math.TimeFraction(endTime - line.Fade, endTime, ct)

			line.Alpha = math.Clamp(fade, 0, 1)
		end
	end

	if table.Count(self.Lines) == 0 then
		if self.AutoRemove then
			self:Remove()
		end

		return true
	end
end

function meta:IsValid()
	return tobool(GAMEMODE.Bubbles[self])
end

function meta:Remove()
	GAMEMODE.Bubbles[self] = nil
end

function meta:ToScreen(width, height)
	local radius = ScreenScale(16)

	if self.Entity == lp and not lp:ShouldDrawLocalPlayer() then
		return ScrW() * 0.5, ScrH() - radius
	end

	local screen = self.Pos:ToScreen()
	local x = screen.x
	local y = screen.y

	x = math.floor(math.Clamp(x, radius + width * 0.5, ScrW() - width * 0.5 - radius))
	y = math.floor(math.Clamp(y, radius + height, ScrH() - radius))

	return x, y
end

function meta:Draw()
	if self:Update() then
		return
	end

	surface.SetFont(self.Font)

	local width = 0
	local height = 0

	for _, line in SortedPairs(self.Lines) do
		surface.SetFont(line.Font)

		local lineWidth, lineHeight = surface.GetTextSize(line.Text)

		width = math.max(width, lineWidth)
		height = height + lineHeight
	end

	local x, y = self:ToScreen(width, height)

	for _, line in SortedPairs(self.Lines, true) do
		surface.SetFont(line.Font)

		local _, lineHeight = surface.GetTextSize("W")
		local fullWidth, fullHeight = surface.GetTextSize(line.Text)
		local offset = -fullHeight

		surface.SetTextColor(line.Color.r, line.Color.g, line.Color.b, line.Color.a * line.Alpha)

		for str in string.gmatch(line.Text, "[^\n]*") do
			self:DrawText(str, x - fullWidth * 0.5, y + offset)

			offset = offset + lineHeight * 0.5
		end

		y = y - fullHeight
	end
end

function meta:DrawText(text, x, y)
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

function GM:CreateBubble()
	local instance = setmetatable({}, meta)
	instance:Initialize()

	GAMEMODE.Bubbles[instance] = true

	return instance
end

function GM:DrawBubbles()
	local bubbles = table.GetKeys(self.Bubbles)
	local eye = EyePos()

	table.sort(bubbles, function(a, b)
		return a.Pos:DistToSqr(eye) > b.Pos:DistToSqr(eye)
	end)

	for _, bubble in ipairs(bubbles) do
		bubble:Draw()
	end
end
