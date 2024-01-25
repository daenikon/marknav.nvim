local buffer = require("marknav.buffer") 
local cmds = require("marknav.cmdmgr")

local M = {}

-- Set up commands for Markdown file navigation
function M.setup(user_config)
  user_config = user_config or { use_default_keybinds = true }

  local augroup = vim.api.nvim_create_augroup("MarknavAutocommands", { clear = true })
  vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
    group = augroup,
    pattern = {"*.md", "*.markdown"},
    callback = buffer.handle_stack
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      -- User Commands
      vim.api.nvim_create_user_command('MarknavJump', cmds.forward_jump, {nargs = 0})
      vim.api.nvim_create_user_command('MarknavBack', cmds.back_jump, {nargs = 0})
      vim.api.nvim_create_user_command('MarknavTab', cmds.tab_jump, {nargs = 0})
      vim.api.nvim_create_user_command('MarknavJumpTo', cmds.input_jump, {nargs = 0})

      -- Keybindings
      if user_config.use_default_keybinds then
        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', ':MarknavJump<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<BS>', ':MarknavBack<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<Leader><CR>', ':MarknavTab<CR>', opts)
        vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>m', ':MarknavJumpTo<CR>', opts)
      end
    end,
  })
end

return M
