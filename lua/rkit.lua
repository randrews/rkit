RKit.resizable(false)
RKit.resize(640, 480, 200, 200)
RKit.set_title("Matricks")

ts = RKit.load_tilesheet("img/matricks.png", 32)
floor = RKit.load_bitmap("img/floor.png")

left = (320 - 32*6) / 2
bottom = (480 - 32*6) / 2

RKit.set_redraw_handler(function()
						   RKit.draw_bitmap(floor, 0, 0)

						   draw_grid(src_grid, left, bottom)
						   draw_grid(dest_grid, left + 320, bottom)
						end)

RKit.redraw()

cursor = {x = 0, y = 5}
keys = { up = 126,
		 down = 125,
		 left = 123,
		 right = 124 }

mob = RKit.create_mob(left, bottom + 32*cursor.y, 32, 32,
					  function()
						 col = RKit.color(255, 64, 64)
						 RKit.draw_glyph(ts, 3, 0, 0, col, -1)
					  end)

RKit.set_input_handler(function(letter, key)
						  local oldcursor = { x = cursor.x, y = cursor.y }

						  if key == keys.up then cursor.y = cursor.y + 1
						  elseif key == keys.down then cursor.y = cursor.y - 1
						  elseif key == keys.left then cursor.x = cursor.x - 1
						  elseif key == keys.right then cursor.x = cursor.x + 1 end

						  if cursor.x < 0 then cursor.x = 0
						  elseif cursor.x > 5 then cursor.x = 5 end
						  if cursor.y < 0 then cursor.y = 0
						  elseif cursor.y > 5 then cursor.y = 5 end

						  move_cursor(oldcursor, cursor)
						  RKit.redraw()

						  RKit.move_mob(mob,
										left + 32 * cursor.x,
										bottom + 32 * cursor.y)
					   end)

math.randomseed(os.time())

src_grid = {}
dest_grid = {}

for n=1, 36 do
   src_grid[n] = math.random(3)
   dest_grid[n] = math.random(3)
end

function draw_grid(grid, left, top)
   for n, v in ipairs(grid) do
	  local x = (n - 1) % 6 * 32 + left
	  local y = math.floor((n - 1) / 6) * 32 + top

	  local cell = v - 1

	  RKit.draw_glyph(ts, cell, x, y, 0)
   end
end

function move_cursor(from, to)
   if from.x == to.x and from.y == to.y then return end
   local from_sq = src_grid[from.x + 6*from.y + 1]
   local to_sq = src_grid[to.x + 6*to.y + 1]
   if from_sq == to_sq then return end
   src_grid[to.x + 6*to.y + 1] = (6 - from_sq - to_sq)
end