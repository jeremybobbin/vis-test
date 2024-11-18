local events = {
	vis.events.FILE_OPEN,
	vis.events.WIN_OPEN,
	vis.events.WIN_HIGHLIGHT,
	vis.events.WIN_STATUS,
	"CUSTOM",
	vis.events.WIN_CLOSE,
	vis.events.FILE_CLOSE
}

describe("events", function()
	local queue = {}
	for i = #events, 1, -1 do
		vis.events.subscribe(events[i], function()
			queue[i] = events[i]
			return true
		end)
	end

	vis:command("e ./NEW_FILE")
	vis.events.emit("CUSTOM")
	vis.win:close(true)

	it("occur in the right order", function()
		for i, e in ipairs(events) do
			assert.are.equal(e, queue[i])
		end
	end)
end)

