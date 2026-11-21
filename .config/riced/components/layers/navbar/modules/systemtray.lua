iced.define("systemtray", function()
	local widget = {}

	local function close(dbus, shell)
		shell.menu = nil
		shell.menu_branch = nil
		shell.menu_error = nil
		pcall(dbus.close_tray_menu)
	end

	local function open(dbus, shell, item)
		if shell.menu == item.id then
			close(dbus, shell)
			return
		end
		if not item.menu then
			pcall(dbus.context_menu_tray, item.id)
			return
		end
		shell.menu = item.id
		shell.menu_branch = nil
		shell.menu_error = nil
		local ok, error_message = pcall(dbus.open_tray_menu, item.id, function(_, error)
			if error then
				shell.menu_error = tostring(error)
			end
		end)
		if not ok then
			shell.menu_error = tostring(error_message)
		end
	end

	local function label(value)
		return (value or ""):gsub("_(.)", "%1")
	end

	local function tray_icon(item, size)
		for _, name in ipairs({ item.icon, item.title }) do
			if name and name ~= "" then
				name = name:lower():gsub("_status_icon_%d*$", ""):gsub("%s+", "-")
				if name ~= "" then
					local ok, path =
						pcall(iced.icon_path, name, { size = size, path = item.icon_theme_path, thumbnail = true })
					if ok and path then
						local image = path:lower():match("%.svg$") and iced.svg or iced.image
						return image(path, {
							width = iced.Length.fill,
							height = iced.Length.fill,
							content_fit = "contain",
						})
					end
				end
			end
		end
	end

	local function menu_icon(item, entry)
		if not entry.icon or entry.icon == "" then
			return nil
		end
		local ok, path = pcall(iced.icon_path, entry.icon, { size = 16, path = item.icon_theme_path, thumbnail = true })
		if not ok or not path then
			return nil
		end
		local image = path:lower():match("%.svg$") and iced.svg or iced.image
		return image(path, { width = 16, height = 16, content_fit = "contain" })
	end

	local function rows(menu, item, dbus, shell, depth, out)
		for _, entry in ipairs(menu.items or {}) do
			if entry.type == "separator" then
				out[#out + 1] = iced.container(iced.rule(), {
					width = iced.Length.fill,
					padding = { top = 3, bottom = 3 },
				})
			elseif entry.submenu or entry.icon or (entry.label and entry.label ~= "") then
				local expanded = entry.submenu and shell.menu_branch == entry.id
				local text = label(entry.label)
				if entry.toggle == "checkmark" then
					text = (entry.checked and "✓ " or "  ") .. text
				elseif entry.toggle == "radio" then
					text = (entry.checked and "● " or "○ ") .. text
				end
				local content = iced.row({
					iced.container(menu_icon(item, entry) or iced.space(), {
						width = 16,
						height = 16,
						align_x = "center",
						align_y = "center",
					}),
					iced.text(text, { width = iced.Length.fill, wrap = "none" }),
					entry.submenu and iced.text(expanded and "▾" or "▸", { size = 12 })
						or iced.container(iced.space(), { width = 12 }),
				}, {
					spacing = 6,
					align_y = "center",
					clip = true,
				})
				local on_press
				if entry.enabled ~= false then
					on_press = function()
						if entry.submenu then
							if expanded then
								shell.menu_branch = nil
								pcall(dbus.tray_menu_event, item.id, entry.id, "closed")
							else
								shell.menu_branch = entry.id
								pcall(dbus.tray_menu_event, item.id, entry.id, "opened")
							end
						else
							pcall(dbus.tray_menu_event, item.id, entry.id, "clicked")
							close(dbus, shell)
						end
					end
				end
				out[#out + 1] = iced.button(content, {
					width = iced.Length.fill,
					height = 32,
					padding = 4,
					on_press = on_press,
					style = {
						background = "#00000000",
						text_color = entry.enabled ~= false and theme.text or iced.opacity(theme.text, 40),
						hovered = entry.enabled ~= false and { background = iced.opacity(theme.text, 12) } or nil,
					},
				})
				if expanded then
					rows({ items = entry.children }, item, dbus, shell, depth + 1, out)
				end
			end
		end
	end

	local function menu(item, dbus, shell)
		local current = dbus.tray_menu
		if not item.menu then
			return iced.container(iced.text("Use the application menu"), { padding = 8 }), 48
		end
		if shell.menu_error then
			return iced.container(iced.text(shell.menu_error, { wrap = "word_or_glyph" }), { padding = 8 }), 72
		end
		if not current or current.id ~= item.id then
			return iced.container(iced.text("Loading…"), { padding = 8 }), 40
		end
		if current.error then
			return iced.container(iced.text(current.error, { wrap = "word_or_glyph" }), { padding = 8 }), 72
		end
		local out = {}
		rows(current, item, dbus, shell, 0, out)
		if #out == 0 then
			out[1] = iced.container(iced.text("No menu items"), { padding = 2 })
		end
		local height = math.min(360, math.max(48, 16 + #out * 28))
		return iced.scrollable(iced.column(out, { spacing = 0 }), {
			width = iced.Length.fill,
			height = height,
			direction = "vertical",
			scrollbar_hidden = true,
		}),
			height
	end

	function widget:view(shell)
		local dbus = riced.plugins("dbus")
		local items = dbus.tray or {}
		local children = {
			iced.list_view(items, {
				id = "tray",
				key = "id",
				direction = "horizontal",
				spacing = 4,
				render = function(item)
					local icon = tray_icon(item, shell.height) or iced.text("?")
					local button = iced.button(
						icon,
						iced.variant("systemtray", {
							id = "tray_" .. item.id .. "_button",
							on_press = function()
								if item.menu then
									open(dbus, shell, item)
								else
									pcall(dbus.activate_tray, item.id)
								end
							end,
						})
					)
					return button
				end,
			}),
		}

		-- Popups are siblings of the list, inside the widget's returned tree.
		for _, item in ipairs(items) do
			local id = item.id
			local content, height = iced.space(), 1
			if shell.menu == id then
				content, height = menu(item, dbus, shell)
			end
			children[#children + 1] = iced.popup(
				iced.container(content, {
					width = iced.Length.fill,
					height = iced.Length.fill,
					padding = 8,
					style = {
						background = iced.opacity(theme.background, 40),
						border = { color = iced.opacity(theme.text, 20), width = 1 },
					},
					transition = iced.transition("popup_motion"),
				}),
				{
					id = "tray_" .. id .. "_menu",
					visible = shell.menu == id,
					width = 240,
					height = height,
					anchor = "tray_" .. id .. "_button",
					on_closed = function()
						if shell.menu == id then
							close(dbus, shell)
						end
					end,
					anchor_edge = iced.PopupAnchor.bottom,
					gravity = iced.PopupGravity.bottom,
				}
			)
		end

		return iced.stack(children)
	end

	return widget
end)
