local dap, dapui = require("dap"), require("dapui")
local dap_python = require('dap-python')
local Job = require("plenary.job")
require('dap-go').setup()

--- Desktop: notify-send. Termux: termux-toast (termux-api).
local function notify(message, opts)
    opts = opts or {}
    local cmd, args
    if vim.fn.executable("termux-toast") == 1 then
        cmd, args = "termux-toast", { message }
    elseif vim.fn.executable("notify-send") == 1 then
        cmd, args = "notify-send", { message }
    else
        vim.notify(message, vim.log.levels.INFO)
        if opts.on_exit then
            opts.on_exit()
        end
        return
    end
    Job:new({
        command = cmd,
        args = args,
        on_exit = opts.on_exit,
    }):start()
end

-- require("nvim-dap-virtual-text").setup()
dap_python.setup()

-- https://github.com/jisantuc/nix-home/blob/255e21eda6cf15e5bf16e55712f2bd4eac63219e/dotfiles/neovim/ftplugin/python.lua#L4
dap_python.test_runner = "pytest_no_cov"
function dap_python.test_runners.pytest_no_cov(classname, methodname)
    local test_module, test_args = dap_python.test_runners.pytest(classname, methodname)
    test_args[#test_args + 1] = "--no-cov"
    return test_module, test_args
end

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
    command = os.getenv("HOME") .. "/.local/share/vscode-cpptools/extension/debugAdapters/bin/OpenDebugAD7",
}

local unreal_gdb_setup = {
    {
        description = "enable pretty printing",
        text = "-enable-pretty-printing",
        ignoreFailures = true,
    },
    {
        description = "load UE gdbinit",
        text = "source " .. (os.getenv("HOME") or "~") .. "/.gdbinit",
        ignoreFailures = true,
    },
}

local function unreal_editor_binary()
    local engine = vim.g.unreal_engine_path or vim.env.UE_ROOT
    if not engine or engine == "" then
        engine = vim.fn.input("Unreal Engine path: ", "", "path")
        if engine ~= "" then
            vim.g.unreal_engine_path = engine
        end
    end
    if not engine or engine == "" then
        return nil
    end
    return vim.fs.joinpath(engine, "Engine/Binaries/Linux/UnrealEditor")
end

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
    {
        name = "Launch UnrealEditor (project)",
        type = "cppdbg",
        request = "launch",
        program = unreal_editor_binary,
        args = function()
            local uproject
            if vim.g.unreal_uproject and vim.g.unreal_uproject ~= "" then
                uproject = vim.g.unreal_uproject
            else
                uproject = vim.fn.input("Path to .uproject: ", vim.fn.getcwd(), "file")
                if uproject ~= "" then
                    vim.g.unreal_uproject = uproject
                end
            end
            return { "-opengl", uproject }
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        MIMode = "gdb",
        miDebuggerPath = "/usr/bin/gdb",
        environment = {
            { "SDL_VIDEODRIVER", "x11" },
        },
        setupCommands = unreal_gdb_setup,
    },
    {
        name = "Attach to UnrealEditor",
        type = "cppdbg",
        request = "attach",
        processId = require("dap.utils").pick_process,
        MIMode = "gdb",
        miDebuggerPath = "/usr/bin/gdb",
        setupCommands = unreal_gdb_setup,
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
                "--user-data-dir=" .. os.getenv("HOME") .. "/.config/chromium-remote",
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
    dap.continue()
end

local function pytest_coverage()
    local test = Job:new({
        command = "pdm",
        args = { "run", "test" },
        on_exit = function()
            notify("Coverage done...")
        end,
    })

    notify("Coverage started...", { on_exit = function() test:start() end })
end

-- dap
vim.keymap.set("n", "<leader>B", ":PBToggleBreakpoint<cr>", { silent = true })
vim.keymap.set("n", "<leader>c", continue, { nowait = true })
vim.keymap.set("n", "<leader>s", dap.step_into, { nowait = true })
vim.keymap.set("n", "<leader><leader>D", dap.disconnect, { nowait = true })
vim.keymap.set("n", "<leader><leader>d", dapui.toggle)
vim.keymap.set("n", "<leader>t", dap_python.test_method, { nowait = true })
vim.keymap.set("n", "<leader>T", dap_python.test_class, { nowait = true })

local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local input = Input({
  position = "50%",
  size = {
    width = 40,
  },
  border = {
    style = "single",
    text = {
      top = "[Conditional Breakpoint]",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal,FloatBorder:Normal",
  },
}, {
  prompt = "> ",
  default_value = "",
  on_submit = function(value)
    require('dap').toggle_breakpoint(value)
  end,
})

vim.keymap.set("n", "<leader><leader>B", function() input:mount() end, { silent = true })

-- unmount component when cursor leaves buffer
input:on(event.BufLeave, function()
  input:unmount()
end)
