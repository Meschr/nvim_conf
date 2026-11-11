-- nvim-treesitter (main branch): only installs parsers/queries.
-- Highlighting comes from Neovim itself (vim.treesitter.start), indentation from
-- nvim-treesitter's indentexpr, incremental selection from Neovim's built-in `an`/`in`.
local parsers = {
	"json",
	"javascript",
	"typescript",
	"tsx",
	"yaml",
	"html",
	"css",
	"prisma",
	"markdown",
	"markdown_inline",
	"svelte",
	"graphql",
	"bash",
	"lua",
	"vim",
	"dockerfile",
	"gitignore",
	"query",
	"vimdoc",
	"c",
	"c_sharp",
	"cpp",
	"cmake",
	"bibtex",
	"java",
	"python",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- main branch does not support lazy-loading
	build = ":TSUpdate",
	dependencies = {
		{ "windwp/nvim-ts-autotag", opts = {} }, -- auto close / rename html tags
	},
	config = function()
		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
			callback = function(ev)
				-- start highlighting; silently skip filetypes without an installed parser
				if pcall(vim.treesitter.start, ev.buf) then
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- incremental selection (Neovim built-in: `an` = parent node, `in` = child node)
		vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Start incremental selection" })
		vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Expand selection to parent node" })
		vim.keymap.set("x", "<bs>", "in", { remap = true, desc = "Shrink selection to child node" })
	end,
}
