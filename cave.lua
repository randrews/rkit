m = Map.new(10,20)

print(m:size())
print(m:adjacent(0,0,"."))

print(m:inbounds(0,0))
print(m:inbounds(-3,0))
print(m:inbounds(0,11))
print(m:inbounds(0,21))

for x, y in m:each() do
   print(x,y)
   if(x > 3 and y > 3) then break end
end