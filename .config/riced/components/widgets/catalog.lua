-- The desktop widget catalog: every widget module, in gallery order.

local catalog = {}

for _, name in ipairs({
	"components.widgets.cpu",
	"components.widgets.gpu",
	"components.widgets.ram",
	"components.widgets.weather",
	"components.widgets.palette",
}) do
	-- Parenthesised so a loader path returned alongside the module is dropped.
	catalog[#catalog + 1] = (require(name))
end

return catalog
