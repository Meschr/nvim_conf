-- GitHub Copilot inline suggestions (ghost text).
-- First use: run :Copilot auth and log in with your GitHub account.
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			-- standalone language server binary, so no Node.js >= 22 is needed
			server = { type = "binary" },
			suggestion = {
				enabled = true,
				auto_trigger = true, -- show suggestions while typing
				keymap = {
					accept = false, -- <Tab> is mapped below so it still indents when there is no suggestion
					accept_word = "<M-w>",
					accept_line = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				yaml = true,
				gitcommit = true,
			},
		})

		local suggestion = require("copilot.suggestion")

		-- <Tab>: accept Copilot suggestion if one is shown, otherwise a normal tab
		vim.keymap.set("i", "<Tab>", function()
			if suggestion.is_visible() then
				suggestion.accept()
			else
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
			end
		end, { desc = "Accept Copilot suggestion" })

		vim.keymap.set("n", "<leader>ct", function()
			suggestion.toggle_auto_trigger()
		end, { desc = "Toggle Copilot auto suggestions" })

		-- hide ghost text while the nvim-cmp menu is open so the two don't overlap
		local ok, cmp = pcall(require, "cmp")
		if ok then
			cmp.event:on("menu_opened", function()
				vim.b.copilot_suggestion_hidden = true
			end)
			cmp.event:on("menu_closed", function()
				vim.b.copilot_suggestion_hidden = false
			end)
		end
	end,
}
