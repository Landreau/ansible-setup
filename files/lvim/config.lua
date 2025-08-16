-- Minimal LunarVim config
lvim.leader = "space"
lvim.keys.normal_mode["<leader>w"] = ":w<cr>"
lvim.keys.normal_mode["<leader>q"] = ":q<cr>"
lvim.builtin.treesitter.ensure_installed = { "lua", "bash", "json", "yaml", "python", "cpp" }
lvim.format_on_save = true