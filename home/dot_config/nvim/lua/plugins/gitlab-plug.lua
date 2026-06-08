require("diffview") -- We require some global state from diffview
require("gitlab").setup({
  port = nil, -- The port of the Go server, which runs in the background, if omitted or `nil` the port will be chosen automatically
  log_path = vim.fn.stdpath("cache") .. "/gitlab.nvim.log", -- Log path for the Go server
  config_path = nil, -- Custom path for `.gitlab.nvim` file, please read the "Connecting to Gitlab" section
  debug = {
      request = false, -- Requests to/from Go server
      response = false,
      gitlab_request = false, -- Requests to/from Gitlab
      gitlab_response = false,
  },
  attachment_dir = nil, -- The local directory for files (see the "summary" section)
  reviewer_settings = {
    jump_with_no_diagnostics = false, -- Jump to last position in discussion tree if true, otherwise stay in reviewer and show warning.
    diffview = {
      imply_local = false, -- If true, will attempt to use --imply_local option when calling |:DiffviewOpen|
    },
  },
  connection_settings = {
    insecure = false, -- Like curl's --insecure option, ignore bad x509 certificates on connection
    remote = "origin", -- The default remote that your MRs target
  },
  keymaps = {
    disable_all = false, -- Disable all mappings created by the plugin
    help = "g?", -- Open a help popup for local keymaps when a relevant view is focused (popup, discussion panel, etc)
    global = {
      disable_all = false, -- Disable all global mappings created by the plugin
      add_assignee = "glaa",
      delete_assignee = "glad",
      add_label = "glla",
      delete_label = "glld",
      add_reviewer = "glra",
      delete_reviewer = "glrd",
      approve = "glA", -- Approve MR
      revoke = "glR", -- Revoke MR approval
      merge = "glM", -- Merge the feature branch to the target branch and close MR
      create_mr = "glC", -- Create a new MR for currently checked-out feature branch
      choose_merge_request = "glc", -- Chose MR for review (if necessary check out the feature branch)
      start_review = "glS", -- Start review for the currently checked-out branch
      summary = "gls", -- Show the editable summary of the MR
      copy_mr_url = "glu", -- Copy the URL of the MR to the system clipboard
      open_in_browser = "glo", -- Openthe URL of the MR in the default Internet browser
      create_note = "gln", -- Create a note (comment not linked to a specific line)
      pipeline = "glp", -- Show the pipeline status
      toggle_discussions = "gld", -- Toggle the discussions window
      toggle_draft_mode = "glD", -- Toggle between draft mode (comments posted as drafts) and live mode (comments are posted immediately)
      publish_all_drafts = "glP", -- Publish all draft comments/notes
    },
    popup = {
      disable_all = false, -- Disable all default mappings for the popup windows (comments, summary, MR creation, etc.)
      next_field = "<Tab>", -- Cycle to the next field. Accepts |count|.
      prev_field = "<S-Tab>", -- Cycle to the previous field. Accepts |count|.
      perform_action = "ZZ", -- Once in normal mode, does action (like saving comment or applying description edit, etc)
      perform_linewise_action = "ZA", -- Once in normal mode, does the linewise action (see logs for this job, etc)
      discard_changes = "ZQ", -- Quit the popup discarding changes, the popup content is not saved to the `temp_registers` (see `:h gitlab.nvim.temp-registers`)
    },
    discussion_tree = {
      disable_all = false, -- Disable all default mappings for the discussion tree window
      add_emoji = "Ea", -- Add an emoji to the note/comment
      delete_emoji = "Ed", -- Remove an emoji from a note/comment
      delete_comment = "dd", -- Delete comment
      edit_comment = "e", -- Edit comment
      reply = "r", -- Reply to comment
      toggle_resolved = "-", -- Toggle the resolved status of the whole discussion
      jump_to_file = "o", -- Jump to comment location in file
      jump_to_reviewer = "a", -- Jump to the comment location in the reviewer window
      open_in_browser = "b", -- Jump to the URL of the current note/discussion
      copy_node_url = "u", -- Copy the URL of the current node to clipboard
      switch_view = "c", -- Toggle between the notes and discussions views
      toggle_tree_type = "i", -- Toggle type of discussion tree - "simple", or "by_file_name"
      publish_draft = "P", -- Publish the currently focused note/comment
      toggle_draft_mode = "D", -- Toggle between draft mode (comments posted as drafts) and live mode (comments are posted immediately)
      toggle_sort_method = "st", -- Toggle whether discussions are sorted by the "latest_reply", or by "original_comment", see `:h gitlab.nvim.toggle_sort_method`
      toggle_node = "t", -- Open or close the discussion
      toggle_all_discussions = "T", -- Open or close separately both resolved and unresolved discussions
      toggle_resolved_discussions = "R", -- Open or close all resolved discussions
      toggle_unresolved_discussions = "U", -- Open or close all unresolved discussions
      refresh_data = "<C-R>", -- Refresh the data in the view by hitting Gitlab's APIs again
      print_node = "<leader>p", -- Print the current node (for debugging)
    },
    reviewer = {
      disable_all = false, -- Disable all default mappings for the reviewer windows
      create_comment = "c", -- Create a comment for the lines that the following {motion} moves over. Repeat the key(s) for creating comment for the current line
      create_suggestion = "s", -- Create a suggestion for the lines that the following {motion} moves over. Repeat the key(s) for creating comment for the current line
      move_to_discussion_tree = "a", -- Jump to the comment in the discussion tree
    },
  },
  popup = { -- The popup for comment creation, editing, and replying
    width = "40%", -- Can be a percentage (string or decimal, "40%" = 0.4) of editor screen width, or an integer (number of columns)
    height = "60%", -- Can be a percentage (string or decimal, "60%" = 0.6) of editor screen width, or an integer (number of rows)
    position = "50%", -- Position (from the top left corner), either a number or percentage string that applies to both horizontal and vertical position, or a table that specifies them separately, e.g., { row = "90%", col = "100%" } places popups in the bottom right corner while leaving the status line visible
    border = "rounded", -- One of "rounded", "single", "double", "solid"
    opacity = 1.0, -- From 0.0 (fully transparent) to 1.0 (fully opaque)
    comment = nil, -- Individual popup overrides, e.g. { width = "60%", height = "80%", border = "single", opacity = 0.85 },
    edit = nil,
    note = nil,
    help = nil, -- Width and height are calculated automatically and cannot be overridden
    pipeline = nil, -- Width and height are calculated automatically and cannot be overridden
    reply = nil,
    squash_message = nil,
    create_mr = { width = "95%", height = "95%" },
    summary = { width = "95%", height = "95%" },
    temp_registers = {}, -- List of registers for backing up popup content (see `:h gitlab.nvim.temp-registers`)
  },
  discussion_tree = { -- The discussion tree that holds all comments
    expanders = { -- Discussion tree icons
      expanded = " ", -- Icon for expanded discussion thread
      collapsed = " ", -- Icon for collapsed discussion thread
      indentation = "  ", -- Indentation Icon
    },
    spinner_chars = { "/", "|", "\\", "-" }, -- Characters for the refresh animation
    auto_open = true, -- Automatically open when the reviewer is opened
    default_view = "discussions", -- Show "discussions" or "notes" by default
    blacklist = {}, -- List of usernames to remove from tree (bots, CI, etc)
    sort_by = "latest_reply", -- Sort discussion tree by the "latest_reply", or by "original_comment", see `:h gitlab.nvim.toggle_sort_method`
    keep_current_open = false, -- If true, current discussion stays open even if it should otherwise be closed when toggling
    position = "bottom", -- "top", "right", "bottom" or "left"
    size = "20%", -- Size of split
    relative = "editor", -- Position of tree split relative to "editor" or "window"
    resolved = '✓', -- Symbol to show next to resolved discussions
    unresolved = '-', -- Symbol to show next to unresolved discussions
    unlinked = "󰌸", -- Symbol to show next to unliked comments (i.e., not threads)
    draft = "✎", -- Symbol to show next to draft comments/notes
    tree_type = "simple", -- Type of discussion tree - "simple" means just list of discussions, "by_file_name" means file tree with discussions under file
    draft_mode = false, -- Whether comments are posted as drafts as part of a review
    winbar = nil, -- Custom function to return winbar title, should return a string. Provided with WinbarTable (defined in annotations.lua)
                 -- If using lualine, please add "gitlab" to disabled file types, otherwise you will not see the winbar.
  },
  emojis = {
    -- Function for modifying how emojis are displayed in the picker. This does not affect the actual selected emoji.
    -- The function is passed an emoji object as a paramter, e.g.,
    -- {"unicode": "1F44D","name": "thumbs up sign", "shortname": ":thumbsup:", "moji": "👍"}
    -- This is useful if your editor/terminal/font/tmux does not render some emojis properly,
    -- e.g., you can remove skin tones and additionally show the shortname with
    -- formatter = function(val)
    --   return string.format("%s %s %s", val.moji:gsub("[\240][\159][\143][\187-\191]", ""), val.shortname, val.name)
    -- end
    formatter = nil,
  },
  choose_merge_request = {
    open_reviewer = true, -- Open the reviewer window automatically after switching merge requests
  },
  info = { -- Show additional fields in the summary view
    enabled = true,
    horizontal = false, -- Display metadata to the left of the summary rather than underneath
    fields = { -- The fields listed here will be displayed, in whatever order you choose
      "author",
      "created_at",
      "updated_at",
      "merge_status",
      "draft",
      "conflicts",
      "assignees",
      "reviewers",
      "pipeline",
      "branch",
      "target_branch",
      "delete_branch",
      "squash",
      "labels",
      "web_url",
    },
  },
  discussion_signs = {
    enabled = true, -- Show diagnostics for gitlab comments in the reviewer
    skip_resolved_discussion = false, -- Show diagnostics for resolved discussions
    severity = vim.diagnostic.severity.INFO, -- ERROR, WARN, INFO, or HINT
    virtual_text = false, -- Whether to show the comment text inline as floating virtual text
    use_diagnostic_signs = true, -- Show diagnostic sign (depending on the `severity` setting, e.g., I for INFO) along with the comment icon
    priority = 100, -- Higher will override LSP warnings, etc
    icons = {
      comment = "→|",
      range = " |",
    },
    skip_old_revision_discussion = false, -- Don't show diagnostics for discussions that were created for earlier MR revisions
  },
  pipeline = {
    created = "",
    pending = "",
    preparing = "",
    scheduled = "",
    running = "",
    canceled = "↪",
    skipped = "↪",
    success = "✓",
    failed = "",
  },
  create_mr = {
    target = nil, -- Default branch to target when creating an MR
    template_file = nil, -- Default MR template in .gitlab/merge_request_templates
    delete_branch = false, -- Whether the source branch will be marked for deletion
    squash = false, -- Whether the commits will be marked for squashing
    fork = {
      enabled = false, -- If making an MR from a fork
      forked_project_id = nil, -- The ID of the project you are merging into. If nil, will be prompted.
    },
    title_input = { -- Default settings for MR title input window
      width = 40,
      border = "rounded",
    },
  },
  colors = {
    discussion_tree = {
      username = "Keyword",
      mention = "WarningMsg",
      date = "Comment",
      expander = "DiffviewNonText",
      directory = "Directory",
      directory_icon = "DiffviewFolderSign",
      file_name = "Normal",
      resolved = "DiagnosticSignOk",
      unresolved = "DiagnosticSignWarn",
      draft = "DiffviewNonText",
      draft_mode = "DiagnosticWarn",
      live_mode = "DiagnosticOk",
      sort_method = "Keyword",
    }
  }
})
