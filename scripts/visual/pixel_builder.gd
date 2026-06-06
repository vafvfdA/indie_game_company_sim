class_name PixelBuilder
extends RefCounted

const S := 3  # pixel scale factor

# --- Core texture generation ---

static func make_texture(width: int, height: int, pixels: PackedColorArray, scale: int = S) -> ImageTexture:
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in height:
		for x in width:
			var c := pixels[y * width + x]
			if c.a > 0:
				img.set_pixel(x, y, c)
	if scale > 1:
		img.resize(width * scale, height * scale, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)

static func make_from_map(w: int, h: int, map: String, palette: Dictionary, scale: int = S) -> ImageTexture:
	var pixels := PackedColorArray()
	var lines := map.strip_edges().split("\n")
	for y in h:
		var row := ""
		if y < lines.size():
			row = lines[y]
		for x in w:
			var ch := " "
			if x < row.length():
				ch = row[x]
			if ch in palette:
				pixels.append(palette[ch])
			else:
				pixels.append(Color(0, 0, 0, 0))
	return make_texture(w, h, pixels, scale)

# --- Character textures ---

static func _char_palette(role: String) -> Dictionary:
	var hair := Color("3a2a1a")
	var shirt := Color("4a9eff")
	match role:
		"programmer": shirt = Color("4a9eff"); hair = Color("2a2a3a")
		"artist": shirt = Color("ff6b9d"); hair = Color("5a3a2a")
		"designer": shirt = Color("4ecdc4"); hair = Color("3a2a2a")
		"musician": shirt = Color("ffd93d"); hair = Color("4a3a2a")
	return {
		"H": hair,
		"S": Color("f5c6a0"),  # skin
		"E": Color("1a1a2e"),  # eyes
		"T": shirt,            # shirt
		"P": Color("2a3450"),  # pants
		"B": Color("1a1a2e"),  # shoes
		".": Color(0, 0, 0, 0),
	}

static func char_idle(role: String) -> ImageTexture:
	var map := """
....HHHH....
...HHHHHH...
...SSSSSS...
...SESSSE...
...SSSSSS...
....SSSS....
...TTTTTT...
...TTTTTT...
..TTTTTTTT..
...TTTTTT...
...SS..SS...
...PP..PP...
...PP..PP...
...PP..PP...
...BB..BB...
...BB..BB...
"""
	return make_from_map(12, 16, map, _char_palette(role))

static func char_walk1(role: String) -> ImageTexture:
	var map := """
....HHHH....
...HHHHHH...
...SSSSSS...
...SESSSE...
...SSSSSS...
....SSSS....
...TTTTTT...
...TTTTTT...
..TTTTTTTT..
...TTTTTT...
...SS..SS...
..PP....PP..
..PP....PP..
..PP....PP..
..BB....BB..
..BB....BB..
"""
	return make_from_map(12, 16, map, _char_palette(role))

static func char_walk2(role: String) -> ImageTexture:
	var map := """
....HHHH....
...HHHHHH...
...SSSSSS...
...SESSSE...
...SSSSSS...
....SSSS....
...TTTTTT...
...TTTTTT...
..TTTTTTTT..
...TTTTTT...
...SS..SS...
...PPPP.....
...PPPP.....
...PPPP.....
...BBBB.....
...BBBB.....
"""
	return make_from_map(12, 16, map, _char_palette(role))

static func char_work1(role: String) -> ImageTexture:
	var map := """
....HHHH....
...HHHHHH...
...SSSSSS...
...SESSSE...
...SSSSSS...
....SSSS....
...TTTTTT...
..TTTTTTTT..
..TTTTTTTT..
..SSSTTTT...
...SS.SS....
...PP..PP...
...PP..PP...
...PP..PP...
...BB..BB...
...BB..BB...
"""
	return make_from_map(12, 16, map, _char_palette(role))

static func char_work2(role: String) -> ImageTexture:
	var map := """
....HHHH....
...HHHHHH...
...SSSSSS...
...SESSSE...
...SSSSSS...
....SSSS....
...TTTTTT...
..SSTTTTTT..
..SSTTTTTT..
...STTTTTT..
....S..SS...
...PP..PP...
...PP..PP...
...PP..PP...
...BB..BB...
...BB..BB...
"""
	return make_from_map(12, 16, map, _char_palette(role))

# --- Furniture textures ---

static func desk_texture() -> ImageTexture:
	var map := """
DDDDDDDDDDDDDDDDDDDDDD
DDDDDDDDDDDDDDDDDDDDDD
DDDDDDDDDDDDDDDDDDDDDD
DDDDDDDDDDDDDDDDDDDDDD
DDDDDDDDDDDDDDDDDDDDDD
DDDDDDDDDDDDDDDDDDDDDD
DDDDDDDDDDDDDDDDDDDDDD
DDDDDDDDDDDDDDDDDDDDDD
..DD............DD......
..DD............DD......
..DD............DD......
..DD............DD......
"""
	var palette := {"D": Color("6b4226"), ".": Color(0, 0, 0, 0)}
	return make_from_map(24, 12, map, palette)

static func monitor_texture(screen_on: bool = false) -> ImageTexture:
	var sc := Color("16213e")
	if screen_on:
		sc = Color("2a7ab5")
	var map := """
MMMMMMMMMMMM
M...........M
M.SSSSSSSSS.M
M.SSSSSSSSS.M
M.SSSSSSSSS.M
M.SSSSSSSSS.M
M.SSSSSSSSS.M
M...........M
MMMMMMMMMMMM
......MM......
......MM......
....MMMMMM....
"""
	var palette := {
		"M": Color("2a2a3a"),
		"S": sc,
		".": Color(0, 0, 0, 0),
	}
	return make_from_map(12, 12, map, palette)

static func chair_texture() -> ImageTexture:
	var map := """
....CCCC....
...CCCCCC...
...CCCCCC...
..CCCCCCCC..
..CCCCCCCC..
..CCCCCCCC..
..CCCCCCCC..
...CCCCCC...
....CC.CC...
....CC.CC...
...CC...CC..
"""
	var palette := {"C": Color("1e2d4a"), ".": Color(0, 0, 0, 0)}
	return make_from_map(12, 11, map, palette)

static func bookshelf_texture() -> ImageTexture:
	var map := """
WWWWWWWWWWWW
WRRGGBBYYMMW
WRRGGBBYYMMW
WRRGGBBYYMMW
WWWWWWWWWWWW
WRRGGBBYYCCW
WRRGGBBYYCCW
WRRGGBBYYCCW
WWWWWWWWWWWW
W..WW..WW..W
W..WW..WW..W
WWWWWWWWWWWW
"""
	var palette := {
		"W": Color("5a3a1a"),
		"R": Color("e94560"),
		"G": Color("4ecdc4"),
		"B": Color("4a9eff"),
		"Y": Color("ffd93d"),
		"M": Color("ff6b9d"),
		"C": Color("8892a0"),
		".": Color(0, 0, 0, 0),
	}
	return make_from_map(12, 12, map, palette)

static func plant_texture() -> ImageTexture:
	var map := """
..GGGGGG..
.GGGGGGGG.
GGGGGGGGGG
.GGLLGLLG.
..GLLGLL..
..GLLGLL..
....LL....
...PPPP...
...PPPP...
..PPPPPP..
"""
	var palette := {
		"G": Color("2d8b4e"),
		"L": Color("3aad62"),
		"P": Color("8b4513"),
		".": Color(0, 0, 0, 0),
	}
	return make_from_map(10, 10, map, palette)

static func coffee_machine_texture() -> ImageTexture:
	var map := """
.MMMMMMMM.
.MMMMMMMM.
M.MMMMMM.M
M........M
M.BBBBBB.M
M.BBBBBB.M
M........M
M..CCCC..M
M........M
.MMMMMMMM.
"""
	var palette := {
		"M": Color("5a5a6a"),
		"B": Color("4a3728"),
		"C": Color("8892a0"),
		".": Color(0, 0, 0, 0),
	}
	return make_from_map(10, 10, map, palette)

static func whiteboard_texture() -> ImageTexture:
	var map := """
BBBBBBBBBBBB
B...........B
B...........B
B...........B
B...........B
B...........B
B...........B
BBBBBBBBBBBB
"""
	var palette := {
		"B": Color("8892a0"),
		".": Color("eaeaea"),
	}
	return make_from_map(12, 8, map, palette)

static func floor_tile_texture() -> ImageTexture:
	var pixels := PackedColorArray()
	var tile_size := 16
	for y in tile_size:
		for x in tile_size:
			if x == 0 or y == 0:
				pixels.append(Color("1e1e32"))
			else:
				pixels.append(Color("1a1a2e"))
	return make_texture(tile_size, tile_size, pixels, 1)

static func wall_texture() -> ImageTexture:
	var pixels := PackedColorArray()
	var w := 16
	var h := 16
	for y in h:
		for x in w:
			if y < 2:
				pixels.append(Color("e94560"))
			elif y == 2 or y == 9:
				pixels.append(Color("0a2a4a"))
			elif x % 8 == 0:
				pixels.append(Color("0a2a4a"))
			else:
				pixels.append(Color("0f3460"))
	return make_texture(w, h, pixels, 1)
