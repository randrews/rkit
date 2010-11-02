ts = RKit.load_tilesheet("Tahin-font.tga", 16, 16)
floor = RKit.load_bitmap("floor.tga")

RKit.draw_bitmap(floor, 0, 0)
RKit.draw_glyph(ts, "=", 50, 50)
RKit.draw_glyph(ts, 65, 70, 50, RKit.color(255, 0, 0), RKit.color(100, 0, 0))