require("point")

--------------------------------------------------
-- Blocks ----------------------------------------
--------------------------------------------------

Block = {}
Block.prototype = {}
Block.mt = { __index = Block.prototype }

Block.prototype.occ =
   function(block, at)
      if at.x < 1 or at.y < 1 or
		 at.x > block.width or at.y > block.height then
		 return false
      else
		 local n = at.x + block.width*(at.y - 1)
		 return block[n] ~= 0
      end
   end

Block.prototype.draw =
   function(block, at)
      for y=1,block.height do
		 for x=1,block.width do
			local curr = point(x, y)
			local screen = point(at.x+(x-1)*32,
								 at.y+(block.height-y)*32)
			if block:occ(curr) then
			   if block.color then block:background(screen) end
			   block:walls(curr,screen)
			   block:corners(curr,screen)
			end
		 end
      end
   end

Block.prototype.background =
   function(b, at)
      RKit.rect(at.x, at.y, 32, 32, b.color, true)
   end

Block.prototype.walls =
   function(b, cell, at)
      if not b:occ(cell:north()) then
		 RKit.draw_tile(wall_ts, 0, at.x, at.y)
      end

      if not b:occ(cell:east()) then
		 RKit.draw_tile(wall_ts, 1, at.x, at.y)
      end

      if not b:occ(cell:south()) then
		 RKit.draw_tile(wall_ts, 2, at.x, at.y)
      end

      if not b:occ(cell:west()) then
		 RKit.draw_tile(wall_ts, 3, at.x, at.y)
      end
   end

Block.prototype.corners =
   function(b, cell, at)
      local n = b:occ(cell:north())
      local e = b:occ(cell:east())
      local w = b:occ(cell:west())
      local s = b:occ(cell:south())
      local ne = b:occ(cell:northeast())
      local nw = b:occ(cell:northwest())
      local se = b:occ(cell:southeast())
      local sw = b:occ(cell:southwest())

      if not n or
		 not w or
		 n and not nw or
		 w and not nw then
		 RKit.draw_tile(corner_ts, 0, at.x, at.y+28)
      end

      if not s or
		 not e or
		 s and not se or
		 e and not se then
		 RKit.draw_tile(corner_ts, 1, at.x+28, at.y)
      end

      local ne_white = not n
      local ne_black = not e

      if ne_white and ne_black then
		 RKit.draw_tile(corner_ts, 2, at.x+28, at.y+28)
      elseif ne_white and not ne_black then
		 RKit.draw_tile(corner_ts, 0, at.x+28, at.y+28)
      elseif not ne_white and ne_black then
		 RKit.draw_tile(corner_ts, 1, at.x+28, at.y+28)
      elseif n and e and not ne then
		 RKit.draw_tile(corner_ts, 3, at.x+28, at.y+28)
      end

      local sw_white = not w
      local sw_black = not s

      if sw_white and sw_black then
		 RKit.draw_tile(corner_ts, 2, at.x, at.y)
      elseif sw_white and not sw_black then
		 RKit.draw_tile(corner_ts, 0, at.x, at.y)
      elseif not sw_white and sw_black then
		 RKit.draw_tile(corner_ts, 1, at.x, at.y)
      elseif s and w and not sw then
		 RKit.draw_tile(corner_ts, 3, at.x, at.y)
      end
   end

-- Some functions dealing with points / regions

function Block.prototype.mask(block, pt)
   local x = math.floor(pt.x / 32)
   local y = math.floor(pt.y / 32)
   return block:occ(point(x+1, block.height-y))
end

function Block.new(cells)
   setmetatable(cells, Block.mt)
   return cells
end
