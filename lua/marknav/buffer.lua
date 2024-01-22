-- Buffer Logic
local M = {}

-- Push current buffer into window-scoped table
-- If JumpBack --> remove last element
function M.handle_stack()
  local current_buf = vim.api.nvim_get_current_buf()
  local temp_stack = vim.w.buffer_stack or {}

  if #temp_stack > 1 and current_buf == temp_stack[#temp_stack - 1] then
    table.remove(temp_stack)
  else
    table.insert(temp_stack, current_buf)
  end

  vim.w.buffer_stack = temp_stack
  -- print("Buffer stack: ", vim.inspect(vim.w.buffer_stack))
end

return M
