RKit.resizable(false)
RKit.resize(640, 480, 200, 200)
RKit.set_title("RKit Demo")

-- RKit.load_tilesheet and RKit.load_bitmap
--     Load bitmaps either as a grid of n*n pixel tiles, or
--     as a simple bitmap.

ts = RKit.load_tilesheet("img/Tahin-font.png", 16, 16)
floor = RKit.load_bitmap("img/floor.png")

-- RKit.draw_bitmap(floor, 0, 0, 640, 480)

-- RKit.set_input_handler()
--     Takes a function that is called whenever a key is pressed or released.
--     The function takes two args: the first is the ASCII value of the key (if any)
--     The second is the key scancode

RKit.set_input_handler(print)

-- RKit.set_redraw_handler()
--     Takes a function that gets called every time the window should be redrawn.
--     The funtcion takes no args.
--     It gets a few things in can call though:
--     clear_screen fills the screen with a color (made with RKit.color)
--     draw_bitmap draws a bitmap on the window at given coords
--     draw_glyph draws a tile on the window from a loaded tilesheet

RKit.set_redraw_handler(function()
						   RKit.draw_bitmap(floor, 0, 0)

						   draw_grid(src_grid, 100, 160)
						   draw_grid(dest_grid, 420, 160)

						   -- RKit.draw_glyph(ts, "=", 50, 50)
						   -- RKit.draw_glyph(ts, 65, 70, 50, RKit.color(255, 0, 0), RKit.color(100, 0, 0))
						end)

-- RKit.redraw()
--     Tells the window to redraw at its earliest convenience.

RKit.redraw()

mob = RKit.create_mob()

-- RKit.create_timer()
--     Takes a function and a (float) number of seconds. Calls the function after
--     that long of a delay, repeatedly.
--     Returns a lightuserdata representing the timer, you should call
--     RKit.stop_timep(timer) on all timers to stop them before the end of the program
--     (or just whenever you're ready for them to stop).

RKit.create_timer(function() print("Hi") end, 2.0)

math.randomseed(os.time())

src_grid = {}
dest_grid = {}

for n=1, 36 do
   src_grid[n] = math.random(3)
   dest_grid[n] = math.random(3)
end

function draw_grid(grid, left, top)
   for n, v in ipairs(grid) do
	  local x = (n - 1) % 6 * 20 + left
	  local y = math.floor((n - 1) / 6) * 20 + top

	  local cell = "."
	  if v == 1 then cell = 176
	  elseif v == 2 then cell = 177
	  elseif v == 3 then cell = 219 end

	  RKit.draw_glyph(ts, cell, x, y, 0)
   end
end