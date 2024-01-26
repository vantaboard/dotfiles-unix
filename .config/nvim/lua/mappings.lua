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

-- local function jump(forward)
--     local buf_cur = vim.api.nvim_get_current_buf()
--     local jumplist = vim.fn.getjumplist()
-- 
--     if jumplist == nil or #jumplist == 0 then
--         return
--     end
-- 
--     local jumps = jumplist[1]
--     local idx_cur = jumplist[2] + 1
-- 
--     print(vim.inspect(jumps))
--     print(idx_cur)
--     local function is_target(buf)
--         return buf ~= buf_cur and vim.api.nvim_buf_is_loaded(buf)
--     end
-- 
--     if forward then
--         for i = 1, #jumps - idx_cur do
--             if is_target(jumps[idx_cur + i].bufnr) then
--                 return i .. "<C-I>"
--             end
--         end
--     else
--         for i = 1, idx_cur - 1 do
--             if is_target(jumps[idx_cur - i].bufnr) then
--                 return i .. "<C-O>"
--             end
--         end
--     end
-- end
-- 
-- vim.keymap.set("n", "g<C-O>", function()
--     return jump(false)
-- end, { expr = true })
-- vim.keymap.set("n", "g<C-I>", function()
--     return jump(true)
-- end, { expr = true })
