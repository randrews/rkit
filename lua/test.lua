RKit.resizable(false)
RKit.resize(640, 480, 200, 200)
RKit.set_title("Matricks")

floor = RKit.load_bitmap("floor")
ts = RKit.load_tilesheet("matricks", 32)

grid = {}

for n=1, 36 do
	grid[n] = math.random(3)
end

RKit.set_redraw_handler(function()
							RKit.draw_bitmap(floor, 0, 0)
							draw_grid(grid, 100, 100)
						end)

function draw_grid(grid, left, top)
   for n, v in ipairs(grid) do
	  local x = (n - 1) % 6 * 32 + left
	  local y = math.floor((n - 1) / 6) * 32 + top

	  local cell = v - 1

	  RKit.draw_glyph(ts, cell, x, y, 0)
   end
end

RKit.redraw()
