-- Load every motion preset up front. iced.transition("name") otherwise lazily
-- looks for a file whose stem matches "name", so file names are load keys.
require("components.motion.basic")
require("components.motion.list")
require("components.motion.notification")
require("components.motion.popup")
