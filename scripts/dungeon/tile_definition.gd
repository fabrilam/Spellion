extends Resource
class_name DungeonTiles

enum TileType {
	VOID,      # empty, not part of dungeon
	FLOOR,     # walkable floor
	WALL,      # solid wall
	CORRIDOR,  # walkable corridor
	DOOR,      # doorway between rooms
}

enum RoomType {
	NONE,
	SPAWN,      # starting room (safe)
	HALLWAY,    # wide passage
	OPEN_AREA,  # large open room
	STORAGE,    # small with barrels/crates
	TREASURE,   # medium with chests
	ALTAR,      # medium with altar
	LIBRARY,    # with bookshelves
	BOSS,       # large boss room
}
