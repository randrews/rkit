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

-- m = generate_map()

-- player_x, player_y = start_location(m)

k, s = getkey()

while k ~= "q" do
   print(k, s)
   k, s = getkey()
end