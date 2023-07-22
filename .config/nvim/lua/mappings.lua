-- lua/mappings.lua

local Job = require("plenary.job")

-- function that starts a pull request
local function pr(clipboard)
    local function clipboard_job(url)
        return Job:new({
            command = "xclip",
            args = { "-selection", "clipboard" },
            writer = url,
        })
    end

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

vim.keymap.set("n", "<leader>p", function()
    pr(true)
end)

-- camelcasemotion
vim.keymap.set("n", "w", "<Plug>CamelCaseMotion_w")
vim.keymap.set("n", "b", "<Plug>CamelCaseMotion_b")
vim.keymap.set("n", "e", "<Plug>CamelCaseMotion_e")
vim.keymap.set("n", "ge", "<Plug>CamelCaseMotion_ge")

-- pan up and down
vim.keymap.set("n", "<leader>j", "<C-E><C-E><C-E><C-E><C-E><C-E>")
vim.keymap.set("n", "<leader>k", "<C-Y><C-Y><C-Y><C-Y><C-Y><C-Y>")

-- retain cursor pos on visual yank: https://stackoverflow.com/questions/22923951/retaining-cursor-position-when-yanking
vim.keymap.set("v", "y", "mcy`c")

-- replace without yanking
vim.keymap.set("n", "<leader><leader>p", '"_dp')
vim.keymap.set("n", "<leader>P", '"_dP')

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
