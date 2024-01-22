local buffer = require("marknav.buffer") 

local M = {}

-- Jump to previous buffer unless stack is empty
function M.jump_link_back()
  local buffer_stack = vim.w.buffer_stack

  if #buffer_stack > 1 then
    vim.api.nvim_command('buffer ' .. buffer_stack[#buffer_stack - 1])
  else
    print("Buffer history is empty.")
  end
end

-- works for Unix-like systems only
local function modify_path(linkpath)
  -- if absolute --> return
  if string.sub(linkpath, 1, 1) == "/" then
    return linkpath
  end
  -- append relative path to current directory
  return vim.fn.expand('%:p:h') .. '/' .. linkpath
end

local function process_link(link_path)
  local full_path = modify_path(link_path)

  -- Handle Errors
  if vim.fn.filereadable(full_path) == 0 then
    print("The linked file doesn't exist or isn't readable")
    return false
  end

  if vim.fn.expand('%:p') == full_path then
    print("The link points to the current file")
    return false
  end

  if not full_path:match("%.md$") then
    print("The link points to non-markdown file")
    return false
  end

  -- push_buffer(vim.api.nvim_get_current_buf())

  vim.api.nvim_command('edit ' .. full_path)
  return true
end


function M.jump_link_forward()
  local current_line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1

  local index = 1
  while true do
    local link_start, link_end, link_path = string.find(current_line, '%[[^%]]+%]%(([^%)%]]*)%)', index)
    if not link_start then break end

    if cursor_col >= link_start and cursor_col <= link_end then
      return process_link(link_path)
    end

    index = link_end + 1
  end

  print("No Markdown link found under cursor.")
end



function M.jump_to_nth_link(n)
  if type(n) ~= "number" or n <= 0 then
    print("Invalid link number. Please provide a positive integer.")
    return
  end

  local current_line = vim.api.nvim_get_current_line()

  local index = 1
  local count = 0
  while true do
    local link_start, link_end, link_path = string.find(current_line, '%[[^%]]+%]%(([^%)%]]*)%)', index)
    if not link_start then break end

    count = count + 1
    if count == n then
      return process_link(link_path)
    end

    index = link_end + 1
  end

  if count < n then
    print("Link number " .. n .. " not found in the current line.")
  end
end




-- Set up commands for Markdown file navigation
function M.setup()
  local augroup = vim.api.nvim_create_augroup("MarknavAutocommands", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    callback = buffer.handle_stack
  })

  vim.api.nvim_create_user_command(
    'MarknavJump',
    M.jump_link_forward,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavBack',
    M.jump_link_back,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarknavJumpTo',
    function(opts)
      M.jump_to_nth_link(tonumber(opts.args))
    end,
    {nargs = 1}
  )
end

return M
