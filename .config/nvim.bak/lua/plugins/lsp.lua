return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { "ron-rs/ron.vim" },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        vtsls = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "vue",
          },
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = LazyVim.get_pkg_path("vue-language-server", "/node_modules/@vue/language-server"),
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
          },
        },
      },
      setup = {
        tsserver = function()
          require("typescript").setup({ server = require("lspconfig").tsserver })
          return true
        end,
      },
    },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", opts = {} },
      {
        "jose-elias-alvarez/typescript.nvim",
        init = function()
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File" })
        end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
        ron = { "ron" },
      },
    },
  },
}
