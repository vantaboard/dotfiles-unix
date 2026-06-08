local spectre = require("spectre")
spectre.setup()

vim.keymap.set("n", "<leader>S", spectre.open)
vim.keymap.set("v", "<leader>s", spectre.open_visual)
