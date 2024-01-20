local M = {}

-- Stack to keep track of buffer history
local buffer_stack = {}

-- Function to push a buffer onto the stack
local function push_buffer(bufnr)
  table.insert(buffer_stack, bufnr)
end

-- Function to pop a buffer from the stack and switch to it
function M.pop_and_go_to_buffer()
  if #buffer_stack == 0 then
    print("Buffer history is empty.")
    return
  end

  local last_bufnr = table.remove(buffer_stack)
  if not vim.api.nvim_buf_is_loaded(last_bufnr) then
    print("Previous buffer no longer exists.")
    return
  end

  vim.api.nvim_command('buffer ' .. last_bufnr)
end

-- local function is_link_in_line()

-- works for Unix-like systems only
local function modify_path(linkpath)
  -- if absolute --> return
  if string.sub(linkpath, 1, 1) == "/" then
    return linkpath
  end

  local current_file_dir = vim.fn.expand('%:p:h')
  return current_file_dir .. '/' .. linkpath
end


local function is_file_readable(path)
  return vim.fn.filereadable(path) == 1
end

-- Function to check if the cursor is on the relative link and open the link
function M.check_cursor_on_link()
  local current_line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1

  local link_start, link_end, link_path = string.find(current_line, '%[[^%]]+%]%(([^%)%]]*)%)')

  if not link_path or cursor_col < link_start or cursor_col > link_end then
    print("No Markdown link found under cursor.")
    return
  end

  push_buffer(vim.api.nvim_get_current_buf())

  modified_path = modify_path(link_path)

  if not is_file_readable(modified_path) then
    print("The linked file is not readable: " .. modified_path)
    return
  end

  vim.api.nvim_command('edit ' .. modified_path)
end


-- Set up commands for Markdown file navigation
function M.setup()
  vim.api.nvim_create_user_command(
    'MarkNavNext',
    M.check_cursor_on_link,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarkNavPrevious',
    M.pop_and_go_to_buffer,
    {nargs = 0}
  )
end

return M
