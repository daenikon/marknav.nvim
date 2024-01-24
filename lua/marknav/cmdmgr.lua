PATHMGR = require("marknav.pathmgr")

local M = {}

local FILE_PATH_PATTERN = '%[[^%]]+%]%(([^%)%]]*)%)'

-- Jump to previous buffer unless stack is empty
function M.back_jump()
  local buffer_stack = vim.t.buffer_stack
  -- go back if stack not empty
  if #buffer_stack > 1 then
    -- clear error messages if any and open previous buffer
    vim.cmd("echo")
    vim.api.nvim_command('buffer ' .. buffer_stack[#buffer_stack - 1])
    return
  end
  vim.api.nvim_err_writeln("MARKNAV: Buffer history is empty")
end

-- Opens a link at the cursor location
function M.forward_jump()
  local current_line = vim.api.nvim_get_current_line()
  local match_list = PATHMGR.find_matches(current_line, FILE_PATH_PATTERN)
  local cursor_position = vim.api.nvim_win_get_cursor(0)[2]
  local file_path = PATHMGR.extract_at_cursor(match_list, cursor_position)
  -- ERROR HANDLING
  -- No matches found
  if #match_list == 0 then vim.api.nvim_err_writeln("MARKNAV: No links found on current line") return end
  -- Link not valid
  if not file_path then vim.api.nvim_err_writeln("MARKNAV: Cursor is not placed on valid link") return end
  -- expand to absolute path
  file_path = PATHMGR.expand(file_path)
  -- If path isn't valid --> return
  if not PATHMGR.extended_validate(file_path) then return end
  -- Clear error messages if any and open file
  vim.cmd("echo")
  vim.api.nvim_command('edit ' .. file_path)
end

-- open nth link on the current line
function M.jump_to_nth_link(n)
  -- Number isn't valid
  if type(n) ~= "number" or n <= 0 or n % 1 ~= 0 then vim.api.nvim_err_writeln("MARKNAV: Invalid link number. Please provide a positive integer") return end

  local current_line = vim.api.nvim_get_current_line()
  local match_list = PATHMGR.find_matches(current_line, FILE_PATH_PATTERN)
  -- ERROR HANDLING
  -- No matches found
  if #match_list == 0 then vim.api.nvim_err_writeln("MARKNAV: No links found on current line") return end
  -- Nth link not found
  if n > #match_list then vim.api.nvim_err_writeln("MARKNAV: Link number " .. n .. " not found on current line") return end
  -- get file_path and expand it to absolute path
  local file_path = match_list[n].str
  file_path = PATHMGR.expand(file_path)
  -- If path isn't valid --> return
  if not PATHMGR.extended_validate(file_path) then return end
  -- Clear error messages if any and open file
  vim.cmd("echo")
  vim.api.nvim_command('edit ' .. file_path)
end


-- Opens a link at the cursor location IN A NEW TAB
function M.tab_jump()
  local current_line = vim.api.nvim_get_current_line()
  local match_list = PATHMGR.find_matches(current_line, FILE_PATH_PATTERN)
  -- No matches found
  if #match_list == 0 then vim.api.nvim_err_writeln("MARKNAV: No links found on current line") return end

  local cursor_position = vim.api.nvim_win_get_cursor(0)[2]
  local file_path = PATHMGR.extract_at_cursor(match_list, cursor_position)
  -- Link not valid
  if not file_path then vim.api.nvim_err_writeln("MARKNAV: Cursor is not placed on valid link") return end
  -- expand to absolute path
  file_path = PATHMGR.expand(file_path)
  -- If path isn't valid --> return
  if not PATHMGR.validate(file_path) then return end
  -- Clear error messages if any and open file
  vim.cmd("echo")
  vim.api.nvim_command('tabnew ' .. file_path)
end


return M

