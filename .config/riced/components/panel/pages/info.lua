-- System overview for the settings panel.

local function gibibytes(bytes)
	if type(bytes) ~= "number" then
		return "unknown"
	end
	return string.format("%.1f GiB", bytes / 1024 / 1024 / 1024)
end

local function ratio(used, total)
	if type(used) ~= "number" or type(total) ~= "number" or total <= 0 then
		return 0
	end
	return math.min(math.max(used / total, 0), 1)
end

local function duration(seconds)
	if type(seconds) ~= "number" then
		return "unknown"
	end
	local days = seconds // 86400
	local hours = seconds % 86400 // 3600
	local minutes = seconds % 3600 // 60
	if days > 0 then
		return string.format("%dd %dh", days, hours)
	elseif hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	end
	return string.format("%dm", minutes)
end

local function row(label, value)
	return iced.row({
		iced.text(label, { width = 110, size = 13, color = theme.secondary }),
		iced.text(value, { width = iced.Length.fill, size = 13, wrap = "word_or_glyph" }),
	}, { spacing = 8 })
end

local function section(title)
	return iced.text(title, { size = 13, color = theme.primary, font = { weight = "bold" } })
end

local function meter(value)
	return iced.progress_bar(nil, { value = value, girth = 4, width = iced.Length.fill })
end

iced.define("info", function()
	local page = {}

	function page:view(props)
		local system = riced.plugins("system")
		if not system or not system.alive then
			return iced.text("system extension offline", { color = theme.secondary })
		end

		local store = system.store
		local host = store.host or {}
		local cpu = store.cpu or {}
		local memory = store.memory or {}

		local rows = {
			section("System"),
			row("Host", host.name or "unknown"),
			row("OS", (string.format("%s %s", host.os or "", host.version or ""):gsub("%s+$", ""))),
			row("Kernel", host.kernel or "unknown"),
			row("Uptime", duration(host.uptime)),
			row("Processes", tostring(store.processes or "unknown")),

			section("CPU"),
			row("Model", cpu.brand or "unknown"),
			row("Usage", string.format(
				"%.0f%%  %.2f GHz  %d cores",
				cpu.usage or 0,
				(cpu.frequency or 0) / 1000,
				cpu.cores or 0
			)),
			meter(ratio(cpu.usage, 100)),
			row("Load", string.format("%.2f  %.2f  %.2f", cpu.load1 or 0, cpu.load5 or 0, cpu.load15 or 0)),

			section("Memory"),
			row("RAM", string.format("%s / %s", gibibytes(memory.used), gibibytes(memory.total))),
			meter(ratio(memory.used, memory.total)),
		}
		if (memory.swap_total or 0) > 0 then
			rows[#rows + 1] =
				row("Swap", string.format("%s / %s", gibibytes(memory.swap_used), gibibytes(memory.swap_total)))
			rows[#rows + 1] = meter(ratio(memory.swap_used, memory.swap_total))
		end

		local gpus = store.gpus or {}
		if #gpus > 0 then
			rows[#rows + 1] = section("Graphics")
			for _, gpu in ipairs(gpus) do
				local detail = {}
				if gpu.busy then
					detail[#detail + 1] = string.format("%.0f%%", gpu.busy)
				end
				if gpu.temp then
					detail[#detail + 1] = string.format("%.0f°C", gpu.temp)
				end
				if gpu.vram_used and gpu.vram_total then
					detail[#detail + 1] = string.format("%s / %s VRAM", gibibytes(gpu.vram_used), gibibytes(gpu.vram_total))
				end
				rows[#rows + 1] = row(gpu.name or "GPU", table.concat(detail, "  "))
			end
		end

		local disks = store.disks or {}
		if #disks > 0 then
			rows[#rows + 1] = section("Disks")
			for _, disk in ipairs(disks) do
				rows[#rows + 1] = row(
					disk.mount or disk.fs or "disk",
					string.format("%s / %s", gibibytes(disk.used), gibibytes(disk.total))
				)
				rows[#rows + 1] = meter(ratio(disk.used, disk.total))
			end
		end

		return iced.scrollable(iced.column(rows, {
			width = iced.Length.fill,
			spacing = 6,
		}), {
			width = iced.Length.fill,
			height = iced.Length.fill,
		})
	end

	return page
end)
