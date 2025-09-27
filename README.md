# dictionary.nvim
A simple Neovim plugin to manage notes.

---

## Features

- Store notes with `Name` and `Description`.
- Floating window UI with customizable size and position.
- Highlighting for names and descriptions.
- Auto-save and auto-refresh on buffer write.
- Configurable options for path, floating window size, and border style.

---

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    dir = "~/dictionary.nvim",
    opts = {
        -- Path to save your notes (default: $HOME/my_notes.md)
        -- save_path = "~/my_notes.md",

        -- Floating window width/height relative to editor
        -- width_ratio = 0.7,
        -- height_ratio = 0.5,

        -- Floating window border style
        -- border = "rounded",
    },
    config = function(_, opts)
        require("dictionary").setup(opts)
    end,
}
