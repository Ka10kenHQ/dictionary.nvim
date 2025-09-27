local plug = {}

plug.notes = require("dictionary.notes")
plug.ui = require("dictionary.ui")

plug.setup = function(user_opts)
	if plug.ui.setup then
		plug.ui.setup(user_opts)
	end

	vim.api.nvim_create_user_command("Notes", function()
		plug.ui:open_buffer()
	end, {})
end

return plug
