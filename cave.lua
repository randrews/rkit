require("generate_map")
require("util")
require("search")

-- Find a good place to start the player off
function start_location(map)
   local w, h = map:size()
   local x = math.random(w/3) + w / 3
   local y = math.random(h/3) + h / 3

   while map:get(x, y) ~= "." do
	  x = math.random(w/3) + w / 3
	  y = math.random(h/3) + h / 3
   end

   return x, y
end

m = Savegame.load("test.cave")

if not m then
   m = generate_map()
   Savegame.save("test.cave", m)
end

player_x, player_y = start_location(m)

w = 31
h = 31
m:draw(player_x - (w-1)/2,
	   player_y - (h-1)/2,
	   w, h)

Drawing.draw_glyph("@",
			 (w-1)/2,
			 (h-1)/2)

getkey()

-- k, s = getkey()

-- while k ~= "q" do
--    print(k, s)
--    k, s = getkey()
-- end