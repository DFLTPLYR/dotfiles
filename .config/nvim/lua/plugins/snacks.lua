return {
  "folke/snacks.nvim",
  opts = {
    notifier = { enabled = true },
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
