m = Map.new(10,20)

print(m:size())
print(m:adjacent(0,0,"."))

print(m:inbounds(0,0))
print(m:inbounds(-3,0))
print(m:inbounds(0,11))
print(m:inbounds(0,21))

for x, y, c in m:each(0,0,4,2) do
   print(x,y,c)
end

print("----------")

m2 = Map.new(3,3)

for x, y, c in m2:each() do
   print(x,y,c)
end
