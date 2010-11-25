RKit.resizable(false)
RKit.resize(640, 480, 200, 200)
RKit.set_title("Matricks")

floor = RKit.load_bitmap("floor")

RKit.set_redraw_handler(function()
							RKit.draw_bitmap(floor, 0, 0)
						end)

RKit.redraw()
