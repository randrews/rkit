array = {}

function array.map(table, fn)
   local ret = {}
   for k, v in pairs(table) do
	  ret[k] = fn(v, k)
   end
   return ret
end

-- Return the first value in table that matches the predicate, or nil
function array.find(table, fn)
   for k, v in pairs(table) do
	  if fn(v, k) then return v end
   end
   return nil
end

-- Returns ALL values in table that match fn, but ignores non-integer indexes.
function array.select(table, fn)
   local ret = {}
   for k, v in ipairs(table) do
	  if fn(v, k) then _G.table.insert(ret, v) end
   end
   return ret
end
