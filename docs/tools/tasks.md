# Tareas — Spellion

## Estado actual
- ✅ **Hecho** | 🔄 **En progreso** | ⏳ **Pendiente** | ❌ **Bloqueado** | 🗑️ **Cancelado**

---

## 🎮 Core Mecánico
- [x] Movimiento WASD + cámara isométrica (3/4)
- [x] Ataque básico (clic izquierdo)
- [x] Sistema HP/Maná
- [x] XP + subida de nivel + mejoras aleatorias
- [x] HP regen (vitality base + items)
- [x] MP regen display

## ⚔️ Combate
- [x] Enemy IA (persecución, ataque, wander)
- [ ] Esquivar (roll) — Espacio
- [x] Rage orbs (purple sky + red enemy drop)
- [x] Blood decals / VFX muerte
- [x] **Arco (ranged)** — weapon_hand_bow, animación cuerda, flecha Node3D+Area3D, se clava en paredes/enemigos
- [x] **Arrow slow** — enemigos ralentizados 80% por 1.5s al recibir flechazo

## 🧙 Magia / Habilidades
- [x] Bola de Fuego (proyectil, daño área) — sistema base funcional
- [ ] Escarcha (AoE ralentiza)
- [ ] Escudo de Maná (buff absorbe daño)
- [ ] Recupero (heal gradual)
- [ ] Invocar Esbirro
- [ ] Visión Alterna (revela enemigos)
- [ ] Ráfaga de Viento (knockback)
- [ ] Lluvia de Meteoros (ultimate)
- [ ] Sistema 4 slots equipables (Q/E/R/F)
- [ ] Pergaminos de Lonnird (magia mántrica)

## 🕹️ Controles
- [ ] Tecla I — Inventario (actual: TAB)
- [ ] Tecla C — Panel personaje
- [ ] Tecla F — Interactuar (actual: E)
- [x] Tecla Espacio — Esquivar
- [x] Shift — Lorefen ataque especial (placeholder)

## 🗺️ Zonas / Niveles
- [x] Bosque de Riverell (tutorial exterior)
- [ ] Mansión de Lazarian (interior cerrado)
- [ ] Montaña Kahen + Academia Spellion
- [ ] Ciudad de Aveli + Puerto Fischer
- [ ] Paedric — El Nether (final)

## 🏰 Dungeon (Cathedral procedural)
- [x] L5roomGen generación procedural (Diablo 1 estilo)
- [x] Tile system (VOID/FLOOR/WALL/DOOR)
- [x] Marching squares + interior walls
- [x] Wall transparency (regla Diablo 1)
- [x] Goal tile (piso arcoíris) + teleport + nivel
- [x] Luces por room
- [x] Escaleras de entrada
- [x] Border tiles (perímetro dungeon)
- [ ] Catacombs generator (variante nivel 2)
- [ ] Furniture procedural (cofres, barriles, altares)
- [ ] Trampas (fuego, flechas, pisos falsos)

## 👾 Enemigos
- [x] Spider (enemigo base melee + palette swap)
- [x] Super SPIDER (boss por dungeon, ×3 escala, luz)
- [x] HP bar hover + panel toggle
- [ ] Duendes / Goblins (melee rápido)
- [ ] Lobos / Lobos de Hielo (manada)
- [ ] Espectros / Apariciones (mansión)
- [ ] Guerreros del Inframundo (pesado)
- [ ] Arqueros del Inframundo (rango)
- [ ] Demonios (melee, explosivo, volador)
- [ ] Élites con modifiers (Veloz, Escudo, Vampírico)

## 👑 Jefes
- [ ] Manada de Lobos (tutorial)
- [ ] Sinnisgard (espectro, mansión)
- [ ] Oso de Montaña (Kahen)
- [ ] Eldein (Puerto Fischer)
- [ ] Varlord (Paedric)
- [ ] Requivar Dominis (final)

## 📦 Items / Loot
- [x] Sistema de inventario (grid)
- [x] Equipamiento (arma, armadura, 2 anillos, amuleto)
- [x] Weapons: sword, dagger, mace, axe, flail, **bow**
- [x] Save/Load con dedup
- [x] **DEX scaling system** — dex_scale en Item + Stats + save/load
- [x] **Weapon rebalance** — STR/DEX scales por tipo (Bow 0.3/0.9, Sword 0.6/0.1, Dagger 0.3/0.2, Axe 0.8/0.0, Mace 0.7/0.0)
- [ ] Gemas (Cuarzo, Citrino, Amatista) slot amuleto
- [ ] Orbe de Reyes (quest item / ultimate)
- [ ] Armor models en personaje
- [ ] World item visual (modelos 3D por item)
- [ ] Tooltips con comparación
- [ ] Rarezas (común, mágico, raro, único)

## 📈 Stats / Progresión
- [x] Stats screen (C)
- [x] **Bow speed bonus** — `bow_speed_bonus = -1.0` solo con bow equipado (base 2.0 para arcos)
- [ ] Hit chance, dodge, crit system
- [ ] 3 mejoras aleatorias al subir nivel
- [ ] Skill tree o desbloqueo por historia

## 📺 UI
- [x] HP/MP bars + XP bar
- [x] Minimap
- [x] Enemy HP panel (top-right, toggle)
- [x] HUD nivel de dungeon
- [ ] Skill bar (4 slots Q/E/R/F)
- [ ] Panel personaje completo
- [ ] Tooltips comparativos
- [ ] Diálogos con texto + retrato NPC
- [ ] Menú de pausa

## 🎬 Cinemáticas / Narrativa
- [ ] Apertura: rey asesinado por Varlord
- [ ] Sacrificio de Desmond
- [ ] Entrega del Orbe de Reyes
- [ ] Muerte de Aardin
- [ ] Regreso de Desmond
- [ ] Final: abrazo + ascenso
- [ ] Diálogos NPCs (Rey van Gunner, Aardin, Desmond)

## 🎨 Arte / Estética
- [x] Low-poly PS1 style
- [x] NES palette swap shader (enemies)
- [x] Pixel art textures
- [x] Luz roja Super SPIDER
- [ ] Lorefen (zorro de fuego) modelo + VFX llamas
- [ ] Efectos partículas habilidades
- [ ] Post-process / color grading

## 🔊 Audio
- [x] SFX básicos (hit, muerte, click, orb pickup)
- [ ] Música: Bosque (tensa)
- [ ] Música: Mansión (disonante)
- [ ] Música: Montaña (épica)
- [ ] Música: Spellion (majestuosa)
- [ ] Música: Ciudad/Batalla (marcial)
- [ ] Música: Paedric (infernal)
- [ ] Temas únicos por jefe
- [ ] SFX restantes (conjuros, puertas, rugido Lorefen)

## 🔧 Herramientas / Infra
- [x] Dungeon sandbox Python
- [x] Jira CLI local (tools/jira.py)
- [x] GitHub workflow triggers
- [ ] Export build pipeline
- [ ] Testing framework

## 🐛 Bugs conocidos
- [x] ~~Scale perdido por transform.basis~~ ✅
- [x] ~~Arrow no hacía daño (RigidBody bounce + collision layers)~~ ✅

---

*Última actualización: 26 mayo 2026*
