local dap, dapui = require("dap"), require("dapui")
local dap_python = require('dap-python')
require('dap.ext.vscode').load_launchjs(nil, { debugpy = { 'python' } })
local Job = require("plenary.job")
require('dap-go').setup()

-- require("nvim-dap-virtual-text").setup()
dap_python.setup()

-- https://github.com/jisantuc/nix-home/blob/255e21eda6cf15e5bf16e55712f2bd4eac63219e/dotfiles/neovim/ftplugin/python.lua#L4
dap_python.test_runner = "pytest_no_cov"
function dap_python.test_runners.pytest_no_cov(classname, methodname)
    local test_module, test_args = dap_python.test_runners.pytest(classname, methodname)
    test_args[#test_args + 1] = "--no-cov"
    return test_module, test_args
end

require('dap.ext.vscode').load_launchjs 'launch.json'

require('persistent-breakpoints').setup {
    load_breakpoints_event = { "BufReadPost" }
}

require("dap-vscode-js").setup({
    adapters = {
        "pwa-node",
        "pwa-chrome",
        "pwa-msedge",
        "node-terminal",
        "pwa-extensionHost",
    },
    log_console_level = false,
})

dap.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = "/home/blackboardd/Code/vscode-cpptools/debugAdapters/bin/OpenDebugAD7",
}

dap.configurations.python = {}

dap.configurations.cpp = {
    { --launch
        name = "Launch",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input(
                "Path to executable: "
                .. vim.fn.getcwd()
                .. "/"
                .. vim.fn.getcwd()
                .. "/file"
            )
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
        setupCommands = {
            {
                description = "enable pretty printing",
                text = "-enable-pretty-printing",
                ignoreFailures = false,
            },
        },
    },
}

dap.configurations.rust = {
    {
        name = "Debug",
        type = "rt_lldb",
        request = "launch",
        program = function()
            local path = vim.fn.input(
                "Path to executable " .. vim.fn.getcwd() .. " : "
            )

            if path:sub(1, 1) == "/" then
                path = path:sub(2)
            end

            return vim.fn.resolve(vim.fn.getcwd() .. "/" .. path)
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
            local args = vim.fn.input("Arguments: ")
            return vim.split(args, " ")
        end,
    },
}

dap.adapters.firefox = {
    type = "executable",
    command = "node",
    args = {
        os.getenv("HOME")
        .. "/Code/vscode-firefox-debug/dist/adapter.bundle.js",
    },
}

dap.adapters.chrome = {
    type = "executable",
    command = "node",
    args = {
        os.getenv("HOME") .. "/Code/vscode-chrome-debug/out/src/chromeDebug.js",
    },
}

for _, language in ipairs({
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
}) do
    dap.configurations[language] = {
        {
            type = "pwa-chrome",
            request = "launch",
            runtimeExecutable = "/usr/bin/chromium",
            runtimeArgs = {
                "--user-data-dir=/home/blackboardd/.config/chromium-remote",
            },
            name = "Launch: Chrome (9222)",
            url = "http://localhost:3000",
            sourceMaps = true,
            webRoot = "${workspaceFolder}/src",
            protocol = "inspector",
            port = 9222,
        },
    }


    -- loop over remote_ports and use debug_attach_to_remote
    for _, port in ipairs({
        "9229",
        "9230",
        "9231",
        "9232",
        "9233",
        "9234",
        "9235",
        "9236",
    }) do
        dap.configurations[language][#dap.configurations[language] + 1] = {
            type = "pwa-node",
            name = "Attach: Chrome (" .. port .. ")",
            request = "attach",
            port = port,
            autoAttachChildProcesses = true,
            sourceMaps = true,
            cwd = "${workspaceFolder}",
        }
    end
end

dapui.setup({})

-- https://github.com/mfussenegger/nvim-dap/issues/20
local continue = function()
    if vim.bo.filetype == "go" and dap.session() == nil then
        require('dap-go').debug_test()

        return
    end
    if vim.fn.filereadable('.vscode/launch.json') then
        require('dap.ext.vscode').load_launchjs(nil, { debugpy = { 'python' } })
    end
    dap.continue()
end

local function pytest_coverage()
    local cov_end = Job:new({
        command = "notify-send",
        args = { 'Coverage done...' },
    })

    local test = Job:new({
        command = "pdm",
        args = { "run", "test" },
        on_exit = function()
            cov_end:start()
        end
    })

    Job:new({
        command = "notify-send",
        args = { 'Coverage started...' },
        on_exit = function() test:start() end
    }):start()
end

-- dap
vim.keymap.set("n", "<leader>B", ":PBToggleBreakpoint<cr>", { silent = true })
vim.keymap.set("n", "<leader>c", continue, { nowait = true })
vim.keymap.set("n", "<leader><leader>s", dap.step_into, { nowait = true })
vim.keymap.set("n", "<leader><leader>D", dap.disconnect, { nowait = true })
vim.keymap.set("n", "<leader><leader>d", dapui.toggle)
vim.keymap.set("n", "<leader>t", dap_python.test_method, { nowait = true })
vim.keymap.set("n", "<leader>T", dap_python.test_class, { nowait = true })
vim.keymap.set("n", "<leader>C", pytest_coverage, { nowait = true })
