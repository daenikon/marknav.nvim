local buffer = require("marknav.buffer") 
local cmds = require("marknav.cmdmgr")

local M = {}

-- Set up commands for Markdown file navigation
function M.setup()
  local augroup = vim.api.nvim_create_augroup("MarknavAutocommands", { clear = true })
  vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
    group = augroup,
    callback = buffer.handle_stack
  })

  vim.api.nvim_create_user_command(
    'MarknavJump',
    cmds.forward_jump,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavTab',
    cmds.tab_jump,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavBack',
    cmds.back_jump,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavJumpTo',
    function(opts)
      cmds.jump_to_nth_link(tonumber(opts.args))
    end,
    {nargs = 1}
  )
end

return M
