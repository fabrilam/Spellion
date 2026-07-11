# Asset Sources — Spellion (Free / Royalty-Free 3D Models)

> Investigación: 28 mayo 2026
> Fuentes verificadas con descarga directa, sin API keys ni registro obligatorio.

---

## 🥇 Quaternius — CC0, animado, ideal para Spellion

**URL:** https://quaternius.com
**Licencia:** CC0 (dominio público, sin atribución)
**Formato:** .glb, .blend, .fbx
**Download:** Directo desde cada pack page (sin API, sin login)

### Packs relevantes para Spellion

| Pack | Contenido | Animado |
|------|-----------|---------|
| **Ultimate Monsters** | Yeti, cactus, panda, bee, demon, ghost, mushroom, alien, crab, dragon, skull, slime, bird | ✅ Sí |
| **RPG Character Pack** | Knight, wizard, monk, ranger, assassin, dungeons | ✅ Sí |
| **Ultimate Animated Character** | Elf, zombie, ninja, cowboy, wizard, goblin, fighter, viking, chef | ✅ Sí |
| **Cute Animated Monsters** | Yeti, cactus, panda, bee, cthulhu, demon, pig, ghost, mushroom, penguin, crab, dragon, skull | ✅ Sí |
| **Easy Enemy Pack** | Bee, wasp, snake, rat, spider, frog | ✅ Sí |
| **Animated Monster Pack** | Dragon, skeleton, bat, slime | ✅ Sí |
| **Animated Dinosaur Pack** | T-Rex, triceratops, velociraptor, stegosaurus, apatosaurus | ✅ Sí |
| **Animated Knight Pack** | Knight with sword + helmet + medieval | ✅ Sí |
| **Modular Weapons Pack** | Sword, dagger, bow, arrow, shield, axe, hammer, scythe | ❌ Static |
| **Fantasy Props MegaKit** | Potion, chest, cauldron, candle, book, crate, barrel, blacksmith, wizard items | ❌ Static |
| **RPG Essentials Pack** | Sword, dagger, helmet, staff, book, gems, shield, barrel, necklace, armor, coins, key, crown, chest, potion, rings | ❌ Static |
| **Medieval Village MegaKit** | Cabins, village houses, walls, windows, wagons, medieval modular | ❌ Static |
| **Modular Dungeon Pack** | Dungeon tiles, barrels, chests, carpets, isometric | ❌ Static |
| **Ultimate Modular Ruins** | Columns, bookcases, doors, crates, barrels, statues | ❌ Static |
| **3D Card Kit - Fantasy** | Knight, slime, elements, archer, fireball, spells (card-style) | ❌ Static |
| **Modular Character Outfits - Fantasy** | Knight, medieval, fantasy, retargeteable | ✅ Sí |
| **Furniture Pack / Ultimate House Interior** | Chairs, tables, lights, couches, shelves, beds, kitchen, bathroom | ❌ Static |
| **Ultimate Food Pack** | Pizza, hamburger, vegetables, fruit, sushi, chicken, donuts, pancakes | ❌ Static |

### Download example (curl)
```bash
# Los packs se descargan desde la página de cada uno.
# Ej: Ultimate Monsters → https://quaternius.com/packs/ultimatemonsters.html
# Los links directos .glb están en el source de la página.
```

---

## 🥈 Kenney — CC0, assets placeholder + UI

**URL:** https://kenney.nl/assets
**Licencia:** CC0
**Formato:** .glb, .png, .obj, .svg
**Download:** Directo desde cada asset page

### Packs relevantes

| Pack | URL |
|------|-----|
| **Prototype Kit** | https://kenney.nl/assets/prototype-kit |
| **UI Pack** | https://kenney.nl/assets/ui-pack |
| **Fantasy UI** | https://kenney.nl/assets/fantasy-ui |
| **RPG Audio** | https://kenney.nl/assets/rpg-audio |
| **Impact Sounds** | https://kenney.nl/assets/impact-sounds |
| **Magic Sounds** | https://kenney.nl/assets/magic-sounds |

### Download example
```bash
curl -L https://kenney.nl/data/kenney/assets/prototype-kit.zip -o prototype-kit.zip
```

---

## 🥉 OpenGameArt — Comunidad, licencias variadas

**URL:** https://opengameart.org
**Licencia:** CC0, CC-BY, GPL (filtrar por CC0 + 3D)
**Formato:** Variable (.blend, .fbx, .obj, .glb)
**Download:** Directo desde cada asset page

### Búsqueda recomendada
```
https://opengameart.org/art-search-advanced?keys=&field_art_type_tid[]=10&sort_by=count&sort_order=DESC
```
Filtrar por licencia CC0 y tipo "3D Art".

### Download example
```bash
wget https://opengameart.org/sites/default/files/asset-name.zip
```

---

## Texturas PBR — CC0

| Fuente | URL | Formato | Download |
|--------|-----|---------|----------|
| **AmbientCG** | https://ambientcg.com | .png, .exr | `curl -O https://ambientcg.com/get?id=Rock034` |
| **PolyHaven** | https://polyhaven.com | .png, .hdr | Directo desde la página |

---

## Animaciones humanoides

| Fuente | URL | Licencia | Método |
|--------|-----|----------|--------|
| **Mixamo (Adobe)** | https://mixamo.com | Gratis comercial | Requiere cuenta Adobe + UI web. No apto para scripting |
| **Quaternius** | https://quaternius.com | CC0 | Packs animados incluidos (.glb) |

---

## Lo que NO funciona / no recomendado

| Fuente | Motivo |
|--------|--------|
| **Sketchfab** | Requiere cuenta para descargar, no apto para scripting |
| **TurboSquid** | Mayoría pago, free limited |
| **Free3D** | Calidad baja, licencias dudosas |
| **CGTrader** | Mayoría pago |

---

## Recomendación para Spellion

### Prioridad 1: Quaternius
Descargar los packs animados primero (monstruos, personajes) que ya vienen con animaciones listas en .glb. Godot los importa nativamente. No requieren retargeting.

### Prioridad 2: AmbientCG
Texturas PBR para pisos, paredes de dungeon, rocas.

### Prioridad 3: Mixamo (manual)
Si se necesita una animación específica que no tengan los packs de Quaternius (ej: cast de hechizo específico), descargar manualmente desde Mixamo.

### Nota técnica
- .glb se importa directo en Godot 4 con `nodes/apply_root_scale=true`
- .fbx requiere importación con el FBX importer de Godot (puede tener problemas de escala/rotación)
- Los packs animados de Quaternius usan un rig humanoide universal retargeteable entre sí
