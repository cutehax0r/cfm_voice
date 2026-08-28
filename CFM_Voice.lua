local ADDON_NAME, ns = ...

function ns.RegisterVoicePack(dirName, packLabel, sounds)
	local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
	if not LSM then return end

	local dir = "Interface\\AddOns\\" .. ADDON_NAME .. "\\" .. dirName .. "\\"
	for _, sound in ipairs(sounds) do
		LSM:Register(LSM.MediaType.SOUND, "CFM - " .. packLabel .. " - " .. sound.name, dir .. sound.file)
	end
end
