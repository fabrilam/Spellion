# Spellion — Changelog

## Sesión 2026-07-23 — Docs cleanup + Google Sheets workflow

**Commits:**
- `54e3e19` — tools: sheets.py (Google Sheets lectura/escritura), trigger `[SHEETS]` + git fetch al iniciar sesión
- `348a872` — Recuperar docs eliminados por Martin (GDD, scope, assets, process notes, TODO, etc.)

**Cambios:**
- Google Sheets integration via service account (lectura/escritura)
- Workflow: `git fetch` automático al arrancar sesión
- `[SHEETS]` trigger para leer/escribir spreadsheets desde opencode
- Reorganización de docs de diseño
- CHANGELOG.md creado

---

## Sesión 2026-07-22 — Orden de documentos (Martin)

**Commits:**
- `25f8a45` — Orden de documentos

**Cambios:**
- Martin reestructuró la carpeta docs/
- PDF de la novela movido a `docs/novel/`

---

## Sesión 2026-07-11 — Push masivo de sesiones Junio + Docs

**Commits:**
- `d93a72c` — Sesiones Junio 2026: items data-driven, sonidos Diablo SFX, Demon enemy, zoom, cursores, audio 4 canales, rings/amuletos, color rarity
- `fd0de4d` — Organizar docs de diseño en docs/ (GDD, scope, process notes, assets, tasks)

**Cambios:**
- **Sistema de items data-driven**: campo `material` en Item, 54 items marcados en JSON, `Item.drop_sound()` prioriza material sobre categoría
- **Sonidos Diablo 1 SFX**: `item_metal` → `diablo1_sfx/items/invsword.wav`, `item_leather` → `invbody.wav`, `item_cloth` → `invlarm.wav`
- **Shift pickup**: agarre de items solo con Shift, ataque bloqueado con Shift, sin Shift los items no interfieren
- **Cursores custom**: `openhand.png` (hover) y `closedhand.png` (drag)
- **Drag sprite centrado**: `drag_texture.position = mouse - size * 0.5`
- **Audio 4 canales**: Ch1 (player attacks), Ch2 (enemy impacts), Ch3 (player damage/death), Ch4 (items/UI)
- **Sonidos enemigos con variación**: `zombieh1/2`, `zombied1/2`, `fleshth1/2`, `fleshtd1/2`
- **Demon enemy**: modelo FBX + 6 animaciones (idle_loop, walk, run, attack, hit, die), sonidos `hdemonh1/2` + `hdemond1/2`, stats 1.3x speed + 1.5x daño
- **Rings/Amuletos**: 8 rings + 6 amulets con diferentes iconos, dropean como items generados (nunca básicos)
- **Botón debug**: "Spawn Generated" en stats screen
- **Color rarity**: blanco (common), azul (magic), dorado (rare), dorado+outline rojo (unique)
- **Zoom fino cámara**: min 3.0→1.5, step 2.0→0.5

---

## Sesión 2026-05-27 — Magic system + Floating damage + Dungeon level

**Commits:**
- `99f4f1b` — feat: magic system + floating damage + bow sounds + dungeon level + weapon rebalance

**Cambios:**
- Sistema de magia (spells, cast, mana)
- Floating damage numbers
- Sonidos de bow
- Nivel de mazmorra (dungeon level scaling)
- Rebalanceo de armas

---

## Sesión 2026-05-26 — Bow weapon + Arrow system + Ranged attack

**Commits:**
- `7446e7c` — feat: add bow weapon + ranged attack + entrance spawn exclusion zone
- `6180708` — feat: bow weapon + arrow system + dex scaling + enemy slow

**Cambios:**
- Arma de arco funcional
- Proyectiles de flecha
- Escalado por destreza (dex scaling)
- Enemigos con slow
- Zona de exclusión de spawn en entrada

---

## Sesión 2026-05-25 — Enemies + Sangre + Jira CLI

**Commits:**
- `6f9a676` — feat: add Super SPIDER boss enemy per dungeon + perimeter tiles + blood decal Y fix
- `32f6139` — Imports + Green Light Script Change
- `9bf59cd` — fix: enemy scale lost when rotating + add Jira CLI
- `7317775` — chore: remove Jira tools from repo (local only)

**Cambios:**
- Super SPIDER boss por mazmorra
- Perimeter tiles para mazmorras
- Blood decal system con corrección de posición Y
- Enemy scale fix (transform.basis overwrite)
- Jira CLI integration (luego removido a local)
- Green Light Script (imports de assets)

---

## Sesión 2026-05-19 — Inventario, items, armas, save/load

**Commits:**
- Setup inicial del proyecto

**Cambios (de process notes):**
- **Inventario completo**: grid 10×4 con drag & drop, equip slots (7), swap items, drop to world con modelo 3D
- **Items**: Resource `Item.gd` con escalado, grid, stats. Inventory con soporte multi-celda.
- **Daño por arma**: fórmula con scale de fuerza
- **Attack speed**: base + ganancia por agilidad + modificador por arma
- **Puños aleatorios**: `play_sfx_random("punch")` con 15 sonidos
- **World item pickup**: `item_world.gd` con Area3D, Label 2D, tecla E
- **Save/Load**: SaveManager (F5/F9 + botones Stats)
- **Decor transparencia**: `decor_fade.gd` para árboles/bush
- **Enemigos deambulan**: wander aleatorio
- **Rage orb**: orbe que buffea enemigos
- **Click sostenido ataca**: sin gate `_mouse_held`
- **Armas en mano**: 4 escenas `weapon_hand_X.tscn` en BoneAttachment3D
- **Assets descargados**: 15 sonidos punch, 11 sword, player_hit, orb_pickup, ui_click
- **Assets generados**: 5 armas low-poly procedurales (hand_axe, mace, flail, arrow, dagger)

---

## Sesión 2026-05-17 — Blood effects, sonidos, minimapa, bosque

**Commits:**
- Setup inicial del proyecto

**Cambios (de process notes):**
- **Sistema de sangre**: impact → particles → decals con tween secuencial
- **CPUParticles3D** para efectos (compatible GL Compatibility)
- **Sonidos Mixkit**: descarga automatizada vía `scripts/fetch_mixkit_sounds.py`
- **Minimapa** con `Control._draw()`
- **Enemigos con orientación**: `Basis.looking_at(-dir)`
- **SFXPlayer2** como segundo canal de audio para overlap
- **Decoración del bosque**: scatter con `forest_scatter.gd` + fade con `decor_fade.gd`
- **Z-fighting fix**: objetos 0.01u sobre el piso
- **Lecciones**: revisar `visible` antes de debuggear, `position` antes de `add_child`, shared materials require `.duplicate()`

---

## 2026-05-25 — Initial commit

**Commits:**
- `5d00b46` — chore: git config files
- `736a75f` — initial

**Cambios:**
- Setup del proyecto Godot 4.6
- Configuración de repositorio
- Estructura base del proyecto
