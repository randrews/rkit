mt = getmetatable(Map.new(1,1))

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

mt.random_valid_neighbor = function(map, x, y, valid, diag)
			      if type(valid) ~= "function" then valid = map:valid_function(valid) end

			      local possible = map:neighbors(x, y, diag)

			      while #possible > 0 do
				 local cell = table.remove( possible, math.random(#possible) )
				 if not valid or valid(unpack(cell)) then
				    return unpack(cell)
				 end
			      end

			      return nil
			   end

mt.neighbors = function(map, x, y, diag)
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

mt.randomwalk =
   function(map, start_x, start_y, valid, diag)
      local curr_x, curr_y = start_x, start_y
      valid = map:valid_function(valid)

      return function()
		curr_x, curr_y = map:random_valid_neighbor(curr_x, curr_y, valid, diag)
		return curr_x, curr_y
	     end      
   end

SPREAD, DEATH, ITER, PROB = 3, 4, 4, 3

math.randomseed( os.time() )

function generate_forests(m)
   local m2 = Map.new(m:size())

   for x, y, c in m:each() do
      m2:set(x, y, c) -- Replace me with a clone function
      if c ~= "-" and math.random(PROB)==1 then
	 m:set(x,y,"+")
      end
   end

   for k=1,ITER do
      for x, y, c in m:each() do
	 if c ~= "-" then
	    if c=="+" and m:adjacent(x,y,"+") < DEATH then
	       m2:set(x,y,".")
	    elseif c == "." and m:adjacent(x,y,"+") > SPREAD then
	       m2:set(x,y,"+")	 
	    else
	       m2:set(x,y,c)
	    end
	 end
      end

      m2, m = m, m2
   end

   -- Mark everything surrounded by + with #
   for x,y,c in m:each() do
      if c=="+" and m:adjacent(x,y,"+")==8 then m2:set(x,y,"#")
      else m2:set(x, y, m:get(x,y)) end
   end

   -- Mark everything surrounded by # with club
   for x,y,c in m2:each() do
      if c=="#" and m2:adjacent(x,y,"#")==8 then
	 m:set(x,y,string.char(5))
      end
   end
end

function generate_river(map, start_x, start_y)
   local w, h = map:size()

   local c = (w+h)*4
   local proximity = function(x,y)
			local dx = start_x - x
			local dy = start_y - y

			local dist = math.sqrt(dx*dx + dy*dy)

			return c >= 0 and
			   (dist < 5 or map:adjacent(x, y, "-") < 3)
		     end

   for x,y in map:randomwalk(start_x, start_y, proximity) do
      map:set(x,y,"-")
      c = c - 1
   end
   
end

for k=1,4 do
   m = Map.new(256, 256)
   for n=1,8 do
      local w, h = m:size()
      generate_river(m, math.random(w/2), math.random(h/2))
      generate_river(m, math.random(w/2) + w/2, math.random(h/2))
      generate_river(m, math.random(w/2) + w/2, math.random(h/2) + h/2)
      generate_river(m, math.random(w/2), math.random(h/2) + h/2)
   end
   generate_forests(m)
   m:draw()
   getkey()
end