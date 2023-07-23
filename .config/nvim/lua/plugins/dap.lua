local dap, dapui = require("dap"), require("dapui")

require("nvim-dap-virtual-text").setup()

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

require("dap-vscode-js").setup({
    debugger_path = "/home/blackboardd/Code/vscode-js-debug",
    adapters = { "pwa-node", "node-terminal", "pwa-extensionHost" },
})

for _, language in ipairs({ "typescript", "javascript" }) do
    dap.configurations[language] = {
        {
            name = "Debug Attach to Remote",
            type = "pwa-node",
            request = "attach",
            port = 9229,
            autoAttachChildProcesses = true,
            sourceMaps = true,
            cwd = "${workspaceFolder}",
        },
        {
            name = "Debug with Chrome",
            type = "chrome",
            request = "launch",
            protocol = "inspector",
            port = 9229,
            runtimeExecutable = "/usr/bin/chromium",
            runtimeArgs = {
                "--remote-debugging-port=9222",
                "--user-data-dir=/home/blackboardd/.config/chromium-remote",
                "http://localhost:3000",
            },
            sourceMaps = true,
            skipFiles = {
                "<node_internals>/**",
                "${workspaceFolder}/node_modules/**/*.js",
                "**/@vite/*",
            },
            webRoot = "${workspaceFolder}",
        },
        {
            name = "Debug with Firefox (attach)",
            type = "firefox",
            request = "attach",
            reAttach = true,
            url = "localhost:3000",
            resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
            },
            firefoxExecutable = "/usr/bin/firefox-nightly",
        },
    }
end

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

dapui.setup({})

-- dap
vim.keymap.set(
    "n",
    "<leader>B",
    dap.toggle_breakpoint
)
vim.keymap.set(
    "n",
    "<leader>c",
    dap.continue,
    { nowait = true }
)
vim.keymap.set(
    "n",
    "<leader><leader>d",
    dapui.toggle
)
