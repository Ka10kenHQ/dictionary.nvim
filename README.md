# dictionary.nvim
A simple Neovim plugin to manage notes.

---
> **Caution:** Use a `.md` file (Markdown) for your `save_path`. This ensures proper formatting and avoids parsing errors.
---

## Features

- Store notes with `Name` and `Description`.
- Floating window UI with customizable size and position.
- Highlighting for names and descriptions.
- Auto-save and auto-refresh on buffer write.
- Configurable options for path, floating window size, and border style.

---

## Installation

```lua
return {
	"Ka10kenHQ/dictionary.nvim",
	opts = {},
	config = function(_, opts)
		require("dictionary").setup(opts)
	end,
}
```

## Customize

```lua
opts = {
   save_path = "$HOME/not_here.md",
   width_ratio = 0.7,
   height_ratio = 0.5,
   border = "rounded
}
```
