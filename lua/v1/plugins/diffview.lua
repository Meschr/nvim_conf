return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff all changes (diffview)" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "History of current file" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "History of repo" },
		{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
	},
	opts = {
		enhanced_diff_hl = true, -- better highlighting of changed words
	},
}
