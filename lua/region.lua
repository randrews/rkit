require("point")
require("array")

-- A region looks like this:
-- Region.new{
--     origin=point(50, 50),
--     width=50, height=50,
--     mousedown=function(self, point) ... end,
--     ... etc, other event handlers the same ...
-- }

-- Dragging:
-- To enable dragging, set draggable=true on the region.
-- When the region receives a mousedown, until it gets a mouseup,
-- it will be the current dragged region. Whes a mousedragged
-- event is received, the region's origin is updated accordingly,
-- and the region's dragto method is called with the new origin.

-- Hit testing:
-- If your region has a mask(self,point) method, it will be called
-- with a point (in region coordinates) to determine whether to
-- pass on events. Any event within the bounding box will be
-- tested with mask, but only the ones that pass will be sent to
-- event handlers.

Region = {}
Region.prototype = {}
Region.mt = { __index = Region.prototype }
Region.regions = {}

function Region.new(opts)
   setmetatable(opts, Region.mt)
   table.insert(Region.regions, opts)
   return opts
end

function Region.install()
   RKit.set_mouse_handler(Region.mouse_handler)
end

function Region.prototype.hit(region, pt)
   local o = region.origin
   return (pt.x >= o.x and pt.y >= o.y and
		   pt.x <= o.x+region.width and
		   pt.y <= o.y+region.height)
end

function Region.start_drag(dragged, mouse_at)
   if not dragged.draggable then return end
   Region.current_dragged = dragged
   Region.drag_mouse_delta = mouse_at - dragged.origin
   Region.drag(mouse_at)
end

function Region.handle_drop(pt)
   Region.drag(pt)
   Region.current_dragged = nil
end

function Region.drag(pt)
   Region.current_dragged.origin = pt - Region.drag_mouse_delta
   if Region.current_dragged.dragto then
	  Region.current_dragged:dragto(Region.current_dragged.origin)
   end
end

function Region.mouse_handler(type, x, y, buttons)
   if type == "mousemove" then return end
   local pt = point(x,y)
   if type=="mousedragged" and Region.current_dragged then Region.drag(pt) end

   local hits = array.select(Region.regions, function(r) return r:hit(pt) end)
   if #hits > 0 then
	  local last_hit = hits[#hits]
	  if not last_hit.mask or last_hit:mask(pt - last_hit.origin) then
		 if type=="mousedown" then Region.start_drag(last_hit, pt) end
		 if type=="mouseup" and Region.current_dragged then Region.handle_drop(pt) end

		 if last_hit[type] then last_hit[type](last_hit,pt) end
	  end
   end
end
