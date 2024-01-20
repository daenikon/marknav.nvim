local M = {}

-- Stack to keep track of buffer history
local buffer_stack = {}

-- Function to push a buffer onto the stack
local function push_buffer(bufnr)
  table.insert(buffer_stack, bufnr)
end

-- Function to pop a buffer from the stack and switch to it
function M.jump_back()
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

-- works for Unix-like systems only
local function modify_path(linkpath)
  -- if absolute --> return
  if string.sub(linkpath, 1, 1) == "/" then
    return linkpath
  end
  -- append relative path to current directory
  return vim.fn.expand('%:p:h') .. '/' .. linkpath
end


function M.jump_forward()
    local current_line = vim.api.nvim_get_current_line()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1

    local index = 1
    while true do
        local link_start, link_end, link_path = string.find(current_line, '%[[^%]]+%]%(([^%)%]]*)%)', index)
        if not link_start then break end

        if cursor_col >= link_start and cursor_col <= link_end then
            local modified_path = modify_path(link_path)

            if vim.fn.filereadable(modified_path) == 0 then
                print("The linked file is not readable: " .. modified_path)
                return
            end

            push_buffer(vim.api.nvim_get_current_buf())

            vim.api.nvim_command('edit ' .. modified_path)
            return
        end

        index = link_end + 1
    end

    print("No Markdown link found under cursor.")
end



-- Set up commands for Markdown file navigation
function M.setup()
  vim.api.nvim_create_user_command(
    'MarkNavNext',
    M.jump_forward,
    {nargs = 0}
  )
  vim.api.nvim_create_user_command(
    'MarkNavPrevious',
    M.jump_back,
    {nargs = 0}
  )
end

return M
