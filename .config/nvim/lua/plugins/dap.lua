local dap, dapui = require("dap"), require("dapui")

require("nvim-dap-virtual-text").setup()

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
            type = "pwa-node",
            name = "Debug Attach to Remote",
            request = "attach",
            port = 9229,
            autoAttachChildProcesses = true,
            sourceMaps = true,
            cwd = "${workspaceFolder}",
        },
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
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

dapui.setup({})

-- dap
vim.keymap.set("n", "<leader>B", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>c", dap.continue, { nowait = true })
vim.keymap.set("n", "<leader><leader>d", dapui.toggle)
