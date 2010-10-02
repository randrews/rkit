-- m = Map.new(10,20)

-- print(m:size())
-- print(m:adjacent(0,0,"."))

-- print(m:inbounds(0,0))
-- print(m:inbounds(-3,0))
-- print(m:inbounds(0,11))
-- print(m:inbounds(0,21))

-- for x, y, c in m:each(0,0,4,2) do
--    print(x,y,c)
-- end

-- print("----------")

-- m2 = Map.new(3,3)

-- for x, y, c in m2:each() do
--    print(x,y,c)
-- end

-- m:set(0,0,"+")
-- print(m:get(0,0))

SPREAD, DEATH, ITER, PROB = 3, 4, 4, 3

math.randomseed( os.time() )

function generate_map()
   m = Map.new(128,128)
   m2 = Map.new(128,128)

   for x, y in m:each() do
      if math.random(PROB)==1 then m:set(x,y,"+") end
   end

   for k=1,ITER do
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

   return m
end

for k=1,4 do
   generate_map():draw()
   getkey()
end