--------------------------------------------------
-- Points ----------------------------------------
--------------------------------------------------

Point = {}
Point.prototype = {
   north = function(c) return point(c.x, c.y-1) end,
   south = function(c) return point(c.x, c.y+1) end,
   east = function(c) return point(c.x+1, c.y) end,
   west = function(c) return point(c.x-1, c.y) end,
   northwest = function(c) return point(c.x-1, c.y-1) end,
   northeast = function(c) return point(c.x+1, c.y-1) end,
   southwest = function(c) return point(c.x-1, c.y+1) end,
   southeast = function(c) return point(c.x+1, c.y+1) end,
   translate = function(c,by) return point(c.x+by.x, c.y+by.y) end,
   scale = function(c,by) return point(c.x*by, c.y*by) end,
   delta = function(c, from) return point(c.x-from.x, c.y-from.y) end }

function Point.prototype.tostring(pt)
	return "<point: (" .. tostring(pt.x) .. ", " .. tostring(pt.y) .. ")>"
end

Point.mt = {
   __index = Point.prototype,
   __tostring = Point.prototype.tostring,
   __add = Point.prototype.translate,
   __sub = Point.prototype.delta,
   __mul = Point.prototype.scale
}

Point.new = function(x, y)
   local p = {x=x, y=y}
   setmetatable(p, Point.mt)
   return p
end

point = Point.new
