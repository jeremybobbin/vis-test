describe("vis:pipe(\"yes 2>/dev/null | head -n 5 | tr -d '\n'\")", function()
	status, out, err = vis:pipe("yes 2>/dev/null | head -n 5 | tr -d '\n'")
	it("gives 5 Y's", function()
		assert.are.equals("yyyyy", out)
	end)

	it("returns no error output", function()
		assert.are.equals(nil, err)
	end)
end)

describe("vis:pipe(\"exit 69\")", function()
	status, out, err = vis:pipe("exit 69")
	it("exits with code 69", function()
		assert.are.equal(69, status)
	end)
end)


describe("pipe(vis.win.file, the whole thing, \"grep ^D\")", function()
	file = vis.win.file
	local function all()
		return {start=0, finish=file.size}
	end

	status, out, err = vis:pipe(file, all(), "grep ^D")
	it("exits with code 0", function()
		assert.are.equal(0, status)
	end)

	it("returns no error output", function()
		assert.are.equals(nil, err)
	end)

	it("gives output", function()
		assert.are.equals("Delhi\nDhaka\n", out)
	end)
end)

describe("pipe(vis.win.file, the whole thing, \"grep ^X\")", function()
	file = vis.win.file
	local function all()
		return {start=0, finish=file.size}
	end

	status, out, err = vis:pipe(file, all(), "grep ^X")
	it("gives no output", function()
		assert.are.equals(nil, out)
	end)

	it("returns 1", function()
		assert.are.equals(status, 1)
	end)
end)
