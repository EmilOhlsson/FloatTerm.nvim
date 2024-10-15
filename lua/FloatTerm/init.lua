local M = {}

local window = nil

-- Create a terminal window
--
-- Set up the window with buffer, terminal, and sets size
local function create_window()
    local w_width = vim.api.nvim_win_get_width(0)
    local w_height = vim.api.nvim_win_get_height(0)
    local buffer = vim.api.nvim_create_buf(false, true)

    --[[ TODO: We would like to be able to pass these
    --         as parameters ]]
                                --
    local v_pad = 5
    local h_pad = 10
    window = vim.api.nvim_open_win(buffer, true, {
        relative = 'win',
        row = v_pad,
        col = h_pad,
        width = w_width - 2 * h_pad,
        height = w_height - 2 * v_pad,
        border = 'shadow',
        -- A lot of cool config available, like shadow etc
    })

    local scope = { scope = 'local', win = window }
    vim.api.nvim_set_option_value('relativenumber', false, scope)
    vim.api.nvim_set_option_value('number', false, scope)
    vim.api.nvim_set_option_value('signcolumn', 'no', scope)
    vim.api.nvim_set_option_value('cursorline', false, scope)

    local _ = vim.fn.termopen(vim.env.SHELL or '/bin/sh', {
        ---@param job_id integer    Job ID that exited
        ---@param exit_code integer Terminal exit code
        ---@param event_type string The string "exit"
        ---@diagnostic disable-next-line: unused-local
        on_exit = function(job_id, exit_code, event_type)
            vim.api.nvim_win_close(window, false)
            window = nil
        end,
    })
end

local function toggle_window()
    assert(window ~= nil)
    local config = vim.api.nvim_win_get_config(window)

    vim.api.nvim_win_set_config(window, {
        hide = not config.hide
    })
    if not config.hide then
        vim.api.nvim_win_set_config(window, {
            -- TODO: Mark as active
        })
    end
end

---@param config any Setup arguments from vim script
---@diagnostic disable-next-line: unused-local
function M.setup(config)
    --[[ TODO: Could take window configuration, and use to
    --         extend the window creation parameters. This
    --         would allow user to configure borders and
    --         other stylistic options. Other useful options
    --         would be to pass padding, as to control size
    --         of terminal ]]
                              --
    vim.api.nvim_create_user_command('FloatTerm',
        function(_)
            if window == nil then
                create_window()
            else
                toggle_window()
            end
        end, {
        })
end

return M

-- vim: set et ts=4 sw=4 ss=4 tw=100:
