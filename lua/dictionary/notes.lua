---@class Note
---@field name string
---@field description string
local Note = {}
Note.__index = Note

---Create new note
---@param name string
---@param description string
---@return Note
function Note:create_note(name, description)
	return setmetatable({
		name = name,
		description = description,
	}, Note)
end

---Edit existing note
---@param name string
---@param description string
function Note:edit_note(name, description)
	self.name = name
	self.description = description
end

---@class NoteRegistry
---@field notes Note[]
local NoteRegistry = {}
NoteRegistry.__index = NoteRegistry

---Create a new NoteRegistry
---@return NoteRegistry
function NoteRegistry:new()
	return setmetatable({ notes = {} }, NoteRegistry)
end

---Add new note
---@param note Note
function NoteRegistry:add_note(note)
	table.insert(self.notes, note)
end

---Remove note
---@param note Note
function NoteRegistry:remove_note(note)
	for i, n in ipairs(self.notes) do
		if n == note then
			table.remove(self.notes, i)
		end
	end
end

return { Note = Note, NoteRegistry = NoteRegistry }
