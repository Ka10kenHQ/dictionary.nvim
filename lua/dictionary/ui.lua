local plugin = require("dictionary.notes")
local M = {}

local default_opts = {
	save_path = vim.env.HOME .. "/my_notes.md",
	width_ratio = 0.7,
	height_ratio = 0.5,
	border = "rounded",
}

M.opts = {}
M.loaded_from_file = false
M.registry = plugin.NoteRegistry:new()
M.buf = nil
M.ns = vim.api.nvim_create_namespace("dictionary_notes")

vim.cmd("highlight NotesName guifg=#FFD700 guibg=NONE")
vim.cmd("highlight NotesDesc guifg=#87CEFA guibg=NONE")
vim.cmd("highlight NotesLine guifg=#FFFFFF guibg=NONE")

function M.setup(user_opts)
	M.opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})
end

local function format_note(note)
	return string.format("%-20s | %s", note.name, note.description)
end

local function header()
	local h = string.format("%-20s | %s", "Name", "Description")
	local sep = string.rep("-", 20) .. "-|-" .. string.rep("-", 50)
	return { h, sep }
end

local function parse_md(lines)
	local notes = {}
	for i, line in ipairs(lines) do
		if i <= 2 then
		elseif line:match("%S") then
			local name, desc = line:match("^%s*(.-)%s*|%s*(.-)%s*$")
			if name and desc then
				table.insert(notes, plugin.Note:create_note(name, desc))
			end
		end
	end
	return notes
end

local function save_to_file()
	if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
	M.registry.notes = parse_md(lines)

	local md_lines = header()
	for _, note in ipairs(M.registry.notes) do
		table.insert(md_lines, format_note(note))
	end

	local success = pcall(vim.fn.writefile, md_lines, M.opts.save_path, "b")
	if not success then
		vim.notify("Error: Failed to write to " .. M.opts.save_path .. ". Check permissions.", vim.log.levels.ERROR)
	end
end

local function lines_from_notes()
	local lines = header()
	for _, note in ipairs(M.registry.notes) do
		table.insert(lines, format_note(note))
	end
	return lines
end

local function refresh_highlights(buf)
	vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for i, line in ipairs(lines) do
		if i == 1 then
			vim.hl.range(buf, M.ns, "NotesName", { i - 1, 0 }, { i - 1, 20 }, { inclusive = false })
			vim.hl.range(buf, M.ns, "NotesDesc", { i - 1, 23 }, { i - 1, -1 }, { inclusive = false })
		else
			local name, desc = line:match("^%s*(.-)%s*|%s*(.-)%s*$")
			if name and desc then
				vim.hl.range(buf, M.ns, "NotesName", { i - 1, 0 }, { i - 1, #name }, { inclusive = false })
				vim.hl.range(buf, M.ns, "NotesDesc", { i - 1, #name + 3 }, { i - 1, -1 }, { inclusive = false })
			end
		end
	end
end

local function load_file_into_registry()
	if vim.fn.filereadable(M.opts.save_path) == 1 then
		local lines = vim.fn.readfile(M.opts.save_path)
		local file_notes = parse_md(lines)

		if not M.loaded_from_file then
			M.registry.notes = file_notes
			M.loaded_from_file = true
		else
			local existing_names = {}
			for _, note in ipairs(M.registry.notes) do
				existing_names[note.name] = true
			end

			for _, file_note in ipairs(file_notes) do
				if not existing_names[file_note.name] then
					M.registry:add_note(file_note)
				end
			end
		end
	else
		if not M.loaded_from_file then
			M.registry.notes = {}
			M.loaded_from_file = true
		end
	end
end

local function redraw_buffer()
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines_from_notes())
	refresh_highlights(M.buf)
end

local function buffer_to_registry()
	if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
	local notes = parse_md(lines)
	M.registry.notes = notes
end

function M:open_buffer()
	if not M.loaded_from_file then
		load_file_into_registry()
	end

	if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
		self.buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(self.buf, "NotesView")

		vim.bo[self.buf].swapfile = false
		vim.bo[self.buf].modifiable = true
		vim.bo[self.buf].bufhidden = "wipe"
		vim.bo[self.buf].filetype = "notes"

		local width = math.floor(vim.o.columns * M.opts.width_ratio)
		local height = math.floor(vim.o.lines * M.opts.height_ratio)
		local row = math.floor((vim.o.lines - height) / 2)
		local col = math.floor((vim.o.columns - width) / 2)

		vim.api.nvim_open_win(self.buf, true, {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = M.opts.border,
		})

		vim.api.nvim_create_autocmd("BufWritePost", {
			buffer = self.buf,
			callback = function()
				buffer_to_registry()
				save_to_file()
				refresh_highlights(self.buf)
				vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines_from_notes())
				refresh_highlights(self.buf)
			end,
		})
	end

	redraw_buffer()
	refresh_highlights(self.buf)
end

function M:add_note(note)
	self.registry:add_note(note)
	save_to_file()
	redraw_buffer()
end

function M:create_note(name, description)
	description = description or ""
	local n = plugin.Note:create_note(name, description)
	self.registry:add_note(n)
	save_to_file()
	redraw_buffer()
end

return M
