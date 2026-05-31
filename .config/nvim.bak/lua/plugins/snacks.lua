return {
  "folke/snacks.nvim",
  opts = {
    scroll = { enabled = false },
    dashboard = { enabled = false },
    animate = { enabled = false },
    notifier = { enabled = true },
    styles = {
      picker = {
        backdrop = false,
        wo = {
          winblend = 5,
        },
      },
    },
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
    },
  },
}
