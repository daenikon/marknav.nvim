local buffer = require("marknav.buffer") 
--local linkmgr = require("marknav.linkhandler")

-- testing
local linkfinder = require("marknav.linkfinder")

local M = {}

-- Set up commands for Markdown file navigation
function M.setup()
  local augroup = vim.api.nvim_create_augroup("MarknavAutocommands", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    callback = buffer.handle_stack
  })

  vim.api.nvim_create_user_command(
    'MarknavJump',
    linkfinder.marknav_forward,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavTab',
    linkfinder.marknav_tab,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavBack',
    linkfinder.marknav_back,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavJumpTo',
    function(opts)
      linkfinder.jump_to_nth_link(tonumber(opts.args))
    end,
    {nargs = 1}
  )
end

return M
