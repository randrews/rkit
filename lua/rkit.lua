ts = RKit.load_tilesheet("img/Tahin-font.tga", 16, 16)
floor = RKit.load_bitmap("img/floor.tga")

RKit.draw_bitmap(floor, 0, 0)
RKit.draw_glyph(ts, "=", 50, 50)
RKit.draw_glyph(ts, 65, 70, 50, RKit.color(255, 0, 0), RKit.color(100, 0, 0))

key, letter = RKit.readkey()

while key ~= "ESC" do
   print("["..key.."]", letter)
   key, letter = RKit.readkey()
end