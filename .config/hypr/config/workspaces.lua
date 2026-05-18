local monitors = hl.get_monitors()
for _, m in ipairs(monitors) do
	for i = 1, 10 do
		hl.workspace_rule({
			workspace = m.name .. "-" .. i,
			monitor = m.name,
			default = i == 1,
			persistent = true,
		})
	end
end
