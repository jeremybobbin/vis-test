describe("new file", function()
	local win = nil
	local file = nil

	vis.events.subscribe(vis.events.WIN_OPEN, function(w)
		win = w
	end)

	vis.events.subscribe(vis.events.FILE_OPEN, function(f)
		file = f
	end)

	vis:command("e ./NEW_FILE")

	it("window has corresponding file", function()
		assert.are.same(file, win.file)
	end)

	it("has correct name", function()
		assert.are.equal("NEW_FILE", file.name)
	end)

	it("has correct path", function()
		assert.are.equal(os.getenv("PWD").."/NEW_FILE", file.path)
	end)
end)

