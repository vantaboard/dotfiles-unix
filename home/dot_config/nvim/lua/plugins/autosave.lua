local Job = require("plenary.job")

local function start_cmake_build()
    if vim.fn.executable("cmake") ~= 1 then
        return
    end
    Job:new({
        command = "cmake",
        args = { "--build", "." },
        cwd = vim.fn.getcwd(),
    }):start()
end

require("auto-save").setup({
    enabled = true,
    execution_message = {
        message = function()
            if vim.bo.filetype == "cpp" then
                start_cmake_build()
            end

            return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
        end,
        dim = 0.18,
        cleaning_interval = 0,
    },
    trigger_events = { "InsertLeave", "TextChanged" },
    condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")

        if
            fn.getbufvar(buf, "&modifiable") == 1
            and utils.not_in(fn.getbufvar(buf, "&filetype"), {})
        then
            return true
        end
        return false
    end,
    write_all_buffers = false,
    debounce_delay = 2000,
    callbacks = {
        enabling = nil,
        disabling = nil,
        before_asserting_save = nil,
        before_saving = nil,
        after_saving = nil,
    },
})
