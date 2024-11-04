# FloatTerm
A floating terminal for Neovim. Running `:FloatTerm` will create a floating terminal window in your
neovim session, and running `:FloatTerm` again will hide the terminal, but keep it running in the
background.

## Installation
Install using your favorite package manager. F ex using
[vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'EmilOhlsson/FloatTerm.nvim'
```

## Configuration
Using a lua context, set up using the following pattern:
```lua
require('FloatTerm').setup()
```

Or, configure the apperance a bit more
```lua
local float_term = require('FloatTerm')
float_term.setup({
    window_config = {
        border = 'shadow',
        title = 'FloatTerm',
        title_pos = 'left',
    },
    pad_vertical = 5,
    pad_horizontal = 10,
})
```

You can also bind to a keyboard shortcut
```lua
local float_term = require('FloatTerm')
float_term.setup()
vim.keymap.set('n', '<c-f>', float_term.toggle_window, {
    noremap = true,
    desc = 'Toggle floating terminal',
})
```

It is recommended that you make it a bit easier to exit insert mode while in terminal with this
plugin. You can map `Esc` to leave insert mode using
```vim
tnoremap <Esc> <C-\><C-n>
```
