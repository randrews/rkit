ts = RKit.load_tilesheet("img/Tahin-font.tga", 16, 16)
floor = RKit.load_bitmap("img/floor.tga")

RKit.draw_bitmap(floor, 0, 0)
RKit.draw_glyph(ts, "=", 50, 50)
RKit.page_flip()
RKit.draw_glyph(ts, 65, 70, 50, RKit.color(255, 0, 0), RKit.color(100, 0, 0))

-- RKit.readkey()
--     Blocks until a key is pressed, returns the key name and the ASCII value (if any)
--     The key name is the same on all keyboards, and works for arrow keys, etc.
--     The ASCII letter only works for printable chars, and takes keyboard layout (Dvorak)
--     into account.

-- RKit.set_input_handler()
--     Takes a function that is called whenever a key is pressed or released.
--     The function takes two args: the first in the key name (like what readkey gives)
--     The second is true for a key being pressed, false for released.

run = true

RKit.set_input_handler(function(key, pressed)
						  print(key, pressed)
						  if key == "ESC" then run = false end
					   end)

RKit.timer_loop(500, function() print("Hi") ; return run end)