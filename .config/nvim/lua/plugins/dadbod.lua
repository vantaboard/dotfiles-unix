local Job = require("plenary.job")

vim.cmd([[
let g:db_ui_use_nerd_fonts = 1
let g:db_adapter_bigquery_region = 'region-us'
let g:db_ui_save_location = '~/Code/bigquery/saved_queries'
let g:db_ui_tmp_query_location = '~/Code/bigquery/temp_queries'
let g:db_ui_execute_on_save = 0
let g:db_ui_bind_param_pattern = '@\w\+'
]])

vim.cmd([[
let s:bigquery_schema_tables_query = printf("
      \ SELECT table_schema, table_name
      \ FROM `%s`.INFORMATION_SCHEMA.TABLES
      \ ", g:db_adapter_bigquery_region)
]])

local function replace_materialized_view_query(project_dataset, run_table_job)
    project_dataset = string.gsub(project_dataset, '"', '')

    local view_name = string.format("%s.%s", project_dataset, vim.fn.expand("%:t:r"))

    local parts = {}
    for p in string.gmatch(view_name, "([^" .. '".' .. "]+)") do
        table.insert(parts, p)
    end

    local project = parts[1]

    local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    local query = table.concat(content, "\n")
    query = string.gsub(query, "'", "\\'")

    local view_query = string.format("CREATE OR REPLACE MATERIALIZED VIEW `%s` AS (\n%s\n)", view_name, query)

    local view_job = Job:new({
        command = "bq",
        args = {
            "query",
            "--project_id", project,
            "--use_legacy_sql=false",
            view_query
        },
        on_stdout = function(_, out)
            print(out)
        end,
    })

    local table_query = string.format("CREATE OR REPLACE TABLE `%s_table` AS (\n%s\n)", view_name, query)

    local table_job = Job:new({
        command = "bq",
        args = {
            "query",
            "--project_id", project,
            "--use_legacy_sql=false",
            table_query
        },
        on_stdout = function(_, out)
            print(out)
        end,
    })

    view_job:start()

    if run_table_job then
        table_job:start()
    end
end

local function replace_view_query(project_dataset, run_table_job)
    project_dataset = string.gsub(project_dataset, '"', '')

    local view_name = string.format("%s.%s", project_dataset, vim.fn.expand("%:t:r"))

    local parts = {}
    for p in string.gmatch(view_name, "([^" .. '".' .. "]+)") do
        table.insert(parts, p)
    end

    local project = parts[1]

    local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    local query = table.concat(content, "\n")
    query = string.gsub(query, "'", "\\'")

    local view_query = string.format("CREATE OR REPLACE VIEW `%s` AS (\n%s\n)", view_name, query)

    local view_job = Job:new({
        command = "bq",
        args = {
            "query",
            "--project_id", project,
            "--use_legacy_sql=false",
            view_query
        },
        on_stdout = function(_, out)
            print(out)
        end,
    })

    local table_query = string.format("CREATE OR REPLACE TABLE `%s_table` AS (\n%s\n)", view_name, query)

    local table_job = Job:new({
        command = "bq",
        args = {
            "query",
            "--project_id", project,
            "--use_legacy_sql=false",
            table_query
        },
        on_stdout = function(_, out)
            print(out)
        end,
    })

    view_job:start()

    if run_table_job then
        table_job:start()
    end
end

local function get_view_query(view_name)
    local parts = {}
    for p in string.gmatch(view_name, "([^" .. '".' .. "]+)") do
        table.insert(parts, p)
    end

    local project = parts[1]
    local dataset_view = string.format("%s.%s", parts[2], parts[3])

    print("bq --project_id \"%s\"  show --format=prettyjson %s | jq -r .view.query | perl -pe 's/\r\n/\n/g'")
    local handle = io.popen(string.format(
        "bq --project_id \"%s\"  show --format=prettyjson %s | jq -r .view.query | perl -pe 's/\r\n/\n/g'", project,
        dataset_view))

    if handle ~= nil then
        local result = handle:read("*a")
        handle:close()

        vim.api.nvim_paste(result, true, -1)
    end
end

vim.api.nvim_create_user_command("ReplaceBQMaterializedView", function(opts)
    replace_materialized_view_query(opts.args)
end, {})

vim.api.nvim_create_user_command("ReplaceBQView", function(opts)
    replace_view_query(opts.args)
end, {})

vim.api.nvim_create_user_command("ReplaceBQViewTable", function(opts)
    replace_view_query(opts.args, true)
end, {})

vim.api.nvim_create_user_command("BQView", function(opts)
    get_view_query(opts.args)
end, {})

vim.cmd([[
autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
]])
