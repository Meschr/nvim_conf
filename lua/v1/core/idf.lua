-- ESP-IDF: run idf.py for the current project in a terminal split at the bottom

local IDF_DEFAULT_VERSION = "v6.1" -- used when nvim was not started from a `get_idf` shell
local idf_buf = nil

-- project root = first directory upwards whose CMakeLists.txt contains project(...)
local function project_root()
	local start = vim.api.nvim_buf_get_name(0)
	start = start ~= "" and vim.fs.dirname(start) or vim.fn.getcwd()
	for dir in vim.fs.parents(start .. "/x") do
		local cmake = dir .. "/CMakeLists.txt"
		if vim.fn.filereadable(cmake) == 1 then
			for _, line in ipairs(vim.fn.readfile(cmake)) do
				if line:match("^%s*project%s*%(") then
					return dir
				end
			end
		end
	end
end

local function idf(args)
	local root = project_root()
	if not root then
		vim.notify("No ESP-IDF project found (no CMakeLists.txt with project())", vim.log.levels.ERROR)
		return
	end
	vim.cmd("silent! wall")

	-- idf.py is only a shell function after `get_idf`, so call it through the IDF python directly
	local cmd = 'python "$IDF_PATH/tools/idf.py" ' .. args
	if not vim.env.IDF_PATH then
		local activate = vim.fn.expand("~/.espressif/tools/activate_idf_" .. IDF_DEFAULT_VERSION .. ".sh")
		cmd = ". " .. vim.fn.shellescape(activate) .. " >/dev/null && " .. cmd
	end

	-- reuse one terminal: close the previous idf.py run
	if idf_buf and vim.api.nvim_buf_is_valid(idf_buf) then
		vim.api.nvim_buf_delete(idf_buf, { force = true })
	end
	vim.cmd("botright 15new")
	idf_buf = vim.api.nvim_get_current_buf()
	vim.fn.jobstart({ "bash", "-c", cmd }, { term = true, cwd = root })
	vim.cmd("startinsert")
end

local keymap = vim.keymap
keymap.set("n", "<leader>ib", function() idf("build") end, { desc = "ESP-IDF build" })
keymap.set("n", "<leader>if", function() idf("flash") end, { desc = "ESP-IDF flash" })
keymap.set("n", "<leader>im", function() idf("monitor") end, { desc = "ESP-IDF monitor (exit: Ctrl+])" })
keymap.set("n", "<leader>ia", function() idf("build flash monitor") end, { desc = "ESP-IDF build, flash & monitor" })
keymap.set("n", "<leader>ic", function() idf("menuconfig") end, { desc = "ESP-IDF menuconfig" })
keymap.set("n", "<leader>ix", function() idf("fullclean") end, { desc = "ESP-IDF fullclean" })
