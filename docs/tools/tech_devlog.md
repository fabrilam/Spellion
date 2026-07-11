# Technical Devlog — Spellion

> Arquitectura, sistemas, decisiones técnicas y diseño de mecánicas.
> Complementa al GDD (diseño narrativo/gameplay) y PROCESS_NOTES (workflow MCP).

---

## 1. Engine & Config

| Parámetro | Valor |
|-----------|-------|
| Godot | 4.6.2 stable |
| Renderer | GL Compatibility (para pixel art + PS1 look) |
| Physics | Jolt Physics 3D |
| Scripting | GDScript |
| MCP Plugin | godot_mcp (yurineko73) |

### Project Settings clave
- `rendering/textures/canvas_textures/default_texture_filter=Nearest` (pixel art)
- `rendering/textures/vram_compression/import_etc2_astc=false`
- `physics/3d/active=true` con Jolt
- `input_devices/pointing/emulate_touch_from_mouse=true`

---

## 2. Arquitectura de Escenas (Main)

```
Main (Node3D)
├── CameraRig (Marker3D)        ← cámara isométrica ¾
├── WorldEnvironment              ← sky, ambient, fog
├── Sun (DirectionalLight3D)
├── Floor (MeshInstance3D)       ← piso de pasto enorme
├── Howard (CharacterBody3D)     ← player (instancia howard.tscn)
├── WaveSpawner (Node3D)         ← spawner de enemigos (bosque + dungeons)
├── HUD (CanvasLayer)            ← HP/MP/XP bars + nivel dungeon
├── StatsScreen                  ← panel de stats (C)
├── InventoryScreen              ← inventario grid (TAB)
├── EnemyHPBars (CanvasLayer)    ← hover bars sobre enemigos
├── EnemyHPPanel                 ← panel top-right últimos hit
├── Minimap                      ← minimapa esquina
├── Forest (Node3D)              ← árboles/rocas decorativos
├── PurpleOrbSpawner (Timer)     ← orbes púrpura del cielo
└── Dungeon (Node3D)             ← dungeon procedural
    ├── FloorMesh                ← merged mesh de pisos
    ├── BorderMesh               ← tiles de perímetro
    ├── WallSection_*            ← walls individuales (transparencia por tile)
    ├── Light_*                  ← omni lights por room
    ├── GoalArea                 ← goal tile (teletransporte + rainbow)
    └── Stair*                   ← escaleras de entrada
```

---

## 3. Sistemas Core

### 3.1 Dungeon Generator (L5roomGen)

**Archivos:** `scripts/dungeon/`
- `tile_definition.gd` — Enums `TileType` (VOID/FLOOR/WALL/DOOR) y `RoomType`
- `dungeon_generator.gd` — Generación estilo Diablo 1 Cathedral (L5roomGen)
- `dungeon_visualizer.gd` — Construye meshes, coloca luces, spawn enemies, goal tile

**Algoritmo L5roomGen:**
```
1. Generar spine (2-3 rooms de 8×8 conectadas por corredor de 1 tile)
2. Desde primera spine room, budding axis-alternante:
   axis=0: intenta LEFT (x-cw), luego RIGHT (x+w)
   axis=1: intenta UP (y-ch), luego DOWN (y+h)
3. 25% de chance de cambiar eje en cada recursión
4. Room sizes: (randint(0,5)+2) & ~1 × 2 → {4, 8, 12}
5. Máximo 20 intentos por room
6. Build walls (marching squares: VOID→WALL si adyacente a FLOOR)
7. Interior walls + connectivity check
8. Corner fill + pillar removal
```

**Transparencia de paredes (regla Diablo 1):**
- Una WALL es transparente si el tile al norte (y-1) es FLOOR o DOOR
- Se calcula UNA VEZ en generación, no por frame
- Las transparentes se renderizan con alpha=0.3

**Goal tile:**
- El tile de FLOOR más lejano del spawn (mín 20 tiles de distancia)
- Animación HSV hue cycling (0.15/s)
- Al tocarlo: teletransporta a spawn, mata enemigos, regenera dungeon, +1 nivel
- Rainbow floor material con emission

### 3.2 Enemy System

**Archivos:** `scripts/enemy.gd`, `scripts/super_spider.gd`
- Extiende `CharacterBody3D`
- IA: wander → detect player (vision range) → chase → attack (melee)
- Level scaling: `hp=18+lvl*20`, `dmg=3+lvl*3.8`, `speed=1.15+lvl*0.12`, `scale=0.54+lvl*0.08`
- Palette swap via shader (`palette_swap3d.gdshader`) — distance-based color replacement (NES style)

**⚠️ Bug crítico resuelto:**
- `transform.basis = Basis.looking_at(...)` **destruye la escala** porque basis contiene rotación + escala
- Fix: guardar `scale` antes y restaurar después del looking_at
- Afectaba wander (line 291) y `_look_at_player()` (line 304)
- Solo se notó tras meses — todas las arañas tenían el mismo tamaño

### 3.3 Orb System

| Orb | Source | Efecto | Pickup |
|-----|--------|--------|--------|
| Red (`orb_rage_red`) | Enemy drop (45%) | Rage a TODOS los enemigos | Solo player |
| Purple (`orb_rage`) | Cielo (wobble, timer 6-15s cerca de enemigos) | Enemy consume → level up (max 10) | Enemies |
| Life (`orb_of_life`) | Enemy drop (20%) | Heal player | Player |

- Orbs despawnean a los 180s
- Sky spawner actualmente deshabilitado

### 3.4 Inventory / Save System

**Grid inventory:**
- Sistema de celdas (grid) con items multi-celda
- Equip slots: arma, armadura, 2 anillos, amuleto
- Items guardados en JSON con posiciones de grid

**Save/Load:**
- Save: exporta items deduplicados (multi-cell guardados en top-left)
- Load: limpia grid + equip, restaura con bounds-safe `_place()` y fallback `add_item()`
- Stats persistidos (vitality, strength, agility, etc.)

### 3.5 Weapon System

- Escenas por arma: `weapon_hand_sword.tscn`, `weapon_hand_dagger.tscn`, etc.
- Hijos permanentes de `SwordAttach` (toggle visibility según arma equipada)
- Stats por arma: `str_scale`, `dex_scale`, `base_damage_min/max`, `atk_speed_mod`
- Default sword: str_scale 0.4/0.7, base 4-7, atk_speed_mod -0.5, grid 2×3

---

## 4. Stats & Balance

### HP Regen
- `_hp_regen = vitality * 0.02 + _hp_regen_add`
- Ultra-conservador nativo: ~0.06/s a vit 3
- Damage interrumpe regen por 5s
- Aplica en ticks de 100ms
- Bloodletter sword: +1.0/s regen, +2.0 attack speed

### Stats Base
- Speed: 2.75 (player base), attack speed: 3.0 base
- Agility: +0.015 attack speed por punto
- Enemy speed: 1.25 + lvl*0.12

### Damage Formula
- Daño físico: `str_scale * strength + dex_scale * agility + base_damage`
- Rango: min-max según arma

---

## 5. UI Systems

### HP Bar (Hover vs Panel)
- Two modes toggle desde character menu
- **Hover**: barra sobre cada enemigo al pasar mouse
- **Panel**: últimas 3 arañas hit, top-right, 5s timeout
- Preferencia guardada en player meta

### Minimap
- Renderiza dungeon grid en tiempo real
- Colores: walls=dark, floor=gray, doors=brown, enemies=red
- Se actualiza al regenerar dungeon

---

## 6. Herramientas

| Herramienta | Propósito |
|------------|-----------|
| `tools/dungeon_sandbox.py` | Prototipado ASCII de L5roomGen (standalone Python) |
| `tools/jira.py` | CLI para Jira (crear/listar/update issues) — local only |
| `tools/tasks.md` | Lista de tareas basada en GDD — local only |
| `tools/export_sessions/` | Exportador de sesiones de chat a HTML |

---

## 7. Dependencias Externas

- **Modelos**: Kenney, Mixamo, assets propios de Martin
- **Audio**: rfx_sfx_database, Mixkit, Freesound
- **Font**: AmazDooMLeft (Doom-style)
- **Texturas**: ambientCG (rock), generación propia pixel art
- **Addons**: godot_mcp (MCP server)

---

## 8. Controles

| Acción | Tecla |
|--------|-------|
| Moverse | WASD |
| Ataque | Clic izquierdo |
| Stats | C |
| Inventario | TAB |
| Pickup | E |
| Save | F5 |
| Load | F9 |

---

*Última actualización: 26 mayo 2026*
