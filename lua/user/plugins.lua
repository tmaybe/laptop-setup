local M = {}

M.plugins = function(use)
  -- Add your own plugins
  -- use 'kyazdani42/nvim-tree.lua'
  -- use '~/my-prototype-plugin'
  -- see :help packer for more options

  -- toggle the quickfix list with <Leader>q
  use 'milkypostman/vim-togglelist'
end

return M
