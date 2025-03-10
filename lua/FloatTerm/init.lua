local M = {}

local base_window_config = {}
local window = nil
local buffer = nil
local v_pad
local h_pad

--- Create a terminal window
---
--- Set up the window with buffer, terminal, and sets size
local function create_window()
    local spawn_terminal = false
    if buffer == nil then
        buffer = vim.api.nvim_create_buf(false, true)
        spawn_terminal = true
    end

    -- Window configuration values, these will be merged with
    -- user provided configuration
    local window_config = {
        relative = 'editor',
        row = v_pad,
        col = h_pad,
        width = vim.o.columns - 2 * h_pad,
        height = vim.o.lines - 2 * v_pad,
        style = 'minimal',
    }
    local actual_config = vim.tbl_deep_extend('force',
        base_window_config, window_config);
    window = vim.api.nvim_open_win(buffer, true, actual_config)

    -- Configure created window
    vim.api.nvim_create_autocmd("WinClosed", {
        buffer = buffer,
        callback = function()
            window = nil
        end,
    })

    if spawn_terminal then
        -- Spawn terminal in current buffer
        local _ = vim.fn.termopen(vim.o.shell or '/bin/sh', {
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

--- Toggle the floating terminal window
---
--- If the window is currently visible, it will be closed.
--- If the window is not visible, it will be created and shown.
--- The terminal buffer is preserved between toggles, allowing you
--- to maintain your terminal session state.
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

--- Setup FloatTerm
---
---@param config table|nil Setup arguments, with following fields
--- - pad_vertical: number|nil - vertical padding
--- - pad_horizontal: number|nil - horizontal padding
--- - window_config: table|nil - see nvim_open_win
function M.setup(config)
    config = config or {}

    vim.validate({
        config = { config, 'table' },
        pad_vertical = { config.pad_vertical, 'number', true },
        pad_horizontal = { config.pad_horizontal, 'number', true},
        window_config = { config.window_config, 'table', true},
    })

    v_pad = tonumber(config.pad_vertical) or 5
    h_pad = tonumber(config.pad_horizontal) or 10

    -- Setup base config used when creating window
    base_window_config = vim.tbl_deep_extend('force', {
            border = 'shadow',
            style = 'minimal',
            title = 'FloatTerm',
            title_pos = 'left',
        },
        config.window_config or {})

    -- Create the actual user command
    vim.api.nvim_create_user_command('FloatTerm',
    function(_)
        M.toggle_window()
    end, {
    desc = "Toggle floating terminal window",
})
end

return M

-- vim: set et ts=4 sw=4 ss=4 tw=100:
