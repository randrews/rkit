mt = getmetatable(Map.new(1,1))

mt.edge = function(map, x, y)
	     local w, h = map:size()
	     return x == 0 or y == 0 or
		x >= w-1 or y >= h-1
	  end

mt.valid_function = function(map, spec)
		       if type(spec)=="function" then return spec
		       elseif type(spec)=="number" then
			  return function()
				    spec = spec - 1
				    return spec >= 0
				 end
		       elseif type(spec)=="string" then
			  return function(x, y)
				    return string.find(spec, map:get(x, y), 1, true)
				 end
		       else return nil end
		    end

mt.neighbor_function = function(map, spec)
		       if type(spec)=="function" then return spec
		       elseif type(spec)=="nil" or type(spec)=="boolean" then
			  return map:neighbors(spec)
		       elseif type(spec)=="string" then
			  return map:weighted_neighbors(spec)
		       else return nil end
		    end

mt.random_valid_neighbor = function(map, x, y, valid, neighbors)
			      if type(valid) ~= "function" then valid = map:valid_function(valid) end
			      if type(neighbors) ~= "function" then neighbors = map:neighbor_function(neighbors) end

			      local possible = neighbors(x, y)

			      while #possible > 0 do
				 local cell = table.remove( possible, math.random(#possible) )
				 if not valid or valid(unpack(cell)) then
				    return unpack(cell)
				 end
			      end

			      return nil
			   end

mt.neighbors = function(map, diag)
		  return function(x, y)
			    local a = {}

			    if map:inbounds(x-1, y) then table.insert(a, {x-1, y}) end
			    if map:inbounds(x+1, y) then table.insert(a, {x+1, y}) end
			    if map:inbounds(x, y-1) then table.insert(a, {x, y-1}) end
			    if map:inbounds(x, y+1) then table.insert(a, {x, y+1}) end

			    if diag then
			       if map:inbounds(x-1, y-1) then table.insert(a, {x-1, y-1}) end
			       if map:inbounds(x+1, y+1) then table.insert(a, {x+1, y+1}) end
			       if map:inbounds(x+1, y-1) then table.insert(a, {x+1, y-1}) end
			       if map:inbounds(x-1, y+1) then table.insert(a, {x-1, y+1}) end
			    end

			    return a
			 end
	       end

mt.weighted_neighbors = function(map, weight)
			   return function(x, y)
				     local a = {}

				     for n=1, #weight do
					local c = weight:sub(n, n)

					if c=="n" and map:inbounds(x, y-1) then table.insert(a, {x, y-1}) end
					if c=="s" and map:inbounds(x, y+1) then table.insert(a, {x, y+1}) end
					if c=="e" and map:inbounds(x+1, y) then table.insert(a, {x+1, y}) end
					if c=="w" and map:inbounds(x-1, y) then table.insert(a, {x-1, y}) end
				     end

				     return a
				  end
			end

mt.randomwalk =
   function(map, start_x, start_y, valid, neighbors)
      local curr_x, curr_y = start_x, start_y
      valid = map:valid_function(valid)
      neighbor_function = map:neighbor_function(neighbors)

      return function()
		curr_x, curr_y = map:random_valid_neighbor(curr_x, curr_y, valid, neighbor_function)
		return curr_x, curr_y
	     end      
   end

string.random = function(str)
		   local n = math.random(#str)
		   return str:sub(n, n)
		end

--------------------------------------------------

SPREAD, DEATH, ITER, PROB = 3, 4, 4, 3

math.randomseed( os.time() )

function generate_forests(m)
   local m2 = Map.new(m:size())

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

function generate_river(map, start_x, start_y, prob)
   status("Generating rivers")
   local w, h = map:size()

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

function smooth_terrain(map)
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

function fractal_terrain(map)
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

function status(str)
   draw_status(str .. " (step " .. step_num .. " of " .. ")")
   step_num = step_num + 1
end

for k=1,4 do
   step_num = 1
   m = Map.new(512, 512)
   fractal_terrain(m)
   m = smooth_terrain(m)

   local w, h = m:size()
   local rivers = (w/64) ^ 2

   for n=1,rivers do
      local x, y

      repeat
	 x, y = math.random(w), math.random(h)
      until m:get(x, y) == "." 

      generate_river(m, x, y, "news")
   end

   generate_forests(m)
   m:draw()

   -- draw_status("Finished map " .. k, 255, 64, 64)
   getkey()
end