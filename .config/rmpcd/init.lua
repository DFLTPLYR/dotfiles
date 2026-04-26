-- ##############################################################
-- ##                                                          ##
-- ## This is an example config file. Uncomment and customize  ##
-- ## to your liking. Check out the documentation for more     ##
-- ## information. https://rmpc.mierak.dev/rmpcd/              ##
-- ##                                                          ##
-- ##############################################################

---@type Config
local config = {
	-- Point rmpcd to your mpd server
	address = "127.0.0.1:6600",
}

-- Enable mpris support
config.mpris = true

-- Automatically increment play count on song change
rmpcd.install("#builtin.playcount")

rmpcd.install("plugins.lyrics")

-- Install notification on song change builtin
rmpcd.install("plugins.notify"):setup({
	debounce_delay = 0,
})

return config
