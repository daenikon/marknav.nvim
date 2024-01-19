local M = {}

-- Stack to keep track of buffer history
local buffer_stack = {}

-- Function to push a buffer onto the stack
local function push_buffer(bufnr)
    table.insert(buffer_stack, bufnr)
end

-- Function to pop a buffer from the stack and switch to it
local function pop_and_go_to_buffer()
    if #buffer_stack > 0 then
        local last_bufnr = table.remove(buffer_stack)
        vim.api.nvim_command('buffer ' .. last_bufnr)
    end
end


-- Function to check if the cursor is on line with relative link and open the link
function M.check_cursor_on_link()
    local current_line = vim.api.nvim_get_current_line()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1

    -- Check if the cursor is on a Markdown link (basic pattern matching)
    local link_start, link_end, link_path = string.find(current_line, '%[[^%]]+%]%(([^%)%]]*)%)')
    if link_path and cursor_col >= link_start and cursor_col <= link_end then
        push_buffer(vim.api.nvim_get_current_buf())

        -- Get the directory of the current file
        local current_file_dir = vim.fn.expand('%:p:h')

        -- Resolve the absolute path of the link
        local absolute_link_path = current_file_dir .. '/' .. link_path

        -- Open the file at the resolved path
        vim.api.nvim_command('edit ' .. absolute_link_path)
    end
end

-- Function to go to the previous buffer in the stack
function M.go_to_previous_buffer()
    pop_and_go_to_buffer()
end

-- Set up commands for Markdown file navigation
function M.setup()
    vim.api.nvim_create_user_command(
        'MarkLinkNext',
        M.check_cursor_on_link,
        {nargs = 0}
    )
    vim.api.nvim_create_user_command(
        'MarkLinkPrevious',
        M.go_to_previous_buffer,
        {nargs = 0}
    )
end

return M

