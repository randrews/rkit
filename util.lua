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

function status(str)
   draw_status(str .. " (step " .. step_num .. " of 139)")
   step_num = step_num + 1
end

math.randomseed( os.time() )
