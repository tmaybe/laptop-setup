-- Called after everything just before setting a default colorscheme
-- Configure you own bindings or other preferences. e.g.:
--
-- vim.opt.number = false -- No line numbers
-- require('utils').map('n', 's', ':MultipleCursorsFind<cr>')
-- vim.cmd[[colorscheme hybrid]]
-- ...
--

-- move easily between splits
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true })

-- highlight yanked text
vim.api.nvim_exec([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{timeout=500}
  augroup end
]], false)

-- prefer gigavolt colorscheme
vim.cmd[[colorscheme base16-gigavolt]]
