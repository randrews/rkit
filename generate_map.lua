
function generate_forests(m, status)
   local m2 = Map.new(m:size())

   local SPREAD, DEATH, ITER, PROB = 3, 4, 4, 3

   status("Seeding forests")
   for x, y, c in m:each() do
      m2:set(x, y, c) -- Replace me with a clone function
      if c == "." and math.random(PROB)==1 then
	 m:set(x,y,"+")
      end
   end

   for k=1,ITER do
      status("Simulating forest growth")
      for x, y, c in m:each() do
	 if c=="+" and m:adjacent(x,y,"+") < DEATH then
	    m2:set(x,y,".")
	 elseif c == "." and m:adjacent(x,y,"+") > SPREAD then
	    m2:set(x,y,"+")
	 else
	    m2:set(x,y,c)
	 end
      end

      m2, m = m, m2
   end
end

function generate_river(map, start_x, start_y, status)
   status("Generating rivers")
   local w, h = map:size()

   local line1 = start_x > start_y -- Above a line diagonally downward
   local line2 = start_x <= (h - start_y) -- Above a line from the bottom left to top right

   if line1 and line2 then
      prob = "ews"
   elseif not line1 and line2 then
      prob = "nes"
   elseif not line1 and not line2 then
      prob = "new"
   elseif line1 and not line2 then
      prob = "nws"
   end

   local proximity = function(x,y)
			return (map:get(x, y) ~= "~" and
			     map:get(x, y) ~= "#" and
			  map:adjacent(x, y, "~") < 3)
		     end

   for x,y in map:randomwalk(start_x, start_y, proximity, prob) do
      if map:get(x,y) == "-" then break end
      map:set(x,y,"~")
      if map:edge(x, y) then break end
   end

   for x, y, c in map:each() do
      if c == "~" then map:set(x, y, "-") end
   end
end

function smooth_terrain(map, status)
   status("Adding noise to fractal")
   for x, y, c in map:each() do
      if (c == "-" or c == "#") and math.random(3) == 1 then
	 if map:adjacent(x, y, ".") > 0 then map:set(x, y, ".")
	 elseif map:adjacent(x, y, "-") > 0 then map:set(x, y, "-") end
      end
   end

   for n=1, 4 do
      status("Smoothing terrain features")
      for x, y, c in map:each() do
	 if map:adjacent(x, y, ".") > 4 then
	    map:set(x, y, ".")
	 elseif map:adjacent(x, y, "-") > 4 then
	    map:set(x, y, "-")
	 else
	    map:set(x, y, c)
	 end
      end
   end

   return map
end

function fractal_terrain(map, status)
   status("Drawing fractal terrain")
   local w, h = map:size()
   local r = w/64

   for y=0, r do
      for x=0, r do
	 local c = ("---...##"):random()
	 map:set(x*w/r-1, y*h/r-1, c)
	 map:set(x*w/r, y*h/r-1, c)
	 map:set(x*w/r-1, y*h/r, c)
	 map:set(x*w/r, y*h/r, c)
      end
   end

   local iter
   iter = function(x, y, w, h)
	     if w == 2 then return end
	     local c = "."

	     -- north
	     c = (map:get(x,y) .. map:get(x+w-1, y)):random()
	     map:set(x+w/2-1, y, c)
	     map:set(x+w/2, y, c)

	     -- south
	     c = (map:get(x,y+h-1) .. map:get(x+w-1, y+h-1)):random()
	     map:set(x+w/2-1, y+h-1, c)
	     map:set(x+w/2, y+h-1, c)

	     -- west
	     c = (map:get(x,y) .. map:get(x, y+h-1)):random()
	     map:set(x, y+h/2-1, c)
	     map:set(x, y+h/2, c)

	     -- east
	     c = (map:get(x+w-1,y) .. map:get(x+w-1, y+h-1)):random()
	     map:set(x+w-1, y+h/2-1, c)
	     map:set(x+w-1, y+h/2, c)

	     -- center
	     c = (map:get(x,y) .. map:get(x+w-1, y+h-1))
	     c = (c .. map:get(x, y+h-1) .. map:get(x+w-1, y)):random()
	     map:set(x+w/2-1, y+h/2-1, c)
	     map:set(x+w/2, y+h/2, c)

	     map:set(x+w/2-1, y+h/2, c)
	     map:set(x+w/2, y+h/2-1, c)

	     iter(x, y, w/2, h/2)
	     iter(x+w/2, y, w/2, h/2)
	     iter(x+w/2, y+h/2, w/2, h/2)
	     iter(x, y+h/2, w/2, h/2)
	  end

   for y=0, (r-1) do
      for x=0, (r-1) do
	 iter(x*w/r, y*h/r, w/r, h/r)
      end
   end
end

function place_towns(map, status)
   local w, h = map:size()
   local x, y

   for n=1, ((w/64)^2) do
      status("Placing towns")

      repeat
	 x, y = math.random(w)-1, math.random(h)-1
      until map:get(x, y) == "." and not map:edge(x, y) and map:adjacent(x, y, "#^")==0

      map:set(x, y, "^")

      repeat
	 x, y = math.random(w)-1, math.random(h)-1
      until map:get(x, y) == "#" and not map:edge(x, y) and map:adjacent(x, y, "#")==8

      map:set(x, y, "*")
   end
end

function place_roads(map, status)
   local town_x, town_y

   local neighbor_fn = map:neighbors()

   local neighbors = function(current)
			local ret = {}
			local cells = neighbor_fn(unpack(current))

			for i, cell in pairs(cells) do
			   local c = map:get(unpack(cell))
			   if c == "." or c == "^" or c == ":" then ret[cell] = 1 end
			end

			return ret
		     end

   local goal = function(cell)
		   local x, y = unpack(cell)
		   local c = map:get(x,y)
		   return (x ~= town_x or y ~= town_y) and (c == "^" or c == ":")
		end

   for start_x, start_y, c in map:each() do
      if c == "^" then
	 status("Navigating roads")
	 town_x, town_y = start_x, start_y

	 local path = search(neighbors, {start_x, start_y}, goal)

	 if path then
	    for k, cell in pairs(path) do
	       local x, y = unpack(cell)
	       if map:get(x, y) ~= "^" then map:set(x, y, ":") end
	    end
	    m:draw()
	 end
      end
   end
end

-- status_fn is a function that's called to report on the progress of making the
-- map, since it can take a little while
function generate_map(status_fn)
   -- If null is passed in, pass our guys a function that just ignores the string
   if not status_fn then
	  status_fn = function(str) end
   end

   step_num = 1
   m = Map.new(512, 512)
   fractal_terrain(m, status_fn)
   m = smooth_terrain(m, status_fn)

   local w, h = m:size()
   local rivers = (w/64) ^ 2

   for n=1,rivers do
      local x, y

      repeat
		 x, y = math.random(w)-1, math.random(h)-1
      until m:get(x, y) == "." and not m:edge(x, y)

      generate_river(m, x, y, status_fn)
   end

   generate_forests(m, status_fn)
   place_towns(m, status_fn)

   return m
end
