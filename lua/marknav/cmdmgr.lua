PATHMGR = require("marknav.pathmgr")
BUF = require("marknav.buffer")

local M = {}

local FILE_PATH_PATTERN = '%[[^%]]+%]%(([^%)%]]*)%)'

-- Jump to previous buffer unless stack is empty
function M.back_jump()
  local previous_buffer = BUF.get_previous_buffer()
  if previous_buffer ~= nil then
    -- Open previous buffer
    vim.api.nvim_command('buffer ' .. previous_buffer)
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
  -- Open file
  vim.api.nvim_command('edit ' .. file_path)
end

-- Jump to nth link
function M.input_jump()
  vim.ui.input({prompt = "Enter link number: "}, function(input)
    vim.cmd('echo ""')
    input = tonumber(input)
    -- Number isn't valid
    --if type(input) ~= "number" or input <= 0 or input % 1 ~= 0 then vim.api.nvim_err_writeln("MARKNAV: Invalid link number. Please provide a positive integer") return end
    if type(input) ~= "number" or input <= 0 or input % 1 ~= 0 then return end
    local current_line = vim.api.nvim_get_current_line()
    local match_list = PATHMGR.find_matches(current_line, FILE_PATH_PATTERN)
    -- ERROR HANDLING
    -- No matches found
    --if #match_list == 0 then vim.api.nvim_err_writeln("MARKNAV: No links found on current line") return end
    if #match_list == 0 then return end
    -- Nth link not found
    --if input > #match_list then vim.api.nvim_err_writeln("MARKNAV: Link number " .. input .. " not found on current line") return end
    if input > #match_list then return end
    -- get file_path and expand it to absolute path
    local file_path = match_list[input].str
    file_path = PATHMGR.expand(file_path)
    -- If path isn't valid --> return
    if not PATHMGR.extended_validate(file_path) then return end
    -- Open file
    vim.api.nvim_command('edit ' .. file_path)
  end)

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
  -- Open file
  vim.api.nvim_command('tabnew ' .. file_path)
end

return M

