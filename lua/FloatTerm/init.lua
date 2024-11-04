local M = {}

local base_window_config = {}
local window = nil
local buffer = nil
local v_pad
local h_pad

-- Create a terminal window
--
-- Set up the window with buffer, terminal, and sets size
local function create_window()
    local spawn_terminal = false
    if buffer == nil then
        buffer = vim.api.nvim_create_buf(false, true)
        spawn_terminal = true
    end

    local window_config = {
        relative = 'editor',
        row = v_pad,
        col = h_pad,
        width = vim.o.columns - 2 * h_pad,
        height = vim.o.lines - 2 * v_pad,
        -- A lot of cool
        -- config available,
        -- like shadow etc
    }
    local actual_config = vim.tbl_deep_extend('force',
        base_window_config, window_config);
    window = vim.api.nvim_open_win(buffer, true, actual_config)

    -- Configure created window
    local scope = { scope = 'local', win = window }
    vim.api.nvim_set_option_value('relativenumber', false, scope)
    vim.api.nvim_set_option_value('number', false, scope)
    vim.api.nvim_set_option_value('signcolumn', 'no', scope)
    vim.api.nvim_set_option_value('cursorline', false, scope)

    if spawn_terminal then
        -- Spawn terminal in current buffer
        local _ = vim.fn.termopen(vim.env.SHELL or '/bin/sh', {
            ---@param job_id integer    Job ID that exited
            ---@param exit_code integer Terminal exit code
            ---@param event_type string The string "exit"
            ---@diagnostic disable-next-line: unused-local
            on_exit = function(job_id, exit_code, event_type)
                vim.api.nvim_win_close(window, false)
                window = nil
                buffer = nil
            end,
        })
    end
end

function M.toggle_window()
    -- Windows can't easily be moved between tab pages, so windows
    -- are toggled by closing, and recreated. The buffer contains
    -- the running terminal, which is re-used if it is still running
    if window ~= nil then
        vim.api.nvim_win_close(window, false)
        window = nil
    else
        create_window()
    end
end

---@param config any Setup arguments from vim script
function M.setup(config)
    config = config or {}
    local default_window_config = {
        border = 'shadow',
        title = 'FloatTerm',
        title_pos = 'left',
    }

    -- Setup base config used when creating window
    if config.window_config ~= nil then
        assert(type(config.window_config) == 'table',
            "Window config need to be a table")
        default_window_config = vim.tbl_deep_extend('force',
            default_window_config, config.window_config)
    end
    base_window_config = default_window_config

    v_pad = config.pad_vertical or 5
    h_pad = config.pad_horizontal or 10

    -- Create the actual user command
    vim.api.nvim_create_user_command('FloatTerm',
        function(_)
            M.toggle_window()
        end, {
        })
end

return M

-- vim: set et ts=4 sw=4 ss=4 tw=100:
