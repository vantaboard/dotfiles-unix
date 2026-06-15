-- lua/mappings.lua

local Job = require("plenary.job")

local function clipboard_job(url)
    local command = "xclip"
    local args = { "-selection", "clipboard" }
    if vim.fn.executable("termux-clipboard-set") == 1 then
        command = "termux-clipboard-set"
        args = {}
    end
    return Job:new({
        command = command,
        args = args,
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

local function reverse_utf8_str(s)
    if s == "" then
        return s
    end
    local n = vim.fn.strchars(s)
    local parts = {}
    for i = n - 1, 0, -1 do
        parts[#parts + 1] = vim.fn.strcharpart(s, i, 1)
    end
    return table.concat(parts)
end

-- Visual type and corners for getregion/getregionpos. During an |xmap| callback, |visualmode()|
-- is often still empty while |mode()| is still v/V/^V; use getpos('v') and getpos('.') then.
-- See |getregion()| example with getpos('v'), getpos('.'), and mode().
local function visual_type_and_corners()
    local m1 = vim.fn.mode():sub(1, 1)
    if m1 == "v" or m1 == "V" or m1 == "\22" then
        return m1, vim.fn.getpos("v"), vim.fn.getpos(".")
    end
    local vm = vim.fn.visualmode()
    if vm == "" then
        return nil, nil, nil
    end
    return vm, vim.fn.getpos("'<"), vim.fn.getpos("'>`")
end

-- Visual <leader>rr: linewise = reverse line order; charwise = reverse text on each line;
-- block (^V) = reverse vertically within each column (matches grid / column selections).
local function reverse_visual_selection()
    local vm, p1, p2 = visual_type_and_corners()
    if not vm or p1[2] == 0 or p2[2] == 0 then
        return
    end

    local sl, el = p1[2], p2[2]
    if sl > el then
        sl, el = el, sl
    end

    if vm == "V" then
        reverse_lines_in_range(sl, el)
        return
    end

    local region_opts = { type = vm }
    local lines = vim.fn.getregion(p1, p2, region_opts)
    if #lines == 0 then
        return
    end

    if vm == "v" then
        for i, line in ipairs(lines) do
            lines[i] = reverse_utf8_str(line)
        end
    elseif vm == "\22" then
        local grid = {}
        for r, line in ipairs(lines) do
            grid[r] = {}
            local n = vim.fn.strchars(line)
            for c = 0, n - 1 do
                grid[r][c + 1] = vim.fn.strcharpart(line, c, 1)
            end
        end
        local nrows = #grid
        local ncols = nrows > 0 and #grid[1] or 0
        for c = 1, ncols do
            for r = 1, math.floor(nrows / 2) do
                grid[r][c], grid[nrows - r + 1][c] = grid[nrows - r + 1][c], grid[r][c]
            end
        end
        for r = 1, nrows do
            lines[r] = table.concat(grid[r])
        end
    else
        return
    end

    local pos = vim.fn.getregionpos(p1, p2, region_opts)
    if vm == "\22" then
        -- Block: replace each row's slice; one span from first to last corner is not the rectangle.
        for i = 1, #lines do
            local sp = pos[i][1]
            local ep = pos[i][2]
            vim.api.nvim_buf_set_text(0, sp[2] - 1, sp[3] - 1, ep[2] - 1, ep[3], { lines[i] })
        end
        return
    end

    local start_pos = pos[1][1]
    local end_pos = pos[#pos][2]
    local sr = start_pos[2] - 1
    local sc = start_pos[3] - 1
    local er = end_pos[2] - 1
    local ec = end_pos[3]
    vim.api.nvim_buf_set_text(0, sr, sc, er, ec, lines)
end

-- <leader>rr: normal = reverse all lines; visual = reverse selected text (char/line/block)
-- (not <leader>r: nvim-tree refresh, LSP references)
vim.keymap.set("n", "<leader>rr", ":g/^/m0<cr>", { silent = true })
vim.keymap.set("x", "<leader>rr", function()
    reverse_visual_selection()
end, { silent = true })

-- Block visual (Ctrl-V): prepend unnamed register on each line (avoids `p` replacing the block).
-- Yank "/foo/" elsewhere, block-select the column, then <leader>p.
vim.keymap.set("x", "<leader>p", 'I<C-r>"<Esc>', { silent = true })

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
