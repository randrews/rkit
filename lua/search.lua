function search(neighbors, start, goal)
   local open_list = {[start] = 0}
   local open_count = 1

   local closed = {}
   local parents = {}

   local lowest = function()
		     local least_node ; local least = math.huge

		     for node, cost in pairs(open_list) do
			if node and cost < least then
			   least_node, least = node, cost
			end
		     end

		     return least_node, least
		  end

   local build_path = function(final)
			 local path = {final}
			 local current = parents[final]

			 while current do
			    print(unpack(current))
			    table.insert(path, current)
			    current = parents[current]
			 end

			 return path
		      end

   local seen = function(node)
		   local x, y = unpack(node)
		   for node, cost in pairs(open_list) do
		      local node_x, node_y = unpack(node)
		      if x == node_x and y == node_y then return true end
		   end

		   for node, v in pairs(closed) do
		      local node_x, node_y = unpack(node)
		      if x == node_x and y == node_y then return true end
		   end

		   return false
		end

   while open_count > 0 do
      local current_node, current_cost = lowest()
      if current_cost > 100 then return nil end

      if goal(current_node) then
	 print("Made it")
	 return build_path(current_node)
      else
	 closed[current_node] = true
	 open_list[current_node] = nil ; open_count = open_count - 1

	 local neigh = neighbors(current_node)
	 if neigh then
	    for node, cost in pairs(neigh) do
	       if not seen(node) then
		  open_list[node] = current_cost + cost ; open_count = open_count + 1
		  parents[node] = current_node
	       end
	    end
	 end
      end
   end

   return nil
end
