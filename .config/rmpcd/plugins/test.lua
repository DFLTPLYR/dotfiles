require("types")
local lyrics = require("rmpcd.lyrics")
local notify = require("rmpcd.notify")
local playcount = require("rmpcd.playcount")
local log = require("rmpcd.log")
local mpd = require("rmpcd.mpd")

local last_playlist_length = nil
rmpcd.on("idle_event", function(ev)
	if ev ~= "playlist" then
		return
	end

	local status, err = mpd.get_status()
	if err ~= nil then
		log.error("Failed to get status: " .. err)
		return
	end

	local len = status.playlistlength

	if len == 1 and (last_playlist_length == 0 or last_playlist_length == nil) then
		log.info("Playlist was empty and now has one song, starting playback")
		mpd.play()
		return
	end

	last_playlist_length = len
end)

-- lyrics.install()
notify.install()
playcount.install()

---@type Config
return {
	address = "@mpd",
	mpris = false,
	subscribe_channels = { "test" },
}
