# SCOPE — SPELLION

## EQUIPO

| Rol | Persona | Habilidades clave |
|-----|---------|-------------------|
| Programador / Game Designer / Niveles | Fabricio (vos) | Programación Godot, VFX 2D, animaciones, game design, level design, scripting |
| Artista 3D / UI/UX | Martin | Modelado 3D, animación 3D (autorigging), texturas, UX/UI, diseño de menús |
| Sonido y Música | Fede | SFX, música, diseño de audio |

## CRONOGRAMA — 12 MESES

| Mes | Fase | Fabricio (prog) | Martin (arte) | Fede (audio) |
|-----|------|-----------------|---------------|--------------|
| 1-3 | **MVP** | Movimiento, combate básico, 1 habilidad, XP/loot, UI framework, enemigo IA simple, herramientas nivel | Player + 1 enemigo (modelos + anims), geometría mapa, wireframes UI menús | SFX: ataque, hit, muerte, click |
| 4-7 | **ALFA** | Loot completo (stats, rarezas), 4 habilidades, IA 4 enemigos, mazmorras procedurales, balance | 3 enemigos + assets 3 zonas (Bosque/Montaña/Mansión), UI final, VFX partículas | Música: Bosque, Montaña, Mansión. SFX habilidades |
| 8-10 | **BETA** | IA jefes (4), zonas Ciudad+Nether, save/load, menús, post-process, polish | 4 jefes + assets Ciudad+Nether, anims restantes, VFX finales | Música: Ciudad, Nether, boss themes. SFX completos |
| 11-12 | **GOLD** | Bugfixing, optimización, build distribution, balance final | Pulido visual, optimización texturas, ajustes UI | Mezcla final, masterización |

---

## FASE 1 — PROTOTIPO (MVP) ~Meses 1-3

### Core mecánico
- Movimiento WASD + cámara isométrica
- Ataque básico (clic izquierdo) con animación
- 1 habilidad equipable (Bola de Fuego)
- 1 tipo de enemigo melee que spawnea en oleadas
- Sistema de HP / Maná básico (sin regeneración automática)
- XP y subida de nivel (+ elegir 1 de 3 mejoras)
- 1 zona jugable: Bosque (1 mapa, combate infinito tipo arena)

### Arte
- 1 personaje jugador (modelo + textura + anim idle/walk/attack)
- 1 enemigo (modelo + textura + anim idle/walk/attack)
- 1 mapa de prueba geometría simple (paredes, piso, sin decoración)

### Entregable: Build jugable con combate y progresión básica

---

## FASE 2 — ALFA ~Meses 4-7

### Gameplay completo
- 4 habilidades equipables (Fuego, Escarcha, Escudo, Invocar)
- 4 tipos de enemigos (melee, rango, explosivo, 1 élite)
- Sistema de loot completo (5 slots, 3 rarezas, stats aleatorios)
- 3 zonas completas: Bosque, Montaña, Mansión
- Mazmorras procedurales con 3 habitaciones cada zona
- UI completa (inventario, panel personaje, tooltips, minimapa)
- Esquiva (roll) con invulnerabilidad
- 1 jefe de zona (Bosque)

### Arte
- Modelos de enemigos restantes (3)
- Decoración de mapas (árboles, rocas, muebles)
- Íconos de habilidades e ítems
- Efectos VFX: fuego, escarcha, partículas de muerte
- UI wireframes + assets finales

### Entregable: Build alfa con ciclo de juego completo

---

## FASE 3 — BETA ~Meses 8-10

### Contenido final
- Zonas restantes: Ciudad y Nether
- 2 jefes adicionales (Montaña, Mansión) + jefe final (Nether)
- Habilidades ultimate (Lluvia de Meteoros)
- Sistema de rarity Unique con efectos especiales
- Mejoras visuales: post-process (color grading retro)
- Balance de dificultad y loot tables
- Pulido de animaciones y transiciones

### Arte
- Jefes (modelos + VFX + patrones de ataque)
- Assets de Ciudad y Nether
- Animaciones adicionales (cast, hit, death para cada enemigo)
- Música completa por zona
- SFX completos

### Entregable: Build beta con contenido completo, lista para test

---

## FASE 4 — GOLD / RELEASE ~Meses 11-12

- Bug fixing
- Optimización (draw calls, texturas, LOD básico)
- Menú principal + pantalla de carga
- Guardado/carga de partida
- Ajustes de dificultad y balance final
- Build de distribución

### Entregable: Release v1.0

---

## FUERA DE SCOPE (Stretch Goals)

- Multijugador / cooperativo
- Sistema de modding
- Nuevas zonas post-release
- Mapa del mundo interconectado (en lugar de selección por menú)
- Árbol de habilidades profundo (talentos)
- Crafting de ítems
- Mercader / NPCs
