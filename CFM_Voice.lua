local ADDON_NAME = ...

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
if not LSM then return end

local SOUND_DIR = "Interface\\AddOns\\" .. ADDON_NAME .. "\\vivian\\"

local SOUND_MAP = {
	{ name = "Adds",      file = "adds.mp3" },
	{ name = "Countdown", file = "countdown.mp3" },
	{ name = "Danger",    file = "danger.mp3" },
	{ name = "Kick",      file = "kick.mp3" },
	{ name = "Magi",      file = "magi.mp3" },
	{ name = "Move",      file = "move.mp3" },
	{ name = "Note",      file = "note.mp3" },
	{ name = "Run",       file = "run.mp3" },
	{ name = "Soul",      file = "soul.mp3" },
	{ name = "Spread",    file = "spread.mp3" },
	{ name = "Stop",      file = "stop.mp3" },
	{ name = "Surge",     file = "surge.mp3" },
	{ name = "Warning",   file = "warning.mp3" },
}

--- This isn't ideal: I'll worry about it when I have more different voice types.
--- Maybe it should just be a big ol' table.
for _, sound in ipairs(SOUND_MAP) do
	LSM:Register(LSM.MediaType.SOUND, "CFM - Vivian - " .. sound.name, SOUND_DIR .. sound.file)
end
