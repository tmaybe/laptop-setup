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

-- show count of word under the cursor
vim.keymap.set('n', '<Leader>yc', 'yiw:%s/<C-r>0//gn<CR>', { silent = true })

-- highlight yanked text
vim.api.nvim_exec([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{timeout=500}
  augroup end
]], false)

-- prefer gigavolt colorscheme
vim.cmd[[colorscheme base16-gigavolt]]

-- run oi with the word under the cursor
vim.keymap.set('n', '<Leader>yoi', 'yiw:!oi<Space><C-r>0<CR>', { silent = true })
-- run oi with the word under the cursor, specifying a commit
vim.keymap.set('n', '<Leader>yoc', 'yiw:!oi<Space>-c<Space><C-r>0<CR>', { silent = true })
