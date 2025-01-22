vim.g.mapleader = " "

local keymap = vim.keymap -- for concisness
 
keymap.set("i","jk","<Esc>", { desc = "Exit insert mode with jk" })  -- Set escap insert mode key
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment / decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab


-- Python
keymap.set("n", "<leader>r", ":w<CR>:!python3 %<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>rr", ":vsplit | terminal ipython<CR>i", { noremap = true, silent = true })

keymap.set("n", "<leader>rt", function()
  vim.cmd("w")  -- Save the current buffer
  vim.cmd("vsplit")  -- Open a vertical split
  vim.cmd("terminal ipython %")  -- Open IPython in terminal and run the current file
  vim.cmd("startinsert")  -- Start in insert mode to see IPython output immediately
end, { noremap = true, silent = true })
