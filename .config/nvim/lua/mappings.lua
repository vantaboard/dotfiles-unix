-- lua/mappings.lua

local Job = require("plenary.job")

local function clipboard_job(url)
    return Job:new({
        command = "xclip",
        args = { "-selection", "clipboard" },
        writer = url,
    })
end

-- function that starts a pull request
local function pr(clipboard)
    local function branch_job(url)
        return Job:new({
            command = "git",
            args = { "rev-parse", "--abbrev-ref", "HEAD" },
            on_stdout = function(_, branch)
                url = url:gsub(":", "/")
                url = url:gsub("git@", "https://")
                url = url:gsub("%.git", "/compare/" .. branch .. "?expand=1")
                url = url:gsub("\n", "")

                print(url)

                if clipboard then
                    clipboard_job(url):start()
                end
            end,
        })
    end

    local git_url_job = Job:new({
        command = "git",
        args = { "remote", "get-url", "origin" },
        on_stdout = function(_, url)
            branch_job(url):start()
        end,
    })

    local git_pr = Job:new({
        command = "gh",
        args = { "pr", "view", "--json", "url" },
        on_stdout = function(_, url)
            url = url:gsub('^{"url":"', ""):gsub('"}$', "")
            print(url)

            if clipboard then
                clipboard_job(url):start()
            end
        end,
        on_stderr = function()
            git_url_job:start()
        end,
    })
    git_pr:sync()

    local git_pr_result = git_pr:result()

    if next(git_pr_result) == nil then
        return
    end

    local pr_number = git_pr_result[1]:match("([^/]+)$"):gsub('"}', "")
    vim.cmd("Octo pr edit " .. pr_number)
end

-- https://gitlab.com/jrop/dotfiles/-/blob/master/.config/nvim/lua/my/utils.lua#L13
local function buf_vtext()
    local a_orig = vim.fn.getreg("a")
    local mode = vim.fn.mode()
    if mode ~= "v" and mode ~= "V" then
        vim.cmd([[normal! gv]])
    end
    vim.cmd([[silent! normal! "aygv]])
    local text = vim.fn.getreg("a")
    vim.fn.setreg("a", a_orig)
    return text
end

local function copy_commit()
    local hash = buf_vtext()

    Job:new({
        command = "git",
        args = { "remote", "get-url", "origin" },
        on_stdout = function(_, url)
            print(url)
            url = url:gsub(":", "/")
            url = url:gsub("git@", "https://")
            url = url:gsub("%.git", "/commit/")
            url = url:gsub("\n", "")
            url = url .. hash

            print(url)

            clipboard_job(url):start()
        end,
    }):start()
end

local function reverse_lines_in_range(start_line, end_line)
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local n = #lines
    for i = 1, math.floor(n / 2) do
        lines[i], lines[n - i + 1] = lines[n - i + 1], lines[i]
    end
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

local function reverse_first_column_in_range(start_line, end_line)
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local n = #lines
    local firsts = {}
    local rests = {}
    for i = 1, n do
        local line = lines[i]
        if line == "" then
            firsts[i] = ""
            rests[i] = ""
        else
            firsts[i] = vim.fn.strcharpart(line, 0, 1)
            rests[i] = vim.fn.strcharpart(line, 1)
        end
    end
    for i = 1, math.floor(n / 2) do
        firsts[i], firsts[n - i + 1] = firsts[n - i + 1], firsts[i]
    end
    for i = 1, n do
        lines[i] = firsts[i] .. rests[i]
    end
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- <leader>r: reverse all lines (normal) or reverse selected lines in place (visual)
vim.keymap.set("n", "<leader>r", ":g/^/m0<cr>", { silent = true })
vim.keymap.set("x", "<leader>r", function()
    -- Use '< '> marks; line("v") is unreliable after visual exits for the mapping
    reverse_lines_in_range(vim.fn.line("'<"), vim.fn.line("'>"))
end, { silent = true })
-- <leader>R: reverse order of first character on each line (rest of line unchanged)
vim.keymap.set("n", "<leader>R", function()
    reverse_first_column_in_range(1, vim.fn.line("$"))
end, { silent = true })
vim.keymap.set("x", "<leader>R", function()
    reverse_first_column_in_range(vim.fn.line("'<"), vim.fn.line("'>"))
end, { silent = true })

vim.keymap.set("v", "<leader>c", copy_commit)

vim.keymap.set("n", "<leader>P", function()
    pr(true)
end)

-- camelcasemotion
vim.keymap.set("n", "<leader>w", "<Plug>CamelCaseMotion_w")
vim.keymap.set("n", "<leader>b", "<Plug>CamelCaseMotion_b")
vim.keymap.set("n", "<leader>e", "<Plug>CamelCaseMotion_e")
vim.keymap.set("n", "<leader>ge", "<Plug>CamelCaseMotion_ge")

-- pan up and down
vim.keymap.set("n", "<leader>j", "<C-E><C-E><C-E><C-E><C-E><C-E>")
vim.keymap.set("n", "<leader>k", "<C-Y><C-Y><C-Y><C-Y><C-Y><C-Y>")

-- retain cursor pos on visual yank: https://stackoverflow.com/questions/22923951/retaining-cursor-position-when-yanking
-- vim.keymap.set("v", "y", "mcy`c")

-- replace until with current yank
vim.keymap.set(
    "n",
    "<leader>f",
    ':execute("normal vt" . nr2char(getchar()) . "\\"_dP")<cr>'
)
vim.keymap.set(
    "n",
    "<leader>F",
    ':execute("normal vf" . nr2char(getchar()) . "\\"_dP")<cr>'
)

-- easy quit vim
vim.keymap.set("n", "Q", ":q!<cr>")

-- harpoon
vim.keymap.set("n", "<leader>H", require("harpoon.mark").add_file)
vim.keymap.set("n", "<leader>ch", require("harpoon.mark").clear_all)

-- copilot
vim.keymap.set("i", "<C-J>", "<Plug>(copilot-accept)")

-- leetcode
vim.keymap.set("n", "<leader>ll", ":LeetCodeList<cr>")
vim.keymap.set("n", "<leader>lt", ":LeetCodeTest<cr>")
vim.keymap.set("n", "<leader>ls", ":LeetCodeSubmit<cr>")
vim.keymap.set("n", "<leader>li", ":LeetCodeSignIn<cr>")

-- undotree
vim.keymap.set("n", "<leader>u", ":UndotreeToggle<cr>")

-- octo
vim.keymap.set("n", "<leader>o", ":Octo actions<cr>")


vim.api.nvim_set_keymap('i', '<F2>', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>mr", function () require"gitlab".choose_merge_request() end)
