# manager.nvim
NeoVim Plugin Manager with Limited Features

## Installation

To install manager.nvim, add into your `init.lua`:

```lua
local managerpath = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'manager', 'start', 'manager.nvim')
if not (vim.uv or vim.loop).fs_stat(managerpath) then
    local managerrepo = "https://github.com/shizukani-cp/manager.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=main", managerrepo, managerpath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone manager.nvim:\n", "ErrorMsg" },
        }, true, {})
    end
end
vim.opt.runtimepath:prepend(managerpath)
```

You need NeoVim 0.5 or newer and Git installed.

## Usage

To use manager.nvim, load it in your configuration file and add your plugins:

```lua
local manager = require("manager.core").new()

manager:add({
    id = "telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim",
    dependencies = {
        "plenary.nvim",
    },
    config = function()
        -- Write your config here...
    end
})

manager:add({
    id = "plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim",
})

manager:load("telescope.nvim")
```
Each plugin configuration requires an `id` (unique name) and a `url` (the plugin GitHub repository).
You can specify dependencies and a `config` function to set up your plugin after loading if needed.
To load a plugin, use `manager:load("plugin_id")`.

## Contributing

Contributions, bug reports, and feature requests are welcome!
Please open an issue or pull request on GitHub.

## License

This project is licensed under the MIT License.
