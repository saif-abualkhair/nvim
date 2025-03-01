local M = {}

-- Updated commands table with terminal commands
local commands = {
    {
        text = ">git pull", -- What the user types
        command = "git pull" -- The command to execute (without 'terminal')
    },
    {
        text = ">ls", -- Another example command
        command = "ls"
    }
}

-- Track the currently selected suggestion
local selected_index = 1

-- Function to search in commands
local function search_in_commands(input)
    local matches = {}
    for _, cmd in ipairs(commands) do
        if cmd.text:find(input) then
            table.insert(matches, cmd.text)
        end
    end
    return matches
end

-- Function to search for files (placeholder for now)
local function search_for_file(input)
    return "The file you're looking for is: " .. input
end

-- Function to highlight the selected suggestion
local function highlight_selected(suggestions_buf, index)
    -- Clear previous highlights
    vim.api.nvim_buf_clear_namespace(suggestions_buf, -1, 0, -1)

    -- Highlight the selected line
    vim.api.nvim_buf_add_highlight(suggestions_buf, -1, "Visual", index - 1, 0, -1)
end

-- Function to show a toast notification
local function show_toast(message, level)
    vim.notify(message, level, { timeout = 2000 }) -- Show for 2 seconds
end

-- Function to run a command asynchronously without opening a buffer
local function run_command_async(command, callback)
    local handle = vim.fn.jobstart(command, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                callback(true) -- Success
            else
                callback(false) -- Failure
            end
        end
    })

    if handle <= 0 then
        callback(false) -- Handle jobstart failure
    end
end

-- Function to simulate a spinner for async tasks
local function run_with_spinner(command, callback)
    local spinner_frames = { "|", "/", "-", "\\" }
    local spinner_index = 1

    -- Show initial spinner
    local spinner_timer = vim.loop.new_timer()
    spinner_timer:start(0, 100, function()
        vim.schedule(function()
            vim.api.nvim_command('echo "' .. spinner_frames[spinner_index] .. ' Running command..."')
            spinner_index = (spinner_index % #spinner_frames) + 1
        end)
    end)

    -- Run the command asynchronously
    run_command_async(command, function(success)
        -- Stop the spinner
        spinner_timer:stop()
        spinner_timer:close()

        -- Notify completion
        if success then
            show_toast("Command executed successfully: " .. command, vim.log.levels.INFO)
        else
            show_toast("Command failed: " .. command, vim.log.levels.ERROR)
        end

        -- Call the callback
        callback()
    end)
end

function M.open_command_palette()
    -- Get terminal dimensions
    local width = vim.o.columns
    local height = vim.o.lines

    -- Create a floating window for input
    local input_buf = vim.api.nvim_create_buf(false, true)
    local input_win = vim.api.nvim_open_win(input_buf, true, {
        relative = 'editor',
        width = 50,
        height = 1,
        col = (width / 2) - 25, -- Center horizontally
        row = 1, -- Top of the screen
        style = 'minimal',
        border = 'single'
    })

    -- Create a floating window for suggestions
    local suggestions_buf = vim.api.nvim_create_buf(false, true)
    local suggestions_win = vim.api.nvim_open_win(suggestions_buf, false, {
        relative = 'editor',
        width = 50,
        height = 10,
        col = (width / 2) - 25, -- Center horizontally
        row = 3, -- Below the input window
        style = 'minimal',
        border = 'single'
    })

    -- Make the input buffer modifiable
    vim.bo[input_buf].modifiable = true

    -- Function to update suggestions based on input
    local function update_suggestions(input)
        local results = {}
        if input:sub(1, 1) == ">" then
            -- Search in commands
            results = search_in_commands(input)
        else
            -- Search for files (placeholder)
            results = {search_for_file(input)}
        end
        vim.api.nvim_buf_set_lines(suggestions_buf, 0, -1, false, results)

        -- Reset selected index when suggestions update
        selected_index = 1
        highlight_selected(suggestions_buf, selected_index)
    end

    -- Function to close both windows and return to normal mode
    local function close_windows()
        if vim.api.nvim_win_is_valid(input_win) then
            vim.api.nvim_win_close(input_win, true)
        end
        if vim.api.nvim_win_is_valid(suggestions_win) then
            vim.api.nvim_win_close(suggestions_win, true)
        end
        vim.cmd('stopinsert') -- Return to normal mode
    end

    -- Function to execute the selected command
    local function execute_selected()
        local suggestions = vim.api.nvim_buf_get_lines(suggestions_buf, 0, -1, false)
        if #suggestions > 0 then
            local selected = suggestions[selected_index]
            if selected:sub(1, 1) == ">" then
                -- Find the command to execute
                for _, cmd in ipairs(commands) do
                    if cmd.text == selected then
                        -- Run the command with a spinner (async)
                        run_with_spinner(cmd.command, function()
                            close_windows()
                        end)
                        break
                    end
                end
            else
                -- Handle file search (no spinner needed)
                print(search_for_file(selected))
                close_windows()
            end
        end
    end

    -- Bind 'q' to close both windows
    vim.api.nvim_buf_set_keymap(input_buf, 'n', 'q', '', {
        noremap = true,
        silent = true,
        callback = close_windows
    })

    -- Bind 'Esc' to close both windows
    vim.api.nvim_buf_set_keymap(input_buf, 'i', '<Esc>', '', {
        noremap = true,
        silent = true,
        callback = close_windows
    })

    -- Bind 'Enter' to execute the selected command
    vim.api.nvim_buf_set_keymap(input_buf, 'i', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = execute_selected
    })

    -- Bind arrow keys to navigate suggestions
    vim.api.nvim_buf_set_keymap(input_buf, 'i', '<Down>', '', {
        noremap = true,
        silent = true,
        callback = function()
            local suggestions = vim.api.nvim_buf_get_lines(suggestions_buf, 0, -1, false)
            if #suggestions > 0 then
                selected_index = math.min(selected_index + 1, #suggestions)
                highlight_selected(suggestions_buf, selected_index)
            end
        end
    })

    vim.api.nvim_buf_set_keymap(input_buf, 'i', '<Up>', '', {
        noremap = true,
        silent = true,
        callback = function()
            local suggestions = vim.api.nvim_buf_get_lines(suggestions_buf, 0, -1, false)
            if #suggestions > 0 then
                selected_index = math.max(selected_index - 1, 1)
                highlight_selected(suggestions_buf, selected_index)
            end
        end
    })

    -- Set up an autocmd to watch for changes in the input buffer
    vim.api.nvim_create_autocmd('TextChangedI', {
        buffer = input_buf,
        callback = function()
            local input = vim.api.nvim_get_current_line()
            update_suggestions(input)
        end
    })

    -- Set up an autocmd to close both windows if one is closed
    vim.api.nvim_create_autocmd('WinClosed', {
        pattern = tostring(input_win),
        callback = close_windows
    })
    vim.api.nvim_create_autocmd('WinClosed', {
        pattern = tostring(suggestions_win),
        callback = close_windows
    })

    -- Start insert mode in the input window
    vim.cmd('startinsert')
end

-- Keybinding to open the command palette
vim.keymap.set('n', '<Space><S-p>', function()
    require('custom_plugins.command_pallet').open_command_palette()
end, { noremap = true, silent = true })

return M
