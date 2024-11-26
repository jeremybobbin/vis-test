function read(path)
	local f = io.open(path, "r")
	if not f then
		vis:exit(1)
		return
	end
	local content = f:read("*all")
	f:close()
	return content

end

describe("writing", function()
	local file = vis.win.file

	local tmp = string.gsub(file.name, '%.in$', '.tmp')
	local input = file:content(0, file.size)
	local lines = file.lines

	vis:command(",x/^/")
	vis:command(":w! "..tmp)
	local first = read(tmp)

	vis:command(",x/^../")
	vis:command(":w! "..tmp)
	local expected = lines[1]:sub(1, 2) .. lines[2]:sub(1, 2) .. lines[3]:sub(1, 2) .. lines[4]:sub(1, 2)
	local second = read(tmp)

	vis:command("!/bin/rm -f "..tmp)

	it("with multiple (non-visual) cursors saves the whole file", function()
		assert.are.same(input, first)
	end)

	it("with multiple selections only saves the selections", function()
		assert.are.same(expected, second)
	end)

end)

