vim.cmd([[
let g:db_ui_use_nerd_fonts = 1
let g:db_adapter_bigquery_region = 'region-us'
let g:db_ui_save_location = '~/Code/bigquery/saved_queries'
let g:db_ui_tmp_query_location = '~/Code/bigquery/temp_queries'
let g:db_ui_execute_on_save = 0
]])

vim.cmd([[
let s:bigquery_schema_tables_query = printf("
      \ SELECT table_schema, table_name
      \ FROM `%s`.INFORMATION_SCHEMA.TABLES
      \ ", g:db_adapter_bigquery_region)
]])

local function replace_view_query()
    local view_name = vim.fn.expand("%:t:r")

    local parts = {}
    for p in string.gmatch(view_name, "([^" .. '".' .. "]+)") do
        table.insert(parts, p)
    end

    local project = parts[1]
    local dataset_view = string.format("%s.%s", parts[2], parts[3])

    local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    local query = table.concat(content, "\n")
    query = string.gsub(query, "'", "\\'")

    local cmd = string.format("bq mk \\\n --project_id \"%s\" \\\n --use_legacy_sql=false \\\n --view \\\n '%s' \\\n %s", project, query, dataset_view)

    print(cmd)

    local handle = io.popen(cmd)

    if handle ~= nil then
        local result = handle:read("*a")
        handle:close()

        print(result)
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

vim.api.nvim_create_user_command("ReplaceBQView", function(opts)
    replace_view_query(opts.args)
end, {})

vim.api.nvim_create_user_command("BQView", function(opts)
    get_view_query(opts.args)
end, {})

vim.cmd([[
autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
]])
