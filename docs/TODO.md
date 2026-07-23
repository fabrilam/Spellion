# Spellion — Task Tracker

## ✅ Hecho — Sesión 2026-06-09

- [x] **Sonidos items desde Diablo 1 SFX**: `item_metal` → `diablo1_sfx/items/invsword.wav`, `item_leather` → `invbody.wav`
- [x] **Material system**: campo `material` en Item, 54 items marcados en JSON, `Item.drop_sound()` prioriza material
- [x] **item_cloth**: `diablo1_sfx/items/invlarm.wav` para Robe, Tunic, Cape, Cap, Hood, etc.
- [x] **Shift gate**: pickup solo con Shift, ataque bloqueado con Shift, sin Shift los items no interfieren
- [x] **Cursores custom**: `openhand.png` abierta sobre items, `closedhand.png` durante drag
- [x] **Drag centrado**: `drag_texture.position = mouse - size * 0.5`
- [x] **Sonidos enemigos con variación**: `zombieh1/2`, `zombied1/2`, `fleshth1/2`, `fleshtd1/2`
- [x] **Audio 4 canales**: combat (Ch1), enemy impacts (Ch2), player damage (Ch3), items/UI (Ch4)
- [x] **Demon enemy**: modelo FBX + 6 animaciones (idle_loop, walk, run, attack, hit, die), sonidos `hdemonh1/2` + `hdemond1/2`, stats 1.3x speed + 1.5x daño, wave_spawner integrado

- [x] **Blood system**: 5 droplets + raycast colisión + wall drip 5x. Revisar visualmente.
- [x] **Indicador de puntería**: cilindro (color cycling + pulse + 0.8m tall + alpha 0.1).
- [x] **Tooltip stats**: Damage, Speed, Defense, efectos mágicos en hover. Font size aumentado.
- [x] **Sonidos**: orb_pickup al dropear, ui_click al equipar, potion_drink al usar poción.
- [x] **Loot system**: 3 ramas separadas: básico (10%), único (5%), generado (65%) + potions (20%).
  - Magic (75%): prefijo O sufijo O ambos (60% c/u).
  - Rare (25%): prefijo + sufijo + 1-3 extras (70% valor).
  - ItemGenerator.generate() con 24 efectos mágicos.
- [x] **Rampa entrada dungeon**: colisión trimesh + escalones visuales. Rotación, posición ajustada a Z=-2.5.
- [x] **Gravedad player/enemigos**: velocity.y += -15 * delta. Player delay 60 frames al inicio.
- [x] **Enemy markers**: desaparecen del minimapa al morir.
- [x] **Enemy floor snap**: raycast piso + move_and_slide al morir.
- [x] **Puños sin trail**: solo se activa con arma equipada.
- [x] **Potion use**: right-click consume (hp/mp restore 3s). Sonido potion_drink. ✅
- [x] **Pickup con TAB abierto**: Diablo style — item desaparece del mundo, cursor drag sobre grid.
  - `start_world_drag()` → drag icon → suelta en grid o fuera (raycast cursor + max 5m).
  - `_drop_to_world()` con raycast a cursor position, clamp 5m.
- [x] **Fresh click pickup**: flag `_mouse_left_down` evita pickup sostenido.
- [x] **World items cooldown**: 1s antes de ser agarrables.
- [x] **World items icono**: siempre Sprite3D billboard, 50% más grande (pixel_size 0.0075).
- [x] **Trail**: samplea cada frame, fade 0.2s, max_samples=15, gradiente cuadrático max_alpha 0.5.
  - Ring buffer, usa `color_modulate` del item (Bloodletter → rojo).
  - Sección CONFIG con `max_alpha`, `fade_power`, `trail_len`, etc.
- [x] **Trail_type system**: dispatcher por tipo, `"tracer_modulated"` en 49 items.
- [x] **Aim marker**: cilindro en vez de anillo. Color cycling + pulsing scale.
- [x] **Mana regen nerf**: `0.5 + intelligence * 0.1` (antes 2.0 + 0.5).
- [x] **Enemy slide fix**: `velocity.xz = 0` al atacar.
- [x] **TORSO/LEFT_HAND slots**: mapping corregido (swap).
- [x] **Dungeon floor collision**: DOOR tiles incluidos.
- [x] **Exterior floor collision**: trimesh desde IDE.
- [x] **Grid sizes**: 0 mismatches. Todos revisados.
- [x] **Bordes blancos iconos**: limpiados 157 iconos. Backup.
- [x] **Bucklers**: steel 60×64 [2,2], wooden 60×60 [2,2].
- [x] **Daga icon**: cropeada 32×88→32×64, grid [1,2].

## ✅ Efectos mágicos — Estado

### ✅ Funcionan completamente (12)
- **hp_regen** → bonus → `_update_derived` → `regen_hp()`
- **mana_regen** → bonus → `_update_derived` → `regen_mana()`
- **max_hp** → bonus → `_update_derived` → `get_max_hp()`
- **max_mana** → bonus → `_update_derived` → `get_max_mana()`
- **movement_speed** → bonus → `_update_derived` → `get_speed()` → `_physics_process`
- **stat_strength/agility/intelligence/vitality** → bonus → total stats → daño/hp/mana
- **life_steal** → `_life_steal` → `_apply_sword_window()`
- **mana_steal** → `_mana_steal` → `_apply_sword_window()`
- **fire/cold/lightning/poison_damage** → `_bonus_elemental` → sumado a `dmg` en `_apply_sword_window()`
- **defense** → `item.stats.defense` → `set_equip_defense()` → `get_defense()`
- **attack_speed** → `item.stats.atk_spd` → `set_attack_speed_mod()`

### ⚠️ Se guardan y muestran pero NO aplican (2)
- **critical_chance** → `get_crit_chance()` funciona, stats screen lo muestra, pero `_apply_sword_window()` nunca lo usa (no multiplica daño por crítico)
- **spell_damage** → `get_spell_damage()` funciona, stats screen lo muestra, pero `_cast_current_spell()` nunca lo suma al daño (línea 782 usa solo `intelligence * 0.25`)

### ⏸️ Sin runtime aún (18)
knockback, splash, pierce, life_on_kill, fire/cold/lightning/poison_resist, magic_resist, all_resist, thorns, magic_find, gold_find, stat_buffs (ya implementados), light_radius, stun, mana_shield

- [ ] **Aplicar efectos mágicos en runtime** — hp_regen, max_hp, fire_damage, critical_chance, etc. Loop genérico en `_on_item_equipped()` y `_apply_sword_window()`.
- [ ] **Arrow trajectory trail** — línea curva mostrando adónde va la flecha.
- [ ] **Right-click equip** — click derecho sobre item en grid → equipa.
- [ ] **Sistema de resistencias** — fire/cold/lightning/poison_resist.
- [ ] **Knockback, thorns, splash, pierce, life_on_kill, mana_steal, magic_find, gold_find**.
