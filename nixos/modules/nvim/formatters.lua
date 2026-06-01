-- formatters
require("conform").formatters.qmlformat = {
	command = "qmlformat",
	args = { "-i" },
	stdin = false,
}
require("conform").formatters.by_ft = require("conform").formatters.by_ft or {}
require("conform").formatters.by_ft.qml = { "qmlformat" }
