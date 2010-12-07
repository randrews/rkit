function print(...)
   local strs = {}
   for k,v in ipairs(arg) do strs[k]=tostring(v) end
   RKit.log(table.concat(strs,"\t"))
end

require("array")
require("point")
require("block")
require("region")
