local M = {}

-- IMPORTANT!!!
-- Lua's string indices start with 1, not 0!

local function tprint(t)
  print(vim.inspect(t))
end


-- find all pattern matches in a string and return as a table
local function find_matches(str, pattern)
  local found_matches = {}
  local index = 1

  while index < #str do
    -- end is reserved word
    local start, end_, matchStr = string.find(str, pattern, index)

    if not start then break end

    table.insert(found_matches, {
      str = matchStr,
      startPos = start,
      endPos = end_
    })
    index = end_ + 1
  end

  return found_matches
end

-- Extract path at cursor location
local function extract_path_at_cursor(match_list, cursor_pos)
  for _, match in ipairs(match_list) do
    -- Lua's string indices start with 1, not 0!
    if cursor_pos + 1 >= match.startPos and cursor_pos + 1 <= match.endPos then
      return match.str
    end
  end
end

-- works for Unix-like systems only
-- if path absolute -> return
-- else make it absolute and return
local function expand_path(file_path)
  if string.sub(file_path, 1, 1) == "/" then
    return file_path
  end
  return vim.fn.expand('%:p:h') .. '/' .. file_path
end

-- validate cases:
-- 1. readable
-- 2. points to current file
-- 3. points to non-markdown file
local function validate_path(abs_path)
  -- Handle Errors
  if vim.fn.filereadable(abs_path) == 0 then
    print("File doesn't exist or unreadable")
    return false
  end

  if vim.fn.expand('%:p') == abs_path then
    print("Link points to current file")
    return false
  end

  if not abs_path:match("%.md$") then
    print("Link points to non-markdown file")
    return false
  end

  return true
end






local FILE_PATH_PATTERN = '%[[^%]]+%]%(([^%)%]]*)%)'

-- MarknavJump opens a link at the cursor location
function M.marknav_forward()
  local current_line = vim.api.nvim_get_current_line()
  local match_list = find_matches(current_line, FILE_PATH_PATTERN)

  if #match_list == 0 then
    print("No matches found on current line")
    return
  end

  local cursor_position = vim.api.nvim_win_get_cursor(0)[2]
  local file_path = extract_path_at_cursor(match_list, cursor_position)

  if not file_path then
    print("Cursor is not placed on valid link")
    return
  end

  file_path = expand_path(file_path)

  if not validate_path(file_path) then
    return
  end

  vim.api.nvim_command('edit ' .. file_path)
end

-- open nth link on the current line
function M.jump_to_nth_link(n)
  if type(n) ~= "number" or n <= 0 then
    print("Invalid link number. Please provide a positive integer.")
    return
  end

  local current_line = vim.api.nvim_get_current_line()
  local match_list = find_matches(current_line, FILE_PATH_PATTERN)

  if #match_list == 0 then
    print("No matches found on current line")
    return
  end

  if n > #match_list then
    print("File number " .. n .. " not found on current line")
    return
  end

  local file_path = match_list[n].str

  if not file_path then
    print("File number " .. n .. " not found on current line")
    return
  end

  file_path = expand_path(file_path)

  if not validate_path(file_path) then
    return
  end

  vim.api.nvim_command('edit ' .. file_path)
end

-- Jump to previous buffer unless stack is empty
function M.marknav_back()
  local buffer_stack = vim.w.buffer_stack

  if #buffer_stack > 1 then
    vim.api.nvim_command('buffer ' .. buffer_stack[#buffer_stack - 1])
  else
    print("Buffer history is empty.")
  end
end

-- MarknavJump opens a link at the cursor location IN A NEW TAB
function M.marknav_tab()
  local current_line = vim.api.nvim_get_current_line()
  local match_list = find_matches(current_line, FILE_PATH_PATTERN)

  if #match_list == 0 then
    print("No matches found on current line")
    return
  end

  local cursor_position = vim.api.nvim_win_get_cursor(0)[2]
  local file_path = extract_path_at_cursor(match_list, cursor_position)

  if not file_path then
    print("Cursor is not placed on valid link")
    return
  end

  file_path = expand_path(file_path)

  if not validate_path(file_path) then
    return
  end

  vim.api.nvim_command('tabnew ' .. file_path)
end



return M
