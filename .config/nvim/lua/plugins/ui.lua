return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- theme
  { "ellisonleao/gruvbox.nvim" },
  -- Tokyonight
  { "folke/tokyonight.nvim", lazy = true, opts = { style = "moon" } },
  -- Catppuccin
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "frappe", -- latte, frappe, macchiato, mocha
      lsp_styles = {
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        mini = true,
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        snacks = true,
        telescope = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = {
          highlights = {
            fill = { bg = "NONE", fg = "NONE" },
            background = { bg = "NONE", fg = "NONE" },
            buffer_visible = { bg = "NONE", fg = "NONE" },
            separator = { bg = "NONE", fg = "NONE" },
            buffer_selected = { bg = "#1e0f14", fg = "#f9dbe2", bold = true },
          },
        },
      },
    },
  },
}
