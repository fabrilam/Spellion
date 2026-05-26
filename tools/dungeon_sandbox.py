#!/usr/bin/env python3
"""
Dungeon Generator Sandbox — Spellion
Runs the GDScript dungeon generation logic in Python for rapid ASCII prototyping.
Usage:
  python tools/dungeon_sandbox.py                    # random dungeon
  python tools/dungeon_sandbox.py --seed 42          # specific seed
  python tools/dungeon_sandbox.py --runs 5           # stats only
  python tools/dungeon_sandbox.py --params {...}     # custom params
  python tools/dungeon_sandbox.py --export-params    # print current params as JSON
"""

import sys, json, random, argparse
from dataclasses import dataclass, field
from typing import List, Tuple, Dict, Optional

# ─── Tile types ─────────────────────────────────────────────────────────────
VOID = 0
FLOOR = 1
WALL = 2
CORRIDOR = 3
DOOR = 4

TILE_CHARS = {VOID: ' ', FLOOR: '.', WALL: '#', CORRIDOR: ',', DOOR: 'D'}

# ─── Room types ─────────────────────────────────────────────────────────────
SPAWN = 0
STORAGE = 1
HALLWAY = 2
TREASURE = 3
ALTAR = 4
LIBRARY = 5
OPEN_AREA = 6
BOSS = 7

ROOM_NAMES = {
    SPAWN: "Spawn", STORAGE: "Storage", HALLWAY: "Hallway",
    TREASURE: "Treasure", ALTAR: "Altar", LIBRARY: "Library",
    OPEN_AREA: "OpenArea", BOSS: "Boss",
}

# ─── Default parameters ─────────────────────────────────────────────────────
DEFAULT_PARAMS = {
    "GRID_W": 80,
    "GRID_H": 60,
    "SPINE_ROOM_SIZE": 8,
    "SPINE_CORRIDOR_W": 1,
    "MIN_FLOOR_TILES": 400,
    "ROOM_SIZES": [4, 6, 8],
    "MAX_ATTEMPTS": 30,
    "INTERIOR_WALL_ATTEMPTS": 4,
    "SPINE_COUNT_MIN": 2,
    "SPINE_COUNT_MAX": 3,
}


@dataclass
class DungeonGen:
    params: dict = field(default_factory=lambda: dict(DEFAULT_PARAMS))
    grid: List[List[int]] = field(default_factory=list)
    rooms: List[dict] = field(default_factory=list)
    room_registry: List[dict] = field(default_factory=list)
    spawn_door_y: int = 0
    seed: int = 0

    def generate(self, seed: int = -1) -> dict:
        if seed >= 0:
            self.seed = seed
            random.seed(seed)
        else:
            self.seed = random.randrange(0, 2**31)
            random.seed(self.seed)

        p = self.params
        for attempt in range(p["MAX_ATTEMPTS"]):
            self.grid = [[VOID] * p["GRID_W"] for _ in range(p["GRID_H"])]
            self.rooms = []
            self.room_registry = []
            self._transparent = [[False] * p["GRID_W"] for _ in range(p["GRID_H"])]

            self._generate_spine()

            if self.room_registry:
                sp = self.room_registry[0]
                self._l5_room_gen(sp["x"], sp["y"], sp["w"], sp["h"], 0)

            floor_count = self._count_floor()
            if floor_count < p["MIN_FLOOR_TILES"]:
                continue

            self._build_walls()
            self._fill_corners()
            self._add_interior_walls()
            self._analyze_transparency()

            if self._is_fully_connected():
                break

        self._assign_room_types()
        spawn_world_x = 0.0 - p["GRID_W"]
        spawn_world_z = self.spawn_door_y * 2.0 + 20.0
        return {
            "grid": self.grid,
            "transparent": self._transparent,
            "rooms": self.rooms,
            "width": p["GRID_W"],
            "height": p["GRID_H"],
            "spawn_pos": (spawn_world_x, 0.0, spawn_world_z),
            "seed": self.seed,
        }

    def _generate_spine(self) -> None:
        p = self.params
        room_count = random.randint(p["SPINE_COUNT_MIN"], p["SPINE_COUNT_MAX"])
        spine_y = (p["GRID_H"] - p["SPINE_ROOM_SIZE"]) // 2

        for i in range(room_count):
            rx = 2 + i * (p["SPINE_ROOM_SIZE"] + p["SPINE_CORRIDOR_W"])
            ry = spine_y
            self._draw_room(rx, ry, p["SPINE_ROOM_SIZE"], p["SPINE_ROOM_SIZE"])
            self.room_registry.append({"x": rx, "y": ry, "w": p["SPINE_ROOM_SIZE"], "h": p["SPINE_ROOM_SIZE"]})

            if i > 0:
                prev_rx = 2 + (i - 1) * (p["SPINE_ROOM_SIZE"] + p["SPINE_CORRIDOR_W"])
                mid_y = spine_y + p["SPINE_ROOM_SIZE"] // 2
                for x in range(prev_rx + p["SPINE_ROOM_SIZE"], rx):
                    for w in range(p["SPINE_CORRIDOR_W"]):
                        yy = mid_y - p["SPINE_CORRIDOR_W"] // 2 + w
                        if 0 <= yy < p["GRID_H"] and 0 <= x < p["GRID_W"]:
                            self.grid[yy][x] = FLOOR

        self.spawn_door_y = spine_y + p["SPINE_ROOM_SIZE"] // 2
        if 0 <= self.spawn_door_y < p["GRID_H"]:
            self.grid[self.spawn_door_y][0] = DOOR
            self.grid[self.spawn_door_y][1] = FLOOR

    def _draw_room(self, rx: int, ry: int, rw: int, rh: int) -> None:
        p = self.params
        for y in range(ry, ry + rh):
            for x in range(rx, rx + rw):
                if 0 <= x < p["GRID_W"] and 0 <= y < p["GRID_H"]:
                    self.grid[y][x] = FLOOR

    @staticmethod
    def _diablo_room_size() -> int:
        return ((random.randint(0, 5) + 2) & 0xFFFFFFFE) * 2

    def _l5_room_gen(self, x: int, y: int, w: int, h: int, axis: int) -> None:
        p = self.params
        if random.random() < 0.25:
            axis = 1 - axis

        if axis == 0:  # X axis: try LEFT and RIGHT
            num = 0
            cw = ch = 0
            cx1 = cy1 = 0
            ran = False
            while not ran and num < 20:
                cw = self._diablo_room_size()
                ch = self._diablo_room_size()
                cy1 = h // 2 + y - ch // 2
                cx1 = x - cw
                ran = self._l5_check_room(cx1 - 1, cy1 - 1, cw + 1, ch + 2)
                num += 1

            if ran:
                self._draw_room(cx1, cy1, cw, ch)
                self.room_registry.append({"x": cx1, "y": cy1, "w": cw, "h": ch})

            cx2 = x + w
            ran2 = self._l5_check_room(cx2, cy1 - 1, cw + 1, ch + 2)
            if ran2:
                self._draw_room(cx2, cy1, cw, ch)
                self.room_registry.append({"x": cx2, "y": cy1, "w": cw, "h": ch})

            if ran:
                self._l5_room_gen(cx1, cy1, cw, ch, 1)
            if ran2:
                self._l5_room_gen(cx2, cy1, cw, ch, 1)

        else:  # Y axis: try UP and DOWN
            num = 0
            cw = ch = 0
            rx = ry = 0
            ran = False
            while not ran and num < 20:
                cw = self._diablo_room_size()
                ch = self._diablo_room_size()
                rx = w // 2 + x - cw // 2
                ry = y - ch
                ran = self._l5_check_room(rx - 1, ry - 1, cw + 2, ch + 1)
                num += 1

            if ran:
                self._draw_room(rx, ry, cw, ch)
                self.room_registry.append({"x": rx, "y": ry, "w": cw, "h": ch})

            ry2 = y + h
            ran2 = self._l5_check_room(rx - 1, ry2, cw + 2, ch + 1)
            if ran2:
                self._draw_room(rx, ry2, cw, ch)
                self.room_registry.append({"x": rx, "y": ry2, "w": cw, "h": ch})

            if ran:
                self._l5_room_gen(rx, ry, cw, ch, 0)
            if ran2:
                self._l5_room_gen(rx, ry2, cw, ch, 0)

    def _l5_check_room(self, tx: int, ty: int, tw: int, th: int) -> bool:
        p = self.params
        if tx < 0 or ty < 0 or tx + tw > p["GRID_W"] or ty + th > p["GRID_H"]:
            return False
        for y in range(ty, ty + th):
            for x in range(tx, tx + tw):
                if self.grid[y][x] != VOID:
                    return False
        return True

    def _room_fits(self, rx: int, ry: int, rw: int, rh: int) -> bool:
        p = self.params
        if rx < 0 or ry < 0 or rx + rw > p["GRID_W"] or ry + rh > p["GRID_H"]:
            return False
        for y in range(ry, ry + rh):
            for x in range(rx, rx + rw):
                if self.grid[y][x] != VOID:
                    return False
        return True

    def _count_floor(self) -> int:
        return sum(row.count(FLOOR) for row in self.grid)

    def _build_walls(self) -> None:
        p = self.params
        to_wall = []
        for y in range(p["GRID_H"]):
            for x in range(p["GRID_W"]):
                if self.grid[y][x] != VOID:
                    continue
                adj_floor = False
                for ny in (y - 1, y + 1):
                    if 0 <= ny < p["GRID_H"] and self.grid[ny][x] == FLOOR:
                        adj_floor = True
                        break
                if not adj_floor:
                    for nx in (x - 1, x + 1):
                        if 0 <= nx < p["GRID_W"] and self.grid[y][nx] == FLOOR:
                            adj_floor = True
                            break
                if adj_floor:
                    to_wall.append((x, y))

        for x, y in to_wall:
            self.grid[y][x] = WALL

        floating = []
        for y in range(p["GRID_H"]):
            for x in range(p["GRID_W"]):
                if self.grid[y][x] != WALL:
                    continue
                has_floor = False
                for ny in (y - 1, y, y + 1):
                    for nx in (x - 1, x, x + 1):
                        if 0 <= ny < p["GRID_H"] and 0 <= nx < p["GRID_W"]:
                            if self.grid[ny][nx] == FLOOR:
                                has_floor = True
                if not has_floor:
                    floating.append((x, y))

        for x, y in floating:
            self.grid[y][x] = VOID

    def _fill_corners(self) -> None:
        p = self.params
        for y in range(p["GRID_H"]):
            for x in range(p["GRID_W"]):
                if self.grid[y][x] != VOID:
                    continue
                has_top = y > 0 and self.grid[y - 1][x] == WALL
                has_bot = y < p["GRID_H"] - 1 and self.grid[y + 1][x] == WALL
                has_lft = x > 0 and self.grid[y][x - 1] == WALL
                has_rgt = x < p["GRID_W"] - 1 and self.grid[y][x + 1] == WALL
                if (has_top and has_lft) or (has_top and has_rgt) or (has_bot and has_lft) or (has_bot and has_rgt):
                    self.grid[y][x] = WALL

    def _analyze_transparency(self) -> None:
        p = self.params
        self._transparent = [[False] * p["GRID_W"] for _ in range(p["GRID_H"])]
        for y in range(p["GRID_H"]):
            for x in range(p["GRID_W"]):
                if self.grid[y][x] != WALL:
                    continue
                # South = positive Y in grid = positive Z in world = towards camera
                if y < p["GRID_H"] - 1:
                    neighbor = self.grid[y + 1][x]
                    if neighbor == FLOOR or neighbor == DOOR:
                        self._transparent[y][x] = True

    def _add_interior_walls(self) -> None:
        for _ in range(self.params["INTERIOR_WALL_ATTEMPTS"]):
            saved = self._snapshot_grid()
            self._try_add_cross_wall()
            if not self._is_fully_connected():
                self.grid = saved

    def _snapshot_grid(self) -> List[List[int]]:
        return [row[:] for row in self.grid]

    def _try_add_cross_wall(self) -> None:
        p = self.params
        horizontal = random.random() < 0.5
        for _ in range(30):
            if horizontal:
                pos = random.randint(3, p["GRID_H"] - 4)
                start_x = end_x = -1
                for x in range(p["GRID_W"]):
                    if self.grid[pos][x] == FLOOR:
                        if start_x < 0:
                            start_x = x
                        end_x = x
                if start_x < 0 or end_x - start_x < 6:
                    continue
                if (start_x <= 0 or self.grid[pos][start_x - 1] != WALL) and \
                   (end_x >= p["GRID_W"] - 1 or self.grid[pos][end_x + 1] != WALL):
                    continue
                self._build_wall_line(pos, start_x, end_x, True)
                return
            else:
                pos = random.randint(3, p["GRID_W"] - 4)
                start_y = end_y = -1
                for y in range(p["GRID_H"]):
                    if self.grid[y][pos] == FLOOR:
                        if start_y < 0:
                            start_y = y
                        end_y = y
                if start_y < 0 or end_y - start_y < 6:
                    continue
                if (start_y <= 0 or self.grid[start_y - 1][pos] != WALL) and \
                   (end_y >= p["GRID_H"] - 1 or self.grid[end_y + 1][pos] != WALL):
                    continue
                self._build_wall_line(pos, start_y, end_y, False)
                return

    def _build_wall_line(self, fixed: int, from_a: int, to_a: int, horiz: bool) -> None:
        mid = (from_a + to_a) // 2
        for i in range(from_a, to_a + 1):
            x = i if horiz else fixed
            y = fixed if horiz else i
            if i == mid:
                self.grid[y][x] = DOOR
            else:
                self.grid[y][x] = WALL

    def _is_fully_connected(self) -> bool:
        p = self.params
        start = None
        for y in range(p["GRID_H"]):
            for x in range(p["GRID_W"]):
                if self.grid[y][x] in (FLOOR, DOOR):
                    start = (x, y)
                    break
            if start:
                break
        if not start:
            return False

        visited = [[False] * p["GRID_W"] for _ in range(p["GRID_H"])]
        stack = [start]
        visited[start[1]][start[0]] = True
        reachable = 0
        while stack:
            x, y = stack.pop()
            reachable += 1
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < p["GRID_W"] and 0 <= ny < p["GRID_H"] and not visited[ny][nx]:
                    if self.grid[ny][nx] in (FLOOR, DOOR):
                        visited[ny][nx] = True
                        stack.append((nx, ny))

        total = sum(row.count(FLOOR) + row.count(DOOR) for row in self.grid)
        return reachable == total

    def _assign_room_types(self) -> None:
        self.rooms = []
        for ri, rd in enumerate(self.room_registry):
            depth = min(ri, 5)
            rtype = {0: SPAWN, 1: STORAGE, 2: HALLWAY, 3: TREASURE, 4: BOSS}.get(depth, HALLWAY)
            self.rooms.append({"x": rd["x"], "y": rd["y"], "w": rd["w"], "h": rd["h"], "type": rtype})

    def get_room_at(self, tx: int, ty: int) -> dict:
        for r in self.rooms:
            if r["x"] <= tx < r["x"] + r["w"] and r["y"] <= ty < r["y"] + r["h"]:
                return r
        return {"type": -1}


# ─── ASCII Rendering ────────────────────────────────────────────────────────
def render_ascii(grid: List[List[int]], transparent: List[List[bool]] = None, highlight_goal: Optional[tuple] = None) -> str:
    lines = []
    for y, row in enumerate(grid):
        line = ''
        for x, tile in enumerate(row):
            if highlight_goal and (x, y) == highlight_goal:
                line += '@'
            elif tile == WALL and transparent and transparent[y][x]:
                line += ':'
            elif tile == WALL:
                line += '#'
            elif tile == FLOOR:
                line += '.'
            elif tile == DOOR:
                line += 'D'
            else:
                line += ' '
        lines.append(line)
    return '\n'.join(lines)


def print_stats(result: dict, params: dict) -> None:
    grid = result["grid"]
    transparent = result.get("transparent")
    floor_tiles = sum(row.count(FLOOR) for row in grid)
    wall_tiles = sum(row.count(WALL) for row in grid)
    doors = sum(row.count(DOOR) for row in grid)
    rooms = len(result["rooms"])
    seed = result["seed"]

    print("-- Dungeon Stats --")
    print(f"  Seed:        {seed}")
    print(f"  Grid:        {params['GRID_W']}x{params['GRID_H']}")
    print(f"  Rooms:       {rooms}")
    print(f"  Floor tiles: {floor_tiles}")
    print(f"  Wall tiles:  {wall_tiles}")
    if transparent:
        tx_count = sum(sum(1 for c in row if c) for row in transparent)
        print(f"  Transparent: {tx_count} ({tx_count*100//max(wall_tiles,1)}%)")
    print(f"  Doors:       {doors}")
    print(f"  Total walk:  {floor_tiles + doors}")

    # Connectivity check
    dg = DungeonGen(params)
    dg.grid = [row[:] for row in grid]
    connected = dg._is_fully_connected()
    print(f"  Connected:   {connected}")

    # Room breakdown
    print(f"\n  Rooms by type:")
    type_counts = {}
    for r in result["rooms"]:
        tn = r["type"]
        type_counts[tn] = type_counts.get(tn, 0) + 1
    for tn in sorted(type_counts):
        print(f"    {ROOM_NAMES.get(tn, '?'):<12}: {type_counts[tn]}")


def interactive_mode(params: dict) -> None:
    last_seed = random.randrange(0, 2**31)
    print()
    print("=" * 60)
    print("  SPELLION - Dungeon Generator Sandbox")
    print("  Diablo 1 Cathedral (L5roomGen)")
    print("=" * 60)
    print()
    print("  Commands:")
    print("    <Enter>       Generate new random dungeon")
    print("    s N           Generate with seed N")
    print("    g             Show current params")
    print("    p KEY=VAL     Set param (p GRID_W=100, p ROOM_SIZES=[4,6,8])")
    print("    r N           Run N generations and show stats")
    print("    q             Quit")
    print()

    while True:
        try:
            cmd = input("> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if not cmd:
            dg = DungeonGen(params)
            result = dg.generate()
            last_seed = result["seed"]
            print()
            print(render_ascii(result["grid"], result.get("transparent")))
            print()
            print_stats(result, params)
            print()
        elif cmd.startswith("s "):
            seed = int(cmd[2:].strip())
            dg = DungeonGen(params)
            result = dg.generate(seed)
            last_seed = seed
            print()
            print(render_ascii(result["grid"], result.get("transparent")))
            print()
            print_stats(result, params)
            print()
        elif cmd == "g":
            print(json.dumps(params, indent=2))
            print(f"\n  Last seed: {last_seed}")
        elif cmd.startswith("p "):
            rest = cmd[2:].strip()
            if "=" in rest:
                key, val = rest.split("=", 1)
                key = key.strip()
                try:
                    val = json.loads(val)
                except:
                    pass
                params[key] = val
                print(f"  {key} = {val}")
            else:
                print("  Usage: p KEY=VALUE")
                print("  Examples:")
                print("    p GRID_W=100")
                print("    p ROOM_SIZES=[4,6,8]")
                print("    p MIN_FLOOR_TILES=600")
                print("    p SPINE_ROOM_SIZE=8")
        elif cmd.startswith("r "):
            count = int(cmd[2:].strip())
            stats = {"rooms": [], "floor": [], "walls": [], "doors": [], "connected": 0}
            for i in range(count):
                dg = DungeonGen(params)
                result = dg.generate()
                grid = result["grid"]
                floor_tiles = sum(row.count(FLOOR) for row in grid)
                wall_tiles = sum(row.count(WALL) for row in grid)
                doors = sum(row.count(DOOR) for row in grid)
                rooms = len(result["rooms"])
                dg2 = DungeonGen(params)
                dg2.grid = [row[:] for row in grid]
                conn = dg2._is_fully_connected()
                stats["rooms"].append(rooms)
                stats["floor"].append(floor_tiles)
                stats["walls"].append(wall_tiles)
                stats["doors"].append(doors)
                if conn:
                    stats["connected"] += 1
            avg = lambda v: sum(v) / len(v)
            print(f"\n  Results ({count} runs)")
            print(f"  Rooms:        {min(stats['rooms'])}--{max(stats['rooms'])} (avg {avg(stats['rooms']):.0f})")
            print(f"  Floor tiles:  {min(stats['floor'])}--{max(stats['floor'])} (avg {avg(stats['floor']):.0f})")
            print(f"  Wall tiles:   {min(stats['walls'])}--{max(stats['walls'])} (avg {avg(stats['walls']):.0f})")
            print(f"  Doors:        {min(stats['doors'])}--{max(stats['doors'])} (avg {avg(stats['doors']):.0f})")
            print(f"  Connected:    {stats['connected']}/{count}")
        elif cmd == "q":
            break
        else:
            print("  Unknown. Commands: <Enter>, s N, g, p KEY=VAL, r N, q")


# ─── CLI ────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Spellion Dungeon Generator Sandbox")
    parser.add_argument("--seed", type=int, default=-1, help="Random seed")
    parser.add_argument("--runs", type=int, default=0, help="Number of runs (stats only)")
    parser.add_argument("--params", type=str, default="{}", help="JSON param overrides")
    parser.add_argument("--export-params", action="store_true", help="Export current params as JSON")
    parser.add_argument("--interactive", action="store_true", help="Interactive mode")
    parser.add_argument("--no-ansi", action="store_true", help="Don't use ANSI colors")
    args = parser.parse_args()

    params = dict(DEFAULT_PARAMS)
    if args.params != "{}":
        params.update(json.loads(args.params))

    if args.export_params:
        print(json.dumps(params, indent=2))
        return

    if args.interactive or (args.seed == -1 and args.runs == 0 and not args.export_params):
        interactive_mode(params)
        return

    if args.runs > 0:
        print(f"Running {args.runs} dungeons with current params...")
        stats = {"rooms": [], "floor": [], "walls": [], "doors": [], "connected": 0}
        for i in range(args.runs):
            dg = DungeonGen(params)
            result = dg.generate()
            grid = result["grid"]
            floor_tiles = sum(row.count(FLOOR) for row in grid)
            wall_tiles = sum(row.count(WALL) for row in grid)
            doors = sum(row.count(DOOR) for row in grid)
            rooms = len(result["rooms"])
            dg2 = DungeonGen(params)
            dg2.grid = grid
            conn = dg2._is_fully_connected()
            stats["rooms"].append(rooms)
            stats["floor"].append(floor_tiles)
            stats["walls"].append(wall_tiles)
            stats["doors"].append(doors)
            if conn:
                stats["connected"] += 1

        avg = lambda v: sum(v) / len(v)
        print(f"\n── Results ({args.runs} runs) ──")
        print(f"  Rooms:        {min(stats['rooms'])}–{max(stats['rooms'])} (avg {avg(stats['rooms']):.0f})")
        print(f"  Floor tiles:  {min(stats['floor'])}–{max(stats['floor'])} (avg {avg(stats['floor']):.0f})")
        print(f"  Wall tiles:   {min(stats['walls'])}–{max(stats['walls'])} (avg {avg(stats['walls']):.0f})")
        print(f"  Doors:        {min(stats['doors'])}–{max(stats['doors'])} (avg {avg(stats['doors']):.0f})")
        print(f"  Connected:    {stats['connected']}/{args.runs}")
        return

    # Single dungeon
    dg = DungeonGen(params)
    result = dg.generate(args.seed)

    print(render_ascii(result["grid"]))
    print()
    print_stats(result, params)


if __name__ == "__main__":
    main()
