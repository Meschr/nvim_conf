-- start Claude; when called from a file, @-mention that file once Claude is connected
local function start_claude()
	local file = vim.api.nvim_buf_get_name(0)
	local is_file = vim.bo.buftype == "" and file ~= "" and vim.fn.filereadable(file) == 1
	if is_file then
		vim.cmd("ClaudeCodeAdd %")
	else
		require("claudecode.terminal").open()
	end
end

-- jump between the Claude window and the code (starts / shows Claude if needed)
local function jump_claude_code()
	local claude_buf = require("claudecode.terminal").get_active_terminal_bufnr()
	local claude_win = claude_buf and vim.fn.bufwinid(claude_buf) or -1

	if claude_buf and vim.api.nvim_get_current_buf() == claude_buf then
		-- in Claude -> back to the window we came from
		vim.cmd("stopinsert")
		local prev = vim.fn.win_getid(vim.fn.winnr("#"))
		if prev ~= 0 and prev ~= claude_win then
			vim.api.nvim_set_current_win(prev)
		else
			vim.cmd("wincmd h")
		end
	elseif claude_win ~= -1 then
		-- Claude visible -> focus it and start typing
		vim.api.nvim_set_current_win(claude_win)
		vim.cmd("startinsert")
	elseif claude_buf then
		-- Claude running but hidden -> show it
		require("claudecode.terminal").open()
	else
		start_claude()
	end
end

return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" }, -- nicer terminal window
	config = true,
	keys = {
		{ "<leader>a", nil, desc = "AI/Claude Code" },
		{ "<A-a>", jump_claude_code, mode = { "n", "i", "t" }, desc = "Jump between Claude and code" },
		{
			"<leader>ac",
			function()
				if require("claudecode").is_claude_connected() then
					vim.cmd("ClaudeCode")
				else
					start_claude()
				end
			end,
			desc = "Toggle Claude (with current file as context)",
		},
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
		{ "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file", ft = { "NvimTree" } },
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
	},
}
