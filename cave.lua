m = Map.new(10,20)

print(m:size())
print(m:adjacent(0,0,"."))

print(m:inbounds(0,0))
print(m:inbounds(-3,0))
print(m:inbounds(0,11))
print(m:inbounds(0,21))
