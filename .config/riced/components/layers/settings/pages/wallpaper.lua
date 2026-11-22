-- Wallpaper picker: current preview, file picker, and the images beside it.

local state = require("data.state")
local settings = require("data.settings").file

local PREVIEW_HEIGHT = 200
local PREVIEW_SIZE = 1024
local THUMB_SIZE = 512
local PAGE_SIZE = 9

local function picture(path, size)
	-- 4K tiles each need their own atlas layer (~200 MB); downscale instead.
	-- The cache keeps the copies, so reopening the page only decodes these.
	local thumb = iced.icon_path(path, { size = size, thumbnail = true })
	return iced.image(thumb or path, {
		width = iced.Length.fill,
		height = iced.Length.fill,
		content_fit = "cover",
	})
end

local function quoted(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function directory()
	local current = state.wallpaper
	local dir = type(current) == "string" and current:match("^(.*)[/\\][^/\\]+$")
	return dir or (os.getenv("HOME") or "") .. "/Pictures/Wallpaper"
end

local cache = { directory = nil, names = {}, at = 0 }
local REFRESH_SECONDS = 2
local EXTENSIONS = { png = true, jpg = true, jpeg = true, webp = true, bmp = true }

local function images()
	local dir = directory()
	local now = os.time()
	if cache.directory == dir and now - cache.at < REFRESH_SECONDS then
		return cache.names
	end
	local names = {}
	if io.popen then
		local pipe = io.popen("ls -1 " .. quoted(dir) .. " 2>/dev/null")
		if pipe then
			for line in pipe:lines() do
				local extension = line:lower():match("%.([%w]+)$")
				if extension and EXTENSIONS[extension] then
					names[#names + 1] = line
				end
			end
			pipe:close()
		end
	end
	table.sort(names)
	cache.directory, cache.names, cache.at = dir, names, now
	return names
end

local function set(path)
	local data = settings.data
	data.background = path
	local ok, err = settings:write(data)
	if not ok then
		log(err)
	end

	state.wallpaper_previous = state.wallpaper
	state.wallpaper = path
	state.wallpaper_progress = 0
	state.wallpaper_transitioning = true
end

local function pick()
	local dbus = riced.plugin("dbus")
	dbus.pick_file({ title = "Choose a wallpaper", path = directory() }, function(paths, error)
		if error == "cancelled" then
			return
		end
		if error then
			log(error)
			return
		end
		set(paths[1])
	end)
end

local page = { index = 1, directory = nil }

function page:view(props)
	local current = state.wallpaper or settings.data.background or ""
	local dir = directory()
	local names = images()

	if page.directory ~= dir then
		page.directory = dir
		page.index = 1
	end
	local count = math.max(1, math.ceil(#names / PAGE_SIZE))
	local index = math.min(math.max(page.index, 1), count)
	page.index = index
	local first = (index - 1) * PAGE_SIZE + 1
	local last = math.min(#names, first + PAGE_SIZE - 1)

	local children = {
		iced.text("Wallpaper", { size = 20, font = { weight = "bold" } }),
		iced.text("Changes apply immediately.", { size = 12, color = theme.secondary }),
	}
	if current ~= "" then
		children[#children + 1] = iced.container(picture(current, PREVIEW_SIZE), {
			width = iced.Length.fill,
			height = PREVIEW_HEIGHT,
			clip = true,
			style = {
				border = { color = iced.opacity(theme.text, 20), width = 1, radius = 4 },
			},
		})
		children[#children + 1] = iced.text(current, { size = 12, color = theme.secondary, wrap = "word_or_glyph" })
	end

	children[#children + 1] = iced.button("Choose a file…", { on_press = pick })
	children[#children + 1] = iced.rule()
	children[#children + 1] = iced.text("Folder: " .. dir, {
		size = 12,
		color = theme.secondary,
		wrap = "word_or_glyph",
	})

	if count > 1 then
		local function step(label, target, enabled)
			return iced.button(
				iced.text(label, {
					align_x = "center",
					align_y = "center",
				}),
				{
					width = 36,
					height = 28,
					padding = 0,
					on_press = enabled and function()
						page.index = target
					end or nil,
					style = {
						background = "#00000000",
						text_color = enabled and theme.primary or iced.opacity(theme.secondary, 40),
						border = { color = iced.opacity(theme.text, 20), width = 1, radius = 4 },
					},
				}
			)
		end
		children[#children + 1] = iced.row({
			step("‹", index - 1, index > 1),
			iced.text(string.format("%d / %d", index, count), {
				width = iced.Length.fill,
				center = true,
				size = 12,
				color = theme.secondary,
			}),
			step("›", index + 1, index < count),
		}, {
			width = iced.Length.fill,
			spacing = 8,
			align_y = "center",
		})
	end

	local items = {}
	for i = first, last do
		local name = names[i]
		local path = dir .. "/" .. name
		local selected = path == current
		local image = picture(path, THUMB_SIZE)
		items[#items + 1] = iced.button(
			iced.column({
				image,
				iced.text(name, {
					size = 11,
					wrap = "none",
					color = selected and theme.primary or theme.secondary,
				}),
			}, {
				spacing = 4,
				width = iced.Length.fill,
				height = iced.Length.fill,
			}),
			{
				width = iced.Length.fill,
				padding = 4,
				on_press = function()
					set(path)
				end,
				style = {
					background = selected and iced.opacity(theme.primary, 20) or "#00000000",
					border = {
						color = selected and theme.success or iced.opacity(theme.text, 20),
						width = selected and 2 or 1,
						radius = 4,
					},
				},
			}
		)
	end
	if #items > 0 then
		children[#children + 1] = iced.grid(items, { columns = 3, spacing = 8 })
	else
		children[#children + 1] = iced.text("No images in this folder", { size = 12, color = theme.secondary })
	end

	return iced.scrollable(
		iced.column(children, {
			width = iced.Length.fill,
			spacing = 8,
		}),
		{
			width = iced.Length.fill,
			height = iced.Length.fill,
		}
	)
end

iced.define("wallpaper", function()
	return page
end)

return page
