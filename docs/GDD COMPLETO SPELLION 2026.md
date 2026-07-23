# GDD COMPLETO — SPELLION 2026

---

# PARTE 1: GAME DESIGN DOCUMENT

## 1. OVERVIEW

| Campo | Valor |
|-------|-------|
| Título | Spellion |
| Género | Diablo-like / Hack & Slash / Action RPG |
| Plataforma | PC (Godot Engine 4) |
| Cámara | Isométrica (top-down, ¾) |
| Estética | 3D poligonal estilo PS1 (low-poly con texturas pixeladas) |
| Target | Jugadores de Diablo clásico, grimdark, retro 3D |
| Inspiración narrativa | Novela original "Spellion" de Martín Arro (2025) |
| Equipo | Fabricio (prog/game design), Martin (3D/UI), Fede (audio) |

## 2. ADAPTACIÓN NARRATIVA

La novela original **no fue concebida como videojuego**. Esta adaptación reestructura la trama en 5 actos jugables, condensando eventos y reordenando ubicaciones para crear un flujo de gameplay Diablo-like, manteniendo fidelidad a personajes, eventos clave y lore.

### Cambios respecto a la novela para adaptación a videojuego:
- **Protagonista**: Howard es el personaje jugable. La novela sigue a Howard como un hechicero nómada en busca de su hermano Desmond.
- **Lorefen** (zorro de fuego) es acompañante permanente, ayuda en combate y narrativa.
- **Spellion** no es el nombre del protagonista — es el nombre de la Academia de Magia.
- Los eventos se condensan: cada zona del juego representa un arco narrativo completo.
- Se añaden hordas de enemigos y combates masivos propios del género Diablo-like.
- Diálogos breves con NPCs clave (Rey van Gunner, Aardin, Desmond) mediante texto en pantalla.

## 3. HISTORIA (SINOPSIS)

En el reino de **Mistralis**, el rey van Ellen de Nealand ha sido asesinado por **Varlord**, el Caballero del Inframundo, quien busca dominar el reino mediante el poder de la **magia mántrica** (oscuridad). 

**Howard**, un hechicero nómada, llega a la región de **Mirland** buscando a su hermano menor **Desmond**, quien ha desaparecido. Su búsqueda lo lleva al pueblo de Riverell, donde conoce a **Lorefen**, un zorro de fuego —una criatura mágica en peligro de extinción— y juntos rescatan a Desmond de una mansión embrujada.

Los hermanos descubren que Desmond posee un poder arcano inmenso en su sangre, y que Varlord busca asesinarlo para absorberselo. Los **Tres Señores del Cielo** (Seren, Fausto y Geminir) exigen un sacrificio: Desmond debe convertirse en un dios espiritual para evitar que Varlord drene su magia.

Desmond acepta el sacrificio. Howard jura vengarlo y se alía con el **Rey van Gunner** de Mirland, quien le entrega el legendario **Orbe de Reyes**, un artefacto con una gema de amatista capaz de drenar poder mágico.

Howard estudia en la **Academia Spellion** bajo el **Maestro Mago Supremo Aardin**, domina las tres ramas de la magia arcana (destrucción, restauración, conjuración), y descubre los secretos de la magia mántrica a través de los **Pergaminos de Lonnird**.

Lidera la batalla por el **Puerto de Fischer**, derrotando al general Eldein. Luego atraviesa un portal interdimensional hacia **Paedric**, el mundo origen de la magia mántrica, donde enfrenta y derrota a Varlord.

Pero Varlord era solo un sirviente. **Requivar Dominis**, el dios de la magia mántrica, emerge en Mistralis. Aardin muere enfrentándolo. Desmond regresa transformado en dios espiritual con el poder de ambas magias fusionadas, y en una batalla celestial derrota a Requivar para siempre.

## 4. PERSONAJES PRINCIPALES

| Personaje | Rol | Descripción |
|-----------|-----|-------------|
| **Howard** | Protagonista (jugador) | Hechicero nómada, busca a su hermano Desmond. Empuña espada y magia arcana. |
| **Lorefen** | Compañero | Zorro de fuego, criatura mágica ancestral. Ayuda en combate con llamaradas. |
| **Desmond** | Hermano de Howard | Joven con poder arcano inmenso. Se sacrifica para convertirse en dios espiritual. |
| **Rey van Gunner** | Aliado | Rey de Mirland. Entrega el Orbe de Reyes a Howard. |
| **Aardin** | Mentor | Maestro Mago Supremo de la Academia Spellion. Enseña a Howard y muere ante Requivar. |
| **Varlord** | Antagonista principal | Caballero del Inframundo. Busca fusionar magia arcana y mántrica. |
| **Requivar Dominis** | Villano final | Dios de la magia mántrica, ser espiritual de otro universo. |
| **Tres Señores del Cielo** | Guías espirituales | Seren, Fausto y Geminir. Mensajeros de los Dioses Magos. |
| **Eldein** | General enemigo | Elfo oscuro, lugarteniente de Varlord. Jefe del Puerto de Fischer. |
| **Aarpatin** | Maestro de Spellion | Examina a Howard en las pruebas de magia. |
| **Skarl** | Recepcionista | Maestro Mago de Encantamientos de Spellion. |

## 5. ZONAS DEL JUEGO (5 Actos)

Las zonas siguen la progresión narrativa de la novela, adaptadas para gameplay Diablo-like:

### Zona 1: Bosque de Riverell (Tutorial)
- **Ubicación en la novela**: Capítulo I — Howard llega a Riverell, busca a Desmond.
- **Gameplay**: Tutorial. Enemigos básicos (duendes, lobos). Introducción a movimiento, ataque, Lorefen.
- **Evento clave**: Howard salva a Lorefen herido, se hacen aliados. Primer cofre de tesoro.
- **Jefe**: Ninguno. Enfrentamiento tutorial con una manada de lobos.
- **Duración estimada**: 15-20 min.

### Zona 2: Mansión de Lazarian
- **Ubicación en la novela**: Capítulo I — Howard rescata a Desmond de la mansión abandonada.
- **Gameplay**: Mazmorra cerrada con habitaciones interconectadas. Enemigos espectrales, trampas mágicas.
- **Evento clave**: Howard encuentra a Desmond atrapado en un círculo mágico. Enfrentan al espectro **Sinnisgard**.
- **Jefe**: Sinnisgard (espectro, soldado de los Guerreros del Inframundo).
- **Duración estimada**: 20-30 min.

### Zona 3: Montaña Kahen y Academia Spellion
- **Ubicación en la novela**: Capítulos II y III — Ascenso a la montaña, sacrificio de Desmond, entrenamiento en Spellion.
- **Gameplay**: Zona híbrida. Exterior de montaña con criaturas de hielo (lobos de hielo, oso). Luego transición a la academia con pruebas de magia.
- **Eventos clave**:
  1. Ascenso con Desmond, pelea contra lobos de hielo y oso.
  2. Encuentro con los Tres Señores del Cielo. **Sacrificio de Desmond** (escena cinemática).
  3. Llegada a Spellion, pruebas con Aarpatin (3 ramas de magia).
  4. Encuentro con Aardin, recibe el Orbe de Reyes y el título de Mago Supremo.
- **Jefe**: Oso de montaña (mitad de zona). Pruebas de magia como "minijefes".
- **Duración estimada**: 30-40 min.

### Zona 4: Ciudad de Aveli y Puerto de Fischer
- **Ubicación en la novela**: Capítulos IV y V — Howard en Aveli, planea la batalla, recupera Fischer.
- **Gameplay**: Ciudad asediada con calles estrechas, luego campo abierto con batalla a gran escala.
- **Eventos clave**:
  1. Howard llega a Aveli, habla con el Rey van Gunner.
  2. Ataque al puerto: oleadas de Guerreros del Inframundo.
  3. Howard estudia los Pergaminos Mántricos con ayuda de los Tres Señores.
  4. **Batalla masiva**: hordas de enemigos mientras Howard y el rey lideran la carga.
- **Jefe**: **Eldein** (elfo oscuro, general de Varlord — combate cuerpo a cuerpo + magia mántrica).
- **Duración estimada**: 30-40 min.

### Zona 5: Paedric — El Nether (Zona Final)
- **Ubicación en la novela**: Capítulos VI y VII — Portal a Paedric, batalla contra Varlord, ascenso de Requivar, batalla celestial.
- **Gameplay**: Mundo infernal, terreno árido con lava, cielo rojizo. Fortaleza de Varlord.
- **Eventos clave**:
  1. Howard cruza el portal a Paedric.
  2. Camina entre filas de Guerreros del Inframundo hacia el castillo.
  3. **Jefe Varlord**: Combate intenso. Howard usa el Orbe de Reyes para drenar su poder. El rey lo remata.
  4. **Cinemática**: Cielo se tiñe de rojo, Requivar aparece. Aardin muere.
  5. **Jefe Final — Requivar Dominis**: Batalla celestial. Desmond regresa como dios espiritual, ayuda a Howard. Juntos derrotan a Requivar.
- **Duración estimada**: 40-50 min.

## 6. CINEMÁTICAS / CUTSCENES

Escenas narrativas clave (texto en pantalla + animación):

1. **Apertura**: Ciudad de Nealand, rey asesinado por Varlord. Howard cabalga hacia Mirland.
2. **Sacrificio de Desmond**: Los Tres Señores realizan el ritual. Desmond desaparece en una nube de luz.
3. **Entrega del Orbe**: El rey van Gunner entrega el Orbe de Reyes a Howard en el castillo.
4. **Muerte de Aardin**: Requivar desintegra a Aardin con un hechizo de hielo.
5. **Regreso de Desmond**: La gema de amatista se rompe, Desmond desciende de los cielos como dios.
6. **Final**: Desmond abraza a Howard por última vez y asciende. El rey da su discurso de victoria.

## 7. SISTEMA DE MAGIA (ARCANA vs MÁNTRICA)

Basado en el lore de la novela:

- **Magia Arcana**: La magia "estándar" de los hechiceros. Se aprende mediante estudio. Usa gemas (cuarzo, citrino) para canalizar poder. 3 ramas: Destrucción, Restauración, Conjuración.
- **Magia Mántrica (Maentrismo)**: Magia oscura basada en sacrificios y devoción a Requivar Dominis. Más poderosa pero corrompe al usuario. Varlord y Eldein la usan.
- **Orbe de Reyes**: Artefacto de los Dioses Magos. Contiene una gema de amatista que almacena energía infinita. Puede drenar el poder de cualquier ser en estado de debilidad.
- **Pergaminos de Lonnird**: 3 pergaminos antiguos escritos por Lonnird (primer elfo en dominar la magia mántrica). Contienen hechizos de las 3 ramas en versión mántrica.

## 8. HABILIDADES DEL JUGADOR

| Habilidad | Tipo | Rama | Descripción |
|-----------|------|------|-------------|
| Bola de Fuego | Proyectil | Destrucción | Daño en área al impactar |
| Escarcha | AoE | Destrucción | Ralentiza enemigos en área |
| Escudo de Maná | Buff | Restauración | Escudo que absorbe daño |
| Recupero | Heal | Restauración | Cura vida gradualmente |
| Invocar Esbirro | Invocación | Conjuración | Esbirro elemental que ataca |
| Visión Alterna | Detección | Conjuración | Revela enemigos y trampas cercanas |
| Ráfaga de Viento | Knockback | Destrucción | Empuja enemigos |
| Lluvia de Meteoros | Ultimate | Destrucción | Daño masivo en área grande |

El jugador equipa hasta 4 habilidades. Se desbloquean al avanzar en la historia y se mejoran con tomos encontrados en la Academia Spellion.

## 9. SISTEMA DE ENEMIGOS

### 9.1 Tipos (basados en la novela)
- **Duendes / Goblins**: Enemigos básicos del bosque. Melee, rápidos.
- **Lobos / Lobos de Hielo**: Manadas que atacan en grupo. Rápidos, daño medio.
- **Espectros / Apariciones**: Enemigos de la mansión. Etéreos, vulnerables a aceite.
- **Guerreros del Inframundo**: Soldados de Varlord. Armadura pesada, daño alto.
- **Arqueros del Inframundo**: Versión a distancia. Disparan flechas.
- **Demonios**: Invocados por Varlord. Varios tipos (melee, explosivos, voladores).
- **Élites**: Versiones potenciadas con modifiers (Veloz, Escudo, Vampírico, etc.)

### 9.2 Jefes

| Jefe | Zona | Descripción |
|------|------|-------------|
| Manada de Lobos | Bosque | Encuentro tutorial de combate |
| Sinnisgard | Mansión | Espectro soldado de Varlord. Ataca con posesión y hechizos de sombra |
| Oso de Montaña | Montaña Kahen | Bestia gigante, ataques de embestida y zarpazos |
| Eldein | Puerto Fischer | Elfo oscuro, general de Varlord. Combate espada + magia mántrica. Usa hechizo que reduce la magia del jugador |
| Varlord | Paedric | Caballero del Inframundo. Monta caballo espectral. Usa conjuro "Diablo Maestro" para invocar demonios. Fase 2: pelea a pie con magia mántrica. Vulnerable al Orbe de Reyes |
| Requivar Dominis | Paedric (final) | Dios de la magia mántrica. Batalla celestial. Fase 1: Howard solo. Fase 2: Desmond ayuda como aliado invocable. Ataques: Fuego Alquímico Corrupto, hechizos de hielo, descarga mágica |

## 10. ITEMS Y LOOT (Lore-based)

### Gemas (Slot Amuleto)
- **Cuarzo** (común): Canaliza magia básica. +10 Maná
- **Citrino** (mágico): +20 Maná, +5% daño de hechizo
- **Amatista** (raro): +40 Maná, +10% daño de hechizo, +5% prob. crítica

### Orbe de Reyes (Item de quest / ultimate)
- Se obtiene en Zona 3. Se usa como habilidad especial contra jefes (drena poder).
- En la batalla final contra Varlord, el orbe se activa automáticamente en una fase de QTE / cinemática.

### Equipamiento general
- **Arma**: Espada (daño físico). Se encuentra en cofres o dropeo de enemigos.
- **Armadura**: Túnica / armadura de cuero (defensa). Stats variables.
- **Anillos** (2): Stats aleatorios (daño mágico, velocidad, defensa, etc.)
- **Amuleto**: Slot para gemas (cuarzo, citrino, amatista).

### Rarezas
- Común (blanco) — 1 stat base
- Mágico (azul) — 2 stats
- Raro (amarillo) — 3 stats
- Único (verde) — 3 stats + efecto especial (ej: +25% daño a espectros)

## 11. SISTEMA DE PROGRESIÓN

- **XP por enemigos eliminados y misiones completadas**.
- **Al subir de nivel**: elegir entre 3 mejoras aleatorias (ej: +daño fuego, +velocidad ataque, +escudo al inicio de combate).
- **Stats**: Vida, Maná, Daño físico, Daño mágico, Velocidad, Defensa, Prob. crítica.
- **Aprendizaje de habilidades**: Al completar eventos clave de la historia (ej: superar las pruebas de Spellion desbloquea nuevas habilidades).

## 12. INTERFAZ (UI)

- **Barra de vida y maná** (esquina superior izquierda, con número de nivel)
- **Barra de XP** (debajo de vida/maná)
- **Slots de habilidades** (barra inferior, 4 teclas Q/E/R/F)
- **Minimapa**: esquina superior derecha
- **Panel de personaje** (C): stats detallados
- **Inventario** (I): Arma, Armadura, 2 anillos, Amuleto + pestaña de ítems de quest
- **Tooltips** con comparación contra equipado
- **Diálogos**: Texto en parte inferior, retrato del NPC hablante

## 13. CONTROLES

| Acción | Tecla |
|--------|-------|
| Moverse | WASD |
| Ataque básico (espada) | Clic izquierdo |
| Habilidad 1-4 | Q / E / R / F |
| Esquivar (roll) | Espacio |
| Inventario | I |
| Panel personaje | C |
| Pausa | Escape |
| Interactuar / Hablar | F |
| Lorefen ataque especial | Shift (cuando esté disponible) |

## 14. ESTÉTICA Y ARTE

- **Modelos**: Low-poly (< 500 triángulos por personaje), estilo PS1
- **Texturas**: Resolución baja (64x64 a 256x256), pixel art, dithering
- **Iluminación**: Sin luces dinámicas — baked ao y vértices coloreados
- **Paleta**: Oscura (marrones, grises, negros) con acentos saturados (rojo fuego, azul escarcha, púrpura mántrico)
- **Efectos**: Partículas simples (additive), sprite sheets animados para spells
- **Estilo mundo**: Fantasía oscura, medieval, con elementos infernales en Paedric
- **Lorefen**: Efecto de partículas de fuego alrededor del zorro cuando está en combate

## 15. AUDIO

- Música ambiental oscura por zona (loops estilo retro/MIDI):
  - Bosque: Tensa, misteriosa
  - Mansión: Disonante, susurros
  - Montaña: Épica, solemne (triste en sacrificio)
  - Spellion: Majestuosa, académica
  - Ciudad/Batalla: Marcial, ritmo intenso
  - Paedric: Agresiva, infernal
  - Jefes: Temas únicos por jefe
- SFX: Golpes, conjuros, monedas, puertas, rugido de Lorefen, muerte de enemigos
- Sin voces: texto en pantalla para toda la narrativa

## 16. ROLES DEL EQUIPO

| Persona | Responsabilidades |
|---------|------------------|
| **Fabricio** (Programador) | Sistemas core, IA, loot, procedural, VFX 2D, animaciones, shaders, game design, level design, UI coding, optimización |
| **Martin** (Artista 3D) | Modelado low-poly, texturizado PS1, animación 3D (autorigging), diseño UX/UI, menús, assets de escenario, VFX 3D |
| **Fede** (Sonidista) | Música ambiental por zona, SFX de combate/UI/habilidades, diseño de audio, mezcla |

## 17. HERRAMIENTAS DE DESARROLLO

| Herramienta | Uso |
|-------------|-----|
| **Godot Engine 4** | Motor de juego principal. C# / GDScript |
| **Blender** | Modelado 3D, animación, texturizado, rigging |
| **OpenCode** | Asistente de codificación AI integrado en terminal |
| **GitHub** | Control de versiones, repositorio, issues |
| **Jira** (via MCP + OpenCode) | Gestión de tareas y sprints. Integrable con OpenCode mediante servidor MCP de Jira (ej. `@agentdesk/jira-mcp`) para crear issues, buscar tareas, actualizar estados desde la terminal |
| **Clockify** (opcional) | Time tracking para estimaciones y retrospectivas |
| **Google Docs** | Documentación compartida del GDD, actas de reunión |

---

# PARTE 2: SCOPE

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
- 3 zonas completas: Bosque de Riverell, Montaña Kahen, Mansión de Lazarian
- Mazmorras procedurales con 3 habitaciones cada zona
- UI completa (inventario, panel personaje, tooltips, minimapa)
- Esquiva (roll) con invulnerabilidad
- 1 jefe de zona (Sinnisgard / Oso de Montaña)

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
- Zonas restantes: Ciudad de Aveli y Paedric (Nether)
- Jefes: Eldein, Varlord + Requivar Dominis
- Habilidades ultimate (Lluvia de Meteoros)
- Sistema de rarity Unique con efectos especiales
- Mejoras visuales: post-process (color grading retro)
- Balance de dificultad y loot tables
- Pulido de animaciones y transiciones
- Integración de cinemáticas narrativas

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

---

# PARTE 3: LISTA DE ASSETS

## 1. MODELOS 3D

### Personajes
| Asset | Polígonos | Animaciones | Prioridad |
|-------|-----------|-------------|-----------|
| Howard (jugador) | ~400 tris | Idle, Walk, Attack, Cast, Roll, Hit, Death | MVP |
| Lorefen (zorro de fuego) | ~200 tris | Idle, Walk, Attack (Fuego Rasgado), Hit, Death | Alfa |
| Esbirro invocado | ~200 tris | Idle, Walk, Attack, Death | Alfa |

### Enemigos
| Asset | Polígonos | Variantes | Animaciones | Prioridad |
|-------|-----------|-----------|-------------|-----------|
| Duende / Goblin (melee) | ~250 tris | 2 skins | Idle, Walk, Attack, Death | MVP |
| Lobos / Lobo de Hielo | ~300 tris | 2 skins | Idle, Walk, Attack, Death | Alfa |
| Espectro / Aparición | ~200 tris | 1 skin | Idle, Float, Possess, Death | Alfa |
| Guerrero del Inframundo | ~400 tris | 2 skins | Idle, Walk, Attack, Death | Alfa |
| Arquero del Inframundo | ~400 tris | 1 skin | Idle, Walk, Shoot, Death | Alfa |
| Demonio menor | ~300 tris | 2 skins | Idle, Walk, Attack, Death | Beta |
| Élite (Guerrero potenciado) | ~450 tris | 1 skin + modifiers | Idle, Walk, Attack, Death | Alfa |
| Sinnisgard (Jefe Mansión) | ~500 tris | — | Idle, Float, Possess, Summon, Death | Alfa |
| Oso de Montaña (Jefe) | ~600 tris | — | Idle, Walk, Slam, Roar, Death | Alfa |
| Eldein (Jefe Puerto) | ~550 tris | — | Idle, Walk, Attack, Cast, Death | Beta |
| Varlord (Jefe Nether) | ~700 tris | — | Idle, Mounted, Attack, Cast, Death | Beta |
| Requivar Dominis (Jefe Final) | ~900 tris | — | Idle, All abilities, Transform, Death | Beta |

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
| Pozo de teletransporte / Portal | 2 | Beta |
| Altar de los Tres Señores | 1 | Alfa |
| Orbe de Reyes (prop) | 1 | Alfa |

---

## 2. TEXTURAS

| Textura | Resolución | Cantidad | Prioridad |
|---------|-----------|----------|-----------|
| Personajes (atlas) | 128x128 | 12+ | MVP |
| Enemigos (atlas) | 128x128 | 10+ | MVP |
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
| Retratos NPCs (Howard, Desmond, Rey, Aardin, etc.) | 6 | Alfa |
| Marco de diálogo | 1 template | Alfa |

---

## 4. AUDIO

### Música (loops)
| Pista | Prioridad |
|-------|-----------|
| Bosque de Riverell (ambient tenso) | Alfa |
| Montaña Kahen (épico, solemne) | Beta |
| Mansión de Lazarian (oscuro, misterioso) | Beta |
| Academia Spellion (majestuoso) | Beta |
| Ciudad de Aveli / Batalla (marcial) | Beta |
| Paedric / Nether (agresivo, distorsionado) | Beta |
| Tema de Jefe (batalla) | Beta |
| Tema de Jefe Final (Requivar) | Beta |
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
| Rugido de Lorefen | 1 | Alfa |
| Jefe ataque / rugido | 4 | Beta |
| Muerte jugador | 1 | Beta |
| Ambiental (viento, pasos, susurros) | 3 | Beta |
| Portal abriéndose | 1 | Beta |

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
| Portal interdimensional | Beta |
| Lorefen (partículas de fuego en idle/combate) | Alfa |
| Magia mántrica (aura púrpura oscura) | Alfa |

---

## 6. ANIMACIONES (TOTAL)

| Animación | Cantidad de personajes que la usan |
|-----------|-----------------------------------|
| Idle | Todos (12+ personajes) |
| Walk | Howard + enemigos melee + jefes |
| Attack (melee) | Howard, duendes, guerreros, élite, jefes |
| Attack (rango) | Arquero del Inframundo |
| Cast / Shoot | Howard + arqueros + Eldein + Varlord + Requivar |
| Roll / Dodge | Solo Howard |
| Hit | Howard + todos los enemigos |
| Death | Todos |
| Explode | Demonio explosivo |
| Spawn / Invocar | Jefes (Sinnisgard, Varlord), Howard (invocar esbirro) |
| Transform | Requivar Dominis |
| Float / Possess | Espectros, Sinnisgard |
| Mounted | Varlord (caballo espectral) |

---

## RESUMEN POR FASE

| Fase | Modelos | Texturas | Animaciones | UI | Audio | VFX |
|------|---------|----------|-------------|----|-------|-----|
| **MVP** | 3 (Howard, duende, mapa) | 5 | 12 | 3 barras + fuente | 4 SFX | 0 |
| **Alfa** | +14 (Lorefen, 4 enemigos, 2 jefes, decoración) | +50 | +40 | +25 (inventario, panel, tooltips, retratos) | +15 SFX + 1 música | +8 |
| **Beta** | +10 (Eldein, Varlord, Requivar, assets Ciudad/Nether) | +15 | +15 | +5 (menú, carga) | +4 músicas + 6 SFX | +3 |
