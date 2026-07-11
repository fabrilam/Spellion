# LISTA DE ASSETS — SPELLION

---

## 1. MODELOS 3D

### Personajes
| Asset | Polígonos | Animaciones | Prioridad |
|-------|-----------|-------------|-----------|
| Jugador (Spellion) | ~400 tris | Idle, Walk, Attack, Cast, Roll, Hit, Death | MVP |
| Esbirro invocado | ~200 tris | Idle, Walk, Attack, Death | Alfa |

### Enemigos
| Asset | Polígonos | Variantes | Animaciones | Prioridad |
|-------|-----------|-----------|-------------|-----------|
| Esqueleto (melee) | ~300 tris | 2 skins | Idle, Walk, Attack, Death | MVP |
| Arquerolich (rango) | ~350 tris | 1 skin | Idle, Walk, Shoot, Death | Alfa |
| Slime explosivo | ~150 tris | 1 skin | Idle, Idle (vibrar), Explode | Alfa |
| Élite (esqueleto grande) | ~450 tris | 1 skin + modifiers vis | Idle, Walk, Attack, Death | Alfa |
| Jefe Bosque (Ent) | ~600 tris | — | Idle, Walk, Slam, Spawn, Death | Alfa |
| Jefe Montaña (Golem) | ~700 tris | — | Idle, Punch, GroundSlam, Death | Beta |
| Jefe Mansión (Fantasma) | ~500 tris | — | Idle, Float, Possess, Summon, Death | Beta |
| Jefe Nether (Demonio final) | ~900 tris | — | Idle, All abilities, Transform, Death | Beta |

### Escenario
| Asset | Cantidad | Prioridad |
|-------|----------|-----------|
| Piso/textura suelo (por zona) | 5 variantes | MVP |
| Paredes / muros | 5 sets (1 por zona) | MVP |
| Puertas (madera, piedra, hierro, nether) | 4 | Alfa |
| Árboles | 3 variantes | Alfa |
| Rocas | 3 variantes | Alfa |
| Muebles mansión (mesa, silla, estante) | 5 | Alfa |
| Decoración ciudad (faroles, carromatos) | 4 | Beta |
| Decoración nether (pilares, ojos flotantes) | 4 | Beta |
| Cofres / loot containers | 2 | Alfa |
| Pozo de teletransporte | 1 | Beta |

---

## 2. TEXTURAS

| Textura | Resolución | Cantidad | Prioridad |
|---------|-----------|----------|-----------|
| Personajes (atlas) | 128x128 | 10+ | MVP |
| Enemigos (atlas) | 128x128 | 8+ | MVP |
| Suelo por zona | 64x64 - 128x128 | 10 | MVP |
| Paredes por zona | 128x128 | 10 | Alfa |
| Decoración | 64x64 - 128x128 | 15 | Alfa |
| UI / paneles | 256x256 | 20 | Alfa |
| Partículas / efectos | 32x32 - 64x64 | 10 | Alfa |
| Cielo / skybox | 256x256 | 5 | Beta |
| Íconos de ítems | 32x32 | 30+ | Alfa |
| Íconos de habilidades | 32x32 | 10+ | Alfa |

---

## 3. UI / INTERFAZ

| Asset | Cantidad | Prioridad |
|-------|----------|-----------|
| Barra de vida / maná / XP | 3 barras + background | MVP |
| Slots de habilidades (4) | 4 slots + border highlight | Alfa |
| Marco de inventario | 1 ventana + slots | Alfa |
| Marco panel personaje | 1 ventana | Alfa |
| Tooltip genérico | 1 template | Alfa |
| Botones (genérico) | 3 estados (normal, hover, pressed) | Alfa |
| Minimapa | border + frame | Alfa |
| Pantalla de carga | 1 fondo | Beta |
| Menú principal | background + botones | Beta |
| Fuente (bitmap retro) | 1 font .woff | MVP |

---

## 4. AUDIO

### Música (loops)
| Pista | Prioridad |
|-------|-----------|
| Bosque (ambient tenso) | Alfa |
| Montaña (épico) | Beta |
| Mansión (oscuro, misterioso) | Beta |
| Ciudad (melancólico) | Beta |
| Nether (agresivo, distorsionado) | Beta |
| Jefe (tema de batalla) | Beta |
| Menú principal | Beta |

### SFX
| Efecto | Cantidad | Prioridad |
|--------|----------|-----------|
| Ataque básico (hit) | 2 variantes | MVP |
| Daño recibido | 2 variantes | MVP |
| Muerte enemigo | 4 variantes | MVP |
| Lanzar habilidad (fuego, escarcha, etc) | 4 | Alfa |
| Esquivar (roll) | 1 | Alfa |
| Subir de nivel | 1 | Alfa |
| Recoger oro / item | 2 | Alfa |
| Click UI | 1 | Alfa |
| Puerta abrirse | 1 | Alfa |
| Jefe ataque / rugido | 4 | Beta |
| Muerte jugador | 1 | Beta |
| Ambiental (viento, pasos) | 3 | Beta |

---

## 5. VFX (PARTÍCULAS)

| Efecto | Prioridad |
|--------|-----------|
| Bola de Fuego (proyectil + explosión) | Alfa |
| Escarcha (área congelada + partículas) | Alfa |
| Escudo de Maná (brillo alrededor) | Alfa |
| Esbirro (nube de invocación) | Alfa |
| Ráfaga de Viento (líneas de aire) | Beta |
| Lluvia de Meteoros (proyectiles + impacto) | Beta |
| Golpe crítico (destello) | Alfa |
| Muerte enemigo (nube de humo / almas) | Alfa |
| Moneda / loot al dropear (brillo) | Alfa |
| Level up (explosión de luz) | Alfa |
| Portal / teletransporte | Beta |

---

## 6. ANIMACIONES (TOTAL)

| Animación | Cantidad de personajes que la usan |
|-----------|-----------------------------------|
| Idle | Todos (8+ personajes) |
| Walk | Jugador + enemigos melee + jefes |
| Attack (melee) | Jugador, esqueleto, élite, jefes |
| Attack (rango) | Arquerolich |
| Cast / Shoot | Jugador + arquerolich |
| Roll / Dodge | Solo jugador |
| Hit | Jugador + todos los enemigos |
| Death | Todos |
| Explode | Slime explosivo |
| Spawn / Invocar | Jefe bosque, fantasma, jugador (invocar esbirro) |
| Transform | Jefe Nether |
| Float | Fantasma |

---

## RESUMEN POR FASE

| Fase | Modelos | Texturas | Animaciones | UI | Audio | VFX |
|------|---------|----------|-------------|----|-------|-----|
| **MVP** | 3 (player, esqueleto, mapa) | 5 | 12 | 3 barras | 4 SFX | 0 |
| **Alfa** | +14 | +50 | +40 | +25 | +15 SFX + 1 música | +8 |
| **Beta** | +10 | +15 | +15 | +5 | +4 músicas + 6 SFX | +3 |
