include("shared.lua")

local whitelist = {
	["materials"] = true,
	["models"] = true,
	["particles"] = true,
	["resource"] = true,
	["sound"] = true
}

for _, addon in ipairs(engine.GetAddons()) do
	if not addon.mounted or not addon.downloaded then
		continue
	end

	local _, folders = file.Find("*", addon.title)

	for _, folder in ipairs(folders) do
		if whitelist[folder] then
			resource.AddWorkshop(addon.wsid)

			break
		end
	end
end
