{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix4nvchad.homeManagerModules.default];

  programs.nvchad = {
    enable = true;
    # You can configure extra options here (see the Configuration section)

    extraPackages = with pkgs; [
      ripgrep
      lua-language-server
      stylua
      bash-language-server
      alejandra 
      typescript-language-server
      pyright                                 
      rust-analyzer                            
      vue-language-server                       
    ];
    extraConfig = ''
      vim.g.lazyvim_php_lsp = "intelephense"
      vim.lsp.config("qmlls", {
        cmd = { "qmlls6" },
      })
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.vue",
          command = "setfiletype vue",
        })


      local nvlsp = require "nvchad.configs.lspconfig"
        local servers = { "ts_ls", "pyright", "rust_analyzer" }
        for _, lsp in ipairs(servers) do
          vim.lsp.config[lsp] = {
          on_attach = nvlsp.on_attach,
          on_init = nvlsp.on_init,
          capabilities = nvlsp.capabilities,
        }
        vim.lsp.enable(lsp)
      end


      vim.keymap.set("i", "jj", "<ESC>", { desc = "exit insert mode" })
      vim.keymap.set("v", "<A-l>", ">gv", { desc = "Indent right" })
      vim.keymap.set("v", "<A-h>", "<gv", { desc = "Indent left" })
     '';
  };
}
