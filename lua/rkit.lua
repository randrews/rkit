RKit.set_title("RKit Demo")

ts = RKit.load_tilesheet("img/Tahin-font.png", 16, 16)
floor = RKit.load_bitmap("img/floor.png")

-- RKit.draw_bitmap(floor, 0, 0)

-- RKit.set_input_handler()
--     Takes a function that is called whenever a key is pressed or released.
--     The function takes two args: the first in the key name (like what readkey gives)
--     The second is true for a key being pressed, false for released.

-- RKit.set_input_handler(function(key, pressed)
-- 						  print(key, pressed)
-- 						  if key == "ESC" then RKit.set_input_handler(nil) end
-- 					   end)

RKit.set_redraw_handler(function(rect)
						   RKit.clear_screen(RKit.color(128,128,0))

						   RKit.draw_bitmap(floor, 30, 50, 0, 0, 100, 100)

						   RKit.draw_glyph(ts, "=", 50, 50)
						   RKit.draw_glyph(ts, 65, 70, 50, RKit.color(255, 0, 0), RKit.color(100, 0, 0))
						end)

RKit.set_input_handler(print)

tim = nil
count = 0
tim = RKit.create_timer(function()
						   count = count + 1

						   if count > 5 then
							  RKit.stop_timer(tim)
						   else
							  print("Hi", count)
						   end
						end,
						0.1)

RKit.resizable(false)
RKit.resize(640, 480, 200, 200)
