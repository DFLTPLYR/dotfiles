return {
  "folke/snacks.nvim",
  opts = {
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
