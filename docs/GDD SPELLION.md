# GDD SPELLION

---

## ÍNDICE

### PARTE 1: GAME DESIGN DOCUMENT
- [1. Overview](#1-overview)
- [2. Adaptación Narrativa](#2-adaptación-narrativa)
- [3. Historia (Sinopsis)](#3-historia-sinopsis)
- [4. Personajes Principales](#4-personajes-principales)
- [5. Zonas del Juego (5 Actos)](#5-zonas-del-juego-5-actos)
- [6. Cinemáticas / Cutscenes](#6-cinemáticas--cutscenes)
- [7. Sistema de Magia (Arcana vs Maentrica)](#7-sistema-de-magia-arcana-vs-maentrica)
- [8. Habilidades del Jugador](#8-habilidades-del-jugador)
- [9. Sistema de Enemigos](#9-sistema-de-enemigos)
- [10. Items y Loot](#10-items-y-loot-lore-based)
- [11. Sistema de Progresión](#11-sistema-de-progresión)
- [12. Interfaz (UI)](#12-interfaz-ui)
- [13. Controles](#13-controles)
- [14. Estética y Arte](#14-estética-y-arte)
- [15. Audio](#15-audio)
- [16. Roles del Equipo](#16-roles-del-equipo)
- [17. Herramientas de Desarrollo](#17-herramientas-de-desarrollo)
- [18. Origen de las Decisiones de Diseño](#18-origen-de-las-decisiones-de-diseño)

### PARTE 2: SCOPE
- [Equipo](#equipo)
- [Cronograma — 12 Meses](#cronograma--12-meses)
- [Fase 1 — Prototipo (MVP)](#fase-1--prototipo-mvp-meses-1-3)
- [Fase 2 — Alfa](#fase-2--alfa-meses-4-7)
- [Fase 3 — Beta](#fase-3--beta-meses-8-10)
- [Fase 4 — Gold / Release](#fase-4--gold-release-meses-11-12)
- [Fuera de Scope (Stretch Goals)](#fuera-de-scope-stretch-goals)

### PARTE 3: LISTA DE ASSETS
- [1. Modelos 3D](#1-modelos-3d)
- [2. Texturas](#2-texturas)
- [3. UI / Interfaz](#3-ui--interfaz)
- [4. Audio](#4-audio)
- [5. VFX (Partículas)](#5-vfx-partículas)
- [6. Animaciones (Total)](#6-animaciones-total)
- [Resumen por Fase](#resumen-por-fase)

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

### CAMBIOS respecto a la novela para adaptación a videojuego
- **Protagonista jugable + habilidades y armas ampliadas**: Howard es el personaje jugable (en la novela es protagonista narrativo; en el juego el jugador lo controla por completo). La diferencia central es la flexibilidad de combate: en la novela Howard usa su espada y un repertorio fijo de magia arcana (Bola de Fuego, Recupero, Visión Alterna, hechizos de destrucción, hielo y rayo); en el juego puede **aprender los hechizos que decida el jugador** y empuña además **otros tipos de armas melee** (hachas, mazas) **y arco y flecha** — armas que en la novela solo usan soldados y arqueros aliados, no Howard.
- **Hordas y combates masivos**: se añaden **criaturas nuevas y en mayor cantidad**, para cumplir con la segregación narrativa/gameplay — hordas y batallas a gran escala propias del Diablo-like que expanden las batallas de la novela.
- **Diálogos y cinemáticas**: los diálogos **pueden diferir de la novela**, pero se inspiran en ella tanto en el guion como en los eventos — texto en pantalla + cutscenes (apertura, sacrificio de Desmond, entrega del Orbe, muerte de Aardin, regreso de Desmond, final).

### ACLARACIONES (no son cambios — evitan confusiones)
- **"Spellion"**: No es el nombre del protagonista — es el nombre de la Academia de Magia.
- **Lorefen**: En la novela ya acompaña a Howard y combate a su lado (Fuego Rasgado contra el oso, bolas de fuego en Fischer). No es invención de la adaptación; el juego lo conserva como acompañante.
- **Eventos condensados**: cada zona del juego representa un arco narrativo completo de la novela — no es un cambio de trama, sino un reordenamiento de ritmo para adaptarse al gameplay. Las zonas pueden estirarse para cumplir con el objetivo de entretener al jugador, o incluso inventar niveles o sectores entre los cuales representan el canon de la novela.

## 3. HISTORIA (SINOPSIS)

En el reino de **Mistralis**, el rey van Ellen de Nealand ha sido asesinado por **Varlord**, el Caballero del Inframundo, quien busca dominar el reino mediante el poder de la **magia maentrica** (oscuridad). 

**Howard**, un hechicero nómada, llega a la región de **Mirland** buscando a su hermano menor **Desmond**, quien ha desaparecido. Su búsqueda lo lleva al pueblo de Riverell, donde conoce a **Lorefen**, un zorro de fuego —una criatura mágica en peligro de extinción— y juntos rescatan a Desmond de una mansión embrujada.

Los hermanos descubren que Desmond posee un poder arcano inmenso en su sangre, y que Varlord busca asesinarlo para absorbérselo. Los **Tres Señores del Cielo** (Seren, Fausto y Geminir) exigen un sacrificio: Desmond debe convertirse en un dios espiritual para evitar que Varlord drene su magia.

Desmond acepta el sacrificio. Howard jura vengarlo y se alía con el **Rey van Gunner** de Mirland, quien le entrega el legendario **Orbe de Reyes**, un artefacto con una gema de amatista capaz de drenar poder mágico.

Howard estudia en la **Academia Spellion** bajo el **Maestro Mago Supremo Aardin**, domina las tres ramas de la magia arcana (destrucción, restauración, conjuración), y descubre los secretos de la magia maentrica a través de los **Pergaminos de Lonnird**.

Lidera la batalla por el **Puerto de Fischer**, derrotando al general Eldein. Luego atraviesa un portal interdimensional hacia **Paedric**, el mundo origen de la magia maentrica, donde enfrenta y derrota a Varlord.

Pero Varlord era solo un sirviente. **Requivar Dominis**, el dios de la magia maentrica, emerge en Mistralis. Aardin muere enfrentándolo. Desmond regresa transformado en dios espiritual con el poder de ambas magias fusionadas, y en una batalla celestial derrota a Requivar para siempre.

## 4. PERSONAJES PRINCIPALES

Todos los personajes están sujetos a cambios respecto a la novela original para satisfacer su rol en la adaptación a videojuego.

| Personaje | Rol | Descripción |
|-----------|-----|-------------|
| **Howard** | Protagonista (jugador) | Hechicero nómada, busca a su hermano Desmond. En el juego puede empuñar distintos tipos de armas (espada, hachas, mazas, arco y flecha) y aprender los hechizos que decida el jugador, además de su magia arcana. |
| **Lorefen** | Compañero | Zorro de fuego, criatura mágica ancestral. Ayuda en combate con llamaradas. |
| **Bruma** | Montura | Corcel de Howard, caballo marrón con manchas blancas. Lo acompaña en la travesía y en las batallas. |
| **Desmond** | Hermano de Howard | Joven con poder arcano inmenso. Se sacrifica para convertirse en dios espiritual. |
| **Rey van Gunner** | Aliado | Rey de Mirland. Entrega el Orbe de Reyes a Howard. |
| **Aardin** | Mentor | Maestro Mago Supremo de la Academia Spellion. Enseña a Howard y muere ante Requivar. |
| **Varlord** | Antagonista principal | Caballero del Inframundo. Busca fusionar magia arcana y maentrica. |
| **Requivar Dominis** | Villano final | Dios de la magia maentrica, ser espiritual de otro universo. |
| **Tres Señores del Cielo** | Guías espirituales | Seren, Fausto y Geminir. Mensajeros de los Dioses Magos. |
| **Eldein** | General enemigo | Elfo oscuro, lugarteniente de Varlord. Jefe del Puerto de Fischer. |
| **Aarpatin** | Maestro de Spellion | Examina a Howard en las pruebas de magia. Tras la muerte de Aardin, lo sucede como Maestro Mago Supremo (posible cutscene de cierre). |
| **Skarl** | Maestro de Spellion | Maestro Mago de Encantamientos, recibe a Howard en la academia. |

### 4.1 Howard (protagonista único)
- Clase por defecto: Hechicero nómada.
- Arma inicial: Espada de hechicero.
- Gema inicial: Citrino (colgante).
- Armadura inicial: Túnica ligera + armadura de cuero.
- Habilidad innata: Visión Alterna (detectar enemigos/tesoros).
- Skill trees: 4 Caminos (Guerrero, Rebelde, Hechicero, Ritualista) + Camino del Ascendido (Fusión e híbridos). El jugador elige su build.
- Progresión: sigue los 7 capítulos del libro.
- En cinemáticas SIEMPRE usa espada, independientemente del build.

### 4.2 Acompañantes (IA, no jugables)

  DESMOND:
    - Hermano de Howard.
    - Rol: acompañante temporal (Cap. 1), luego se sacrifica (Cap. 2).
    - Regresa como invocación espiritual en la detonación de Fusión (si se invirtió en el Camino del Ascendido → "Fusión Espiritual").
    - Arma: usa hechizos arcanos (antes del sacrificio).

  LOREFEN:
    - Zorro de fuego, mascota/aliado permanente.
    - Se obtiene en el Bosque Embrujado (Capítulo 1).
    - Habilidad: "Fuego Rasgado" (ataque de fuego a distancia).
    - Historia propia: busca venganza contra los Guerreros del Inframundo.

  REY VAN GUNNER:
    - Aliado principal, comanda el ejército de Aveli.
    - Acompaña en el Puerto de Fischer y la Batalla Final.
    - Arma: espada real. No usa magia.

  AARDIN:
    - Maestro Mago Supremo de Spellion.
    - Mentor de Howard, le enseña magia arcana.
    - Arma: bastón de mago.
    - Muere desintegrado por Requivar (Capítulo 7).

  AARPATIN:
    - Segundo de Aardin, profesor de Spellion.
    - Supervisa las pruebas de Howard (Capítulo 3).
    - Sucede a Aardin como Maestro Mago Supremo.

  LOS TRES SEÑORES DEL CIELO:
    - Seren, Fausto y Geminir.
    - Entidades divinas, portavoces de los Dioses Magos.
    - Realizan el sacrificio de Desmond (Capítulo 2).
    - Ayudan a descifrar los Pergaminos (Capítulo 5).

## 5. ZONAS DEL JUEGO (5 Actos)

Las zonas siguen la progresión narrativa de la novela, adaptadas para gameplay Diablo-like. Todo está sujeto a revisión: las zonas deben expandirse y seguramente modificarse durante el desarrollo.

El juego se organiza en 5 zonas de alto nivel (actos) que a su vez cubren los 7 capítulos de la novela (detallados en §5.6). Correspondencia:

| Zona (Acto) | Capítulos |
|-------------|-----------|
| Zona 1: Bosque de Riverell | Capítulo 1 (parte: Riverell + Bosque Embrujado) |
| Zona 2: Mansión de Lazarian | Capítulo 1 (parte: Lazarian) |
| Zona 3: Montaña Kahen + Academia Spellion | Capítulos 2 y 3 |
| Zona 4: Ciudad de Aveli + Puerto de Fischer | Capítulos 4 y 5 |
| Zona 5: Paedric — El Nether | Capítulos 6 y 7 |

### Zona 1: Bosque de Riverell (Tutorial)
- **Ubicación en la novela**: Capítulo I — Howard llega a Riverell, busca a Desmond.
- **Gameplay**: Tutorial. Enemigos básicos (duendes, lobos). Introducción a movimiento, ataque, Lorefen.
- **Evento clave**: Howard salva a Lorefen herido, se hacen aliados. Primer cofre de tesoro.
- **Jefe**: Ninguno. Enfrentamiento tutorial con una manada de lobos.

### Zona 2: Mansión de Lazarian
- **Ubicación en la novela**: Capítulo I — Howard rescata a Desmond de la mansión abandonada.
- **Gameplay**: Mazmorra cerrada con habitaciones interconectadas. Enemigos espectrales, trampas mágicas.
- **Evento clave**: Howard encuentra a Desmond atrapado en un círculo mágico. Enfrentan al espectro **Sinnisgard**.
- **Jefe**: Sinnisgard (espectro, soldado de los Guerreros del Inframundo).

### Zona 3: Montaña Kahen y Academia Spellion
- **Ubicación en la novela**: Capítulos II y III — Ascenso a la montaña, sacrificio de Desmond, entrenamiento en Spellion.
- **Gameplay**: Zona híbrida. Exterior de montaña con criaturas de hielo (lobos de hielo, oso). Luego transición a la academia con pruebas de magia.
- **Eventos clave**:
  1. Ascenso con Desmond, pelea contra lobos de hielo y oso.
  2. Encuentro con los Tres Señores del Cielo. **Sacrificio de Desmond** (escena cinemática).
  3. Llegada a Spellion, pruebas con Aarpatin (3 ramas de magia).
  4. Encuentro con Aardin, recibe el Orbe de Reyes y el título de Mago Supremo.
- **Jefe**: Oso de montaña (mitad de zona). Pruebas de magia como "minijefes".

### Zona 4: Ciudad de Aveli y Puerto de Fischer
- **Ubicación en la novela**: Capítulos IV y V — Howard en Aveli, planea la batalla, recupera Fischer.
- **Gameplay**: Ciudad asediada con calles estrechas, luego campo abierto con batalla a gran escala.
- **Eventos clave**:
  1. Howard llega a Aveli, habla con el Rey van Gunner.
  2. Ataque al puerto: oleadas de Guerreros del Inframundo.
  3. Howard estudia los Pergaminos Maentricos con ayuda de los Tres Señores.
  4. **Batalla masiva**: hordas de enemigos mientras Howard y el rey lideran la carga.
- **Jefe**: **Eldein** (elfo oscuro, general de Varlord — combate cuerpo a cuerpo + magia maentrica).

### Zona 5: Paedric — El Nether (Zona Final)
- **Ubicación en la novela**: Capítulos VI y VII — Portal a Paedric, batalla contra Varlord, ascenso de Requivar, batalla celestial.
- **Gameplay**: Mundo infernal, terreno árido con lava, cielo rojizo. Fortaleza de Varlord.
- **Eventos clave**:
  1. Howard cruza el portal a Paedric.
  2. Camina entre filas de Guerreros del Inframundo hacia el castillo.
  3. **Jefe Varlord**: Combate intenso. Howard usa el Orbe de Reyes para drenar su poder. El rey lo remata.
  4. **Cinemática**: Cielo se tiñe de rojo, Requivar aparece. Aardin muere.
  5. **Jefe Final — Requivar Dominis**: Batalla celestial. Desmond regresa como dios espiritual, ayuda a Howard. Juntos derrotan a Requivar.

### 5.6 Progresión narrativa (7 capítulos) con zonas

#### CAPÍTULO 1 - Una moneda de oro
- **Zonas**:
  - RIVERELL (pueblo inicial): tutorial, NPCs, comercio básico. Howard comienza aquí con Desmond.
  - BOSQUE EMBRUJADO (bosque): primer dungeon. Enemigos: espíritus, criaturas mágicas. Evento: Howard conoce a Lorefen.
  - LAZARIAN (mansión abandonada): dungeon interior. Enemigos: espectros, apariciones. Jefe: Sinnisgard (espectro soldado).
- **Bioma**: bosque templado, noche/penumbra.
- **Transición**: Howard y Desmond huyen de Riverell hacia el bosque y terminan en la mansión abandonada de Lazarian.

#### CAPÍTULO 2 - El sacrificio
- **Zonas**:
  - ALDEA DE MONTAÑA (asentamiento): descanso, preparación.
  - MONTAÑA KAHEN (ascenso): sendas de montaña, cuevas, nieve. Enemigos: lobos de hielo, oso de guarida (subjefe opcional).
  - ALTAR DE LOS TRES SEÑORES (cima de Kahen): evento narrativo. Sacrificio de Desmond.
- **Bioma**: montaña nevada, día claro/viento.
- **Transición**: Howard y Desmond ascienden Kahen guiados por los Tres Señores del Cielo.

#### CAPÍTULO 3 - Maestro Mago Supremo
- **Zonas**:
  - ACADEMIA SPELLION (exteriores): jardines, puente, entrada.
  - SALA DE PRUEBAS (interior): 3 salas de prueba (telequinesis, combate, resolución mágica). Sin enemigos — puzles.
  - BIBLIOTECA DE SPELLION: encuentro con Aardin, obtención del Orbe de Reyes. >>> FUSIÓN DESBLOQUEADA <<<
- **Bioma**: academia de piedra, iluminación mágica.
- **Transición**: Howard llega a Spellion buscando respuestas. Aardin lo pone a prueba.

#### CAPÍTULO 4 - El puerto
- **Zonas**:
  - AVELI (campamento aliado): base del Rey Van Gunner. Preparación antes de la batalla.
  - PUERTO DE FISCHER (zona de batalla): calles, muelles, almacenes, playa. Asedio en progreso. Enemigos: Guerreros del Inframundo, arqueros, lobos oscuros.
  - AZOTEA DEL COMANDO ENEMIGO: encuentro con Eldein (jefe).
- **Bioma**: pueblo costero/portuario, atardecer/incendios.
- **Transición**: Howard se une al ejército de Aveli para recuperar el puerto estratégico.

#### CAPÍTULO 5 - Los tres pergaminos
- **Zonas**:
  - ACADEMIA SPELLION (regreso): ahora parcialmente tomada o bajo amenaza.
  - CRIPTA DE LONNIRD (subsuelo de Spellion): mazmorra nueva. Enemigos: espectros, trampas mágicas.
  - SALA DE LOS PERGAMINOS: descifrar los 3 pergaminos con ayuda de los Tres Señores del Cielo. >>> CAMINO DEL RITUALISTA POTENCIADO (perks finales) <<<
- **Bioma**: academia en ruinas/subterráneo.
- **Transición**: Howard regresa a Spellion al descubrir que los Pergaminos de Lonnird contienen la clave para vencer a Requivar.

#### CAPÍTULO 6 - El portal
- **Zonas**:
  - PORTAL MAENTRICO (bosque corrupto): Howard abre el portal usando los pergaminos y el Orbe.
  - PAEDRIC (dimensión maentrica): mundo distorsionado, cielo rojo, gravedad inconsistente, texturas oníricas. Enemigos: criaturas tipo dragón, Guerreros del Inframundo mejorados, demonios. >>> RIESGO sube 25% más lento en esta zona <<<
  - CIUDADELA DE PAEDRIC (fortaleza): encuentro con Varlord.
- **Bioma**: dimensión infernal/maentrica.
- **Transición**: Howard cruza el portal para enfrentar a Varlord en su propio territorio.

#### CAPÍTULO 7 - La batalla final
- **Zonas**:
  - PORTAL DE RETORNO (Paedric -> Mistralis): Howard regresa con Varlord persiguiéndolo.
  - CAMPO DE BATALLA (Mistralis): oleadas de demonios invocados por Varlord. Aardin y el ejército de Aveli presentes. >>> FUSIÓN cargada automáticamente al inicio <<<
  - ENCUENTRO CON VARLORD (jefe): batalla contra el Caballero del Inframundo.
  - ENCUENTRO CON REQUIVAR DOMINIS (jefe final): ser mítico. >>> FUSIÓN necesaria para romper su escudo <<<
  - EPÍLOGO: muerte de Aardin, regreso de Desmond, Volcano Alcántrico como Fusión definitiva.
- **Bioma**: campo de batalla devastado, cielo partido (arcana/maentrica).

### 5.7 Dungeon Crawling

#### 5.7.1 Estructura general
- Mazmorras laberínticas con entrada y salida, interconectadas.
- Pueden ser hechas a mano, generadas proceduralmente, o híbrido.

#### 5.7.2 Componentes de nivel
- TRAMPAS AMBIENTALES: fuegos, pinches, barriles explosivos, flechas detonadas por baldosas. NUNCA muerte instantánea.
- EVENTOS: interacción con objetos clave, NPCs, narración, cutscenes.
- SPAWNS: enemigos de leveled list fijo por mazmorra (SIN LEVEL SCALING), deben encajar temáticamente.
- SPAWNS ESPECIALES: subjefes, jefes o enemigos condicionales.
- ALTARES: fuentes de curación, regeneración de MP, buffs, o con efectos negativos (trampas ocultas, spawn de enemigos).

#### 5.7.3 Mazmorras del libro

1. **BOSQUE EMBRUJADO (Riverell)** — tutorial/primer nivel
   - Enemigos: espíritus, criaturas mágicas
   - Jefe: - (introducción, evento con Lorefen)

2. **SÓTANO DE LA MANSIÓN ABANDONADA (Lazarian)**
   - Enemigos: espectros, apariciones
   - Jefe: Sinnisgard (espectro soldado)

3. **MONTAÑA KAHEN**
   - Enemigos: lobos de hielo, oso de guarida
   - Evento: encuentro con los Tres Señores del Cielo

4. **ACADEMIA SPELLION (pruebas)**
   - Enemigos: ninguno (puzles mágicos, 3 pruebas)
   - Evento: conocer a Aardin, obtener el Orbe de Reyes

5. **PUERTO DE FISCHER (asedio)**
   - Enemigos: Guerreros del Inframundo, arqueros, lobos oscuros
   - Jefe: Eldein (general elfo oscuro)

6. **PAEDRIC (otra dimensión)**
   - Enemigos: criaturas tipo dragón, Guerreros del Inframundo
   - Jefe: Varlord (Caballero del Inframundo)

7. **CAMPO DE BATALLA FINAL**
   - Enemigos: demonios (invocados por Varlord), oleadas infinitas
   - Jefes: Varlord (final), Requivar Dominis (jefe final)

## 6. CINEMÁTICAS / CUTSCENES

Escenas narrativas clave (texto en pantalla + animación):

1. **Apertura**: Ciudad de Nealand, rey asesinado por Varlord. Howard cabalga hacia Mirland.
2. **Sacrificio de Desmond**: Los Tres Señores realizan el ritual. Desmond desaparece en una nube de luz.
3. **Entrega del Orbe**: El rey van Gunner entrega el Orbe de Reyes a Howard en el castillo.
4. **Muerte de Aardin**: Requivar desintegra a Aardin con un hechizo de hielo.
5. **Regreso de Desmond**: La gema de amatista se rompe, Desmond desciende de los cielos como dios.
6. **Final**: Desmond abraza a Howard por última vez y asciende. El rey da su discurso de victoria.

## 7. SISTEMA DE MAGIA (ARCANA vs MAENTRICA)

Basado en el lore de la novela:

- **Magia Arcana**: La magia "estándar" de los hechiceros. Se aprende mediante estudio. Usa gemas (cuarzo, citrino) para canalizar poder. 3 ramas: Destrucción, Restauración, Conjuración.
- **Magia Maentrica (Maentrismo)**: Magia oscura basada en sacrificios y devoción a Requivar Dominis. Más poderosa pero corrompe al usuario. Varlord y Eldein la usan.
- **Orbe de Reyes**: Artefacto de los Dioses Magos. Contiene una gema de amatista que almacena energía infinita. Puede drenar el poder de cualquier ser en estado de debilidad.
- **Pergaminos de Lonnird**: 3 pergaminos antiguos escritos por Lonnird (primer elfo en dominar la magia maentrica). Contienen hechizos de las 3 ramas en versión maentrica.

### 7.1 Gemas de canalización (narrativo/visual)

- Todo hechicero porta una gema para canalizar su poder mágico.
- Es puramente VISUAL/NARRATIVO: la gema brilla cuando el hechicero usa magia. No tiene efecto en gameplay.
- Tipos (de más común a más rara):
  * Cuarzo: común.
  * Citrino: calidad media. Howard usa una en colgante.
  * Amatista: extremadamente rara y poderosa. La del Orbe de Reyes.
- Justificación literaria: Aardin explica que las gemas "permiten al hechicero apaciguar el poder de la magia sin que esta los consuma".
- **Efecto de gemas en gameplay: A DEFINIR** (¿puramente cosméticas/narrativas o con stats?).

### 7.2 Las tres ramas de Magia Arcana

  DESTRUCCIÓN:
    - Hechizos ofensivos: fuego, hielo, rayo, impacto.
    - Ejemplo histórico: Howard usa "fuerte hechizo de fuego" contra Varlord, y "dos hechizos de hielo y rayo" en el clímax.
    - Especialización: daño directo, área, penetración de resistencia.

  RESTAURACIÓN:
    - Curación, protección, escudos, purificación.
    - Ejemplo histórico: "Recupero" cura a Lorefen; Aardin crea un "escudo protector" para el rey.
    - Especialización: sanar, fortalecer armaduras, purificar magia.

  CONJURACIÓN:
    - Telequinesis, invocación de criaturas, control.
    - Ejemplo histórico: Howard usa telequinesis en la prueba de Spellion; Varlord invoca demonios con "Maestro Diablo".
    - Especialización: invocaciones temporales, control de masas.

### 7.3 Hechizos icónicos del libro

Nota: en la novela la magia se escribe "maéntrica" (con acento en la e) y el ismo como "maentrismo". Para el juego se adopta la grafía **"Maentrica"**.

  NOMBRE                | TIPO         | RAMA        | QUIEN LO USA
  -----------------------|--------------|-------------|---------------------
  Recupero              | Restauración | Arcana      | Howard
  Visión Alterna        | Detección    | Arcana      | Howard
  Fuego Rasgado         | Destrucción  | (zorro)     | Lorefen
  Fuego Alquímico       | Destrucción  | Maentrica   | Varlord, Aardin
    Corrupto            |              |             |
  Maestro Diablo        | Conjuración  | Maentrica   | Varlord
  Recupero Maentrico    | Restauración | Maentrica   | Howard (intento)
  Volcano Alcántrico    | Destrucción  | Fusión      | Desmond
  Diablo Maestro        | Conjuración  | Maentrica   | Varlord (alias de Maestro Diablo; se unifica)

### 7.4 Sistema de RIESGO (magia maentrica)

  La magia maentrica NO consume MP. Tiene su propia barra: RIESGO.

  >> CÓMO FUNCIONA:
     - RIESGO empieza en 0% y SUBE al usar hechizos maentricos.
     - Baja al matar enemigos (cantidad variada) o al recibir daño
       (proporcional al daño recibido).
     - La barra de RIESGO se muestra en el HUD.

  >> ZONA SEGURA: 0%–10% — sin eventos.

  >> TICK DE EVENTO (cada 10 segundos):
     Cuando RIESGO > 10%, el juego revisa chances acumulativas.
     No detonan todos simultáneamente; cada evento tiene su propia
     probabilidad que escala con RIESGO.

  TABLA DE EVENTOS:

  RIESGO   | EVENTO              | TIPO          | DETALLE
  ---------|---------------------|---------------|------------------------
  10%+     | Oscuridad           | Inesquivable  | Pantalla sombría,
           |                     |               | visión reducida.
  20%+     | Alucinaciones       | Inesquivable  | Enemigos falsos,
           |                     |               | efectos visuales
           |                     |               | confusos.
  30%+     | Nube de veneno      | Esquivable    | Nube tóxica (nunca
           |                     | (nace lejos)  | encima del jugador).
           |                     |               | Veneno + debilidad.
  40%+     | Nube drenadora      | Esquivable    | Nube púrpura que
           |                     | (nace lejos)  | drena MP y reduce
           |                     |               | regeneración.
  50%+     | Retribución         | Esquivable    | Rayo rojo cae del
           | demónica             | (smite)       | cielo. Daño directo.
  70%+     | Texturas            | Inesquivable  | El nivel se distorsiona
           | horroríficas        |               | con texturas grotescas.
  90%+     | Avatar Dominis      | Spawnea       | Enemigo muy duro, lento,
           |                     |               | acosador. Sin exp ni
           |                     |               | items. Matarlo reduce
           |                     |               | RIESGO solo 1.

  >> FALLO ARCANO (afecta a la magia arcana):
     Por cada 10% de RIESGO, los hechizos arcanos tienen +2% de
     chance de fallar (gastan MP sin producir efecto).

  >> RISK VS REWARD:
     - RIESGO > 50%: los hechizos maentricos hacen más daño.
     - RIESGO > 75%: hechizos maentricos ganan efectos secundarios
       (área, perforación, drenaje extra).
     - Los Perks del Ritualista potencian la recompensa y mitigan el riesgo.

  >> CÓMO BAJA RIESGO:
     - Matar enemigos: cantidad variada (no depende del nivel).
     - Recibir daño: proporcional al daño recibido ("me dejo golpear
       para enfriar la barra").
     - Matar un Avatar Dominis: reduce solo 1 punto.
     - Sacrificio (skill activo del Ritualista): reduce RIESGO a
       cambio de vida.

  Justificación: El libro describe cómo el poder maentrico "consume" y "corrompe" a sus usuarios. La mecánica refleja que usar este poder es intrépido — mientras más lo usás, más te consume.

### 7.5 Mecánica de FUSIÓN (Smart Bomb)

  >> CONCEPTO:
     La Fusión NO se castea con MP. Es una habilidad de carga/detonación independiente, con su propio indicador.

  >> CÓMO SE CARGA:
     - Al hacer daño con magia arcana o maentrica, un porcentaje del daño se convierte en carga de Fusión.
     - El medidor de Fusión se muestra en HUD junto al Orbe de Reyes.
     - Sin el Orbe de Reyes equipado, el medidor no existe.

  >> CÓMO SE DETONA:
     - Al alcanzar carga completa (100%), el jugador puede activar la Fusión con una tecla/habilidad.
     - Libera una explosión masiva de daño combinado arcana/maentrica en área.
     - El medidor se vacía por completo al detonar.

  >> VOLCANO ALCÁNTRICO:
     - Efecto Fusión por defecto (y único hasta desbloquear mejoras).
     - Cataclismo de fuego y energía pura.
     - Daño masivo en área, ignora resistencias menores.
     - Animación cinemática breve al activarse.

  >> NOTAS DE DISEÑO:
     - La Fusión es deliberadamente escasa y poderosa.
     - No se puede "farmear" carga contra enemigos ya muertos.
     - El jugador debe decidir: ¿uso mi mejor magia ahora, o guardo para cargar la Fusión más rápido?

## 8. HABILIDADES DEL JUGADOR

El sistema de habilidades se organiza en los 4 Caminos + Ascendido (ver §8.4). El concepto de "equipar hasta 4 habilidades" en una barra y su conexión con los Caminos: **A DEFINIR**.

### 8.1 Hechizos canon de Howard (usados en la novela)

Howard domina las tres ramas de la magia arcana (destrucción, restauración y conjuración) tras su entrenamiento en la Academia Spellion. Los hechizos con nombre o descripción concreta que usa en la novela son:

| Habilidad | Tipo | Rama | Descripción |
|-----------|------|------|-------------|
| Recupero | Heal | Restauración | Cura vida gradualmente. En la novela Howard lo usa para curar a Lorefen. |
| Visión Alterna | Detección | Conjuración | Revela enemigos y amenazas cercanas. En la novela lo usa en el bosque para sentir una presencia tras una puerta. |
| Bola de Fuego | Proyectil | Destrucción | Daño en área al impactar. En la novela Howard lanza "un hechizo de fuego" contra los lobos de hielo y "un fuerte hechizo de destrucción de fuego" contra Varlord; "Bola de Fuego" es el nombre de juego para ese hechizo. |
| Hechizo de hielo y rayo | Proyectil | Destrucción | En la novela Howard lanza "dos hechizos de hielo y rayo" contra Varlord. |
| Destrucción de encantamientos | Destrucción | Destrucción | Rompe el círculo mágico que aprisiona a Desmond destruyendo el libro vinculado. |
| Conjuro de portal | Conjuración | Conjuración | Crea el portal interdimensional hacia Paedric junto a Aardin (idioma senner, hechizo de conjuración con círculo de llamas negras). |
| Telequinesis | Conjuración | Conjuración | Poder de la tercera rama, aprendido en la academia. |
| Conjuración de monstruos aliados | Invocación | Conjuración | Invoca aliados de tormenta, hielo y fuego; la más poderosa de la tercera etapa del entrenamiento. |

### 8.2 Hechizos canon de otros personajes (candidatos a ponerse a disposición de Howard)

| Habilidad | Rama | Quién lo usa | Descripción |
|-----------|------|--------------|-------------|
| Fuego Rasgado | Fuego | Lorefen | Llamarada desde la boca; daña significativamente al oso de montaña. |
| Fuego Alquímico Corrupto | Destrucción (maentrica) | Varlord / Aardin | Descubierto en los Pergaminos de Lonnird; Howard lo aprende pero nunca se lo muestra lanzándolo. Quienes lo lanzan son Varlord (contra Howard) y Aardin (contra Requivar). |
| Maestro Diablo | Conjuración (maentrica) | Varlord | Atrae cientos de demonios. En la novela aparece también como "Diablo Maestro"; se unifica como **Maestro Diablo**. |
| Recupero Maentrico | Restauración (maentrica) | Howard (intento) | Versión maentrica de Recupero; Howard intenta usarlo contra Varlord sin éxito. |
| Volcano Alcántrico | Fusión | Desmond | Apresa a su objetivo; Desmond lo usa para derrotar a Requivar (ultimate de Fusión). |
| Hechizo de alteración | Alteración (maentrica) | Eldein | Reduce drásticamente la magia del objetivo (Howard queda sin magia en combate). |
| Escudo protector | Restauración | Aardin | Crea un escudo protector; Aardin lo usa sobre el rey (base de Escudo de Maná). |

### 8.3 Propuestas nuevas (adiciones de game design — no aparecen en la novela)

| Habilidad | Tipo | Rama | Descripción |
|-----------|------|------|-------------|
| Escarcha | AoE | Destrucción | Ralentiza enemigos en área. |
| Escudo de Maná | Buff | Restauración | Escudo que absorbe daño. Inspirado en el escudo protector de Aardin. |
| Invocar Esbirro | Invocación | Conjuración | Esbirro elemental que ataca. Inspirado en la conjuración de monstruos aliados de la academia. |
| Ráfaga de Viento | Knockback | Destrucción | Empuja enemigos. |
| Lluvia de Meteoros | Ultimate | Destrucción | Daño masivo en área grande. |

Las habilidades de las secciones 8.2 y 8.3 son candidatas para completar la barra del jugador, además de los hechizos canon de Howard.

### 8.4 Skill Trees — Los 4 Caminos + Ascendido

Sección que reemplaza el concepto de "clases alternativas" con 4 árboles de habilidades principales + 1 rama especial. Howard puede invertir puntos en cualquier árbol sin restricción de clase. Los árboles definen arquetipos de build, pero el jugador es libre de combinarlos.

Desbloqueo de Caminos:
  - Guerrero, Rebelde, Hechicero, Ritualista: disponibles desde Capítulo 1.
  - Ascendido: requiere el Orbe de Reyes (Capítulo 3).

Los 4 caminos principales comparten puntos de habilidad de nivel.
El Camino del Ascendido progresa por hitos narrativos y logros.

#### 8.4.1 Camino del Guerrero

  Arquetipo: combate cuerpo a cuerpo, armas melee, resistencia.
  Atributos: Fuerza, Vitalidad.

  Skills:

  ESPADA (canónica):
    - Daño, velocidad, alcance de ataques con espada.
    - Desbloquea combos y ataques especiales.
    - Sin coste de mana.

  HACHA:
    - Daño bruto, armas lentas y pesadas.
    - Golpes con armadura (ignoran % de Armor Class enemigo).
    - Justificación: ídem arco — variedad de builds.

  MAZA:
    - Daño medio-alto, aturdimiento (stun).
    - Quebrantar armaduras (reducen Armor Class enemigo permanentemente durante el combate).
    - Justificación: ídem.

  ESCUDOS:
    - Bloqueo, reducción de daño recibido.
    - Se entrena dentro de este camino (combate defensivo).

  PERKS DEL GUERRERO:
    - Golpe Poderoso: ataque cargado que hace daño extra.
    - Resistencia física: reduce daño de armas enemigas.
    - Rompeescudos: los ataques ignoran bloqueo.
    - Frenesí: al matar enemigos, aumenta velocidad de ataque temporalmente.
    - Maestría marcial: reduce penalizaciones por requisitos de armas no cumplidos.

  Justificación: Howard usa espada en el libro. Este camino potencia su estilo de combate canónico. Las otras armas melee (hacha, maza) son ruptura justificada por variedad de builds.

#### 8.4.2 Camino del Rebelde

  Arquetipo: distancia, agilidad, sigilo, loot.
  Atributos: Agilidad, Destreza (el prototipo no tiene Destreza — su inclusión: A DEFINIR).

  Skills:

  ARCO (ruptura justificada):
    - Daño a distancia, velocidad de disparo, precisión.
    - Desbloquea modo sostenido (más daño) y flechas especiales.

  ESQUIVE Y MOVILIDAD:
    - Esquive adicional, reducción de penalización de armaduras.
    - Carrera y dash.

  LOOT Y SUPERVIVENCIA:
    - Mayor probabilidad de loot en enemigos y cofres.
    - Detección de trampas.
    - Visión Alterna mejorada (la habilidad innata de Howard detecta también objetos interactuables y caminos ocultos).

  ATAQUES FURTIVOS:
    - Daño extra al atacar por detrás o sin ser detectado.
    - Reducción de aggro.

  PERKS DEL REBELDE:
    - Disparo certero: el modo sostenido del arco tiene perforación (atraviesa enemigos).
    - Paso sombrío: dodge que deja una ilusión y teletransporta.
    - Manos rápidas: velocidad de ataque con arco + recarga de flechas especiales.
    - Instinto de cazador: marca al enemigo más débil en pantalla.
    - Saqueador: loot mejorado y chance de obtener items raros.

  Justificación: Howard no usa arco ni sigilo en el libro. Es el camino menos canónico. Existe para jugadores que prefieran un estilo ágil y a distancia.

#### 8.4.3 Camino del Hechicero

  Arquetipo: magia arcana pura, control, versatilidad mágica.
  Atributo: Magia (en el prototipo, Inteligencia).

  Skills:

  DESTRUCCIÓN:
    - Hechizos ofensivos: fuego, hielo, rayo.
    - Daño directo y por área.
    - Penetración de resistencias.

  RESTAURACIÓN:
    - Curación, escudos, purificación.
    - Protección a aliados (incluye Lorefen).
    - Purificación de efectos maentricos.

  CONJURACIÓN:
    - Telequinesis, invocaciones temporales, control de masas.
    - Invocar criaturas elementales aliadas.
    - Manipular objetos del entorno.

  PERKS DEL HECHICERO:
    - Maestría arcana: los hechizos cuestan menos mana.
    - Gema resplandeciente: efecto visual intensificado (cosmético).
    - Canalización estable: los hechizos sostenidos no pueden ser interrumpidos por daño leve.
    - Sincronía elemental: lanzar dos hechizos del mismo tipo consecutivos aumenta su daño.
    - Protección mágica: Armor Class contra daño mágico.

  Justificación: Es la magia que Howard estudia en la Academia Spellion. Es el camino canónico para su personaje.

#### 8.4.4 Camino del Ritualista

  Arquetipo: magia maentrica, poder oscuro, sacrificio.
  Atributo: Magia (en el prototipo, Inteligencia) + Vitalidad (para resistir el desgaste).
  Recurso: usa la barra de RIESGO en lugar de MP (ver 7.4).
  Desbloqueo: disponible desde Capítulo 1.

  >> JUSTIFICACIÓN DE RUPTURA:
     En la novela, Howard descubre la magia maentrica al leer los Pergaminos de Lonnird (Capítulo 5). En gameplay, obligar al jugador a esperar 5 capítulos para usar un camino entero es funesto — perdería toda exploración de arquetipo en la primera mitad del juego.

     >> LÍMITE DE RUPTURA:
        - El desbloqueo NARRATIVO (Pergaminos de Lonnird) sigue siendo en Capítulo 5. Hasta entonces, el juego muestra un mensaje: "No comprendes del todo este poder..." y los hechizos maentricos disponibles son los básicos, sin los perks finales.
        - A partir de Capítulo 5, el Camino se potencia: se desbloquean perks avanzados y el tope del árbol.
        - Progresión: el jugador invierte puntos antes, pero el poder real del Ritualista llega con la narrativa.

  Skills:

  FUEGO ALQUÍMICO CORRUPTO:
    - Hechizo maentrico básico. Ignora resistencias normales.
    - Causa daño maentrico (drena vida).
    - Sube RIESGO al usarlo.

  INVOCACIONES OSCURAS:
    - Invocar demonios y criaturas de Paedric.
    - Similar a Conjuración arcana pero con criaturas maentricas (inestables — si RIESGO es alto, pueden volverse contra Howard).
    - Sube RIESGO significativamente al invocar.

  SACRIFICIO (activo):
    - Reduce RIESGO a cambio de una porción de vida.
    - También puede convertir vida en carga de Fusión (interactúa con Camino del Ascendido).

  CORRUPCIÓN:
    - Skills que aplican corrupción a enemigos (debuff continuo).
    - Skills que potencian a Howard mientras más corrupto esté el campo de batalla.

  PERKS DEL RITUALISTA:
    - Resistencia maentrica: reduce el daño que Howard recibe de los eventos de RIESGO (Retribución, Nube de veneno).
    - Devoción oscura: los hechizos maentricos son más potentes cuando RIESGO > 50%.
    - Drenar alma: roba vida al matar enemigos con magia maentrica.
    - Estabilidad corrupta: ralentiza la velocidad a la que sube RIESGO. También reduce la probabilidad de perder el control de invocaciones.
    - Vínculo con Paedric: acceso a hechizos maentricos más poderosos mientras esté en la dimensión maentrica (Capítulo 6). Además, RIESGO sube un 25% más lento en Paedric.

  Riesgo narrativo: si Howard invierte demasiados puntos aquí, su apariencia puede cambiar sutilmente (venas oscuras, ojos brillantes) y algunos NPCs pueden reaccionar con desconfianza.

#### 8.4.5 Camino del Ascendido (Rama Especial)

  Arquetipo: poderes híbridos, combinación creativa de ramas, Fusión.
  Requisito: Orbe de Reyes (Capítulo 3).

  Este camino NO se sube con puntos de habilidad de nivel. Se desbloquea al obtener el Orbe de Reyes y progresa mediante hitos narrativos y logros (ej: "usa 3 tipos de magia distintos en una pelea de jefe", "combina espada con magia arcana por primera vez", "sobrevive a una invocación descontrolada", etc.).

  Skills de FUSIÓN (Smart Bomb):
    Los skills base de la detonación de Fusión (ver 7.5). Se mejoran al completar hitos:

    - ALCANCE: aumenta el radio de la explosión.
    - POTENCIA: aumenta el daño base de Volcano Alcántrico.
    - CARGA RÁPIDA: mayor % de daño convertido en carga.
    - DOBLE CARGA: almacenar hasta 2 detonaciones.
    - ONDA EXPANSIVA: la explosión empuja y stunea.
    - PURIFICACIÓN: la explosión elimina efectos maentricos negativos.
    - FUSIÓN ESPIRITUAL: al detonar, invoca el espíritu de Desmond para un ataque combinado definitivo.

  Skills HÍBRIDOS (Combinación de Caminos):
    Estos skills requieren tener cierto nivel en dos caminos distintos. Se desbloquean automáticamente al cumplir los requisitos.

    - INFUSIÓN ARMA (Guerrero + Hechicero):
      Canaliza magia arcana a través del arma cuerpo a cuerpo. El arma hace daño adicional del tipo elemental elegido (fuego, hielo, rayo) durante un tiempo. Cada tipo de arma tiene su propia animación de infusión.
      >> Para espada: Espada llameante / Glacial / Eléctrica.
      >> Para hacha: Hacha de impacto elemental.
      >> Para maza: Maza con ondas de choque mágico.

    - FLECHA MÁGICA (Rebelde + Hechicero):
      Las flechas llevan un hechizo arcano incrustado. Al impactar, detonan el efecto mágico (fuego en área, rayo en cadena, hielo que ralentiza).

    - SACRIFICIO ARCANO (Hechicero + Ritualista):
      Convierte mana en vida, o viceversa, a una tasa mejorada. También permite usar hechizos arcanos con daño maentrico adicional (híbrido arcana-maentrica).

    - SOMBRA GUERRERA (Guerrero + Rebelde):
      Ataque sigiloso que inflige daño masivo. Howard se vuelve invisible brevemente y reaparece con un golpe potenciado. Funciona con cualquier arma melee.

    - VOLCANO ALCÁNTRICO MEJORADO (Guerrero + Ritualista + Hechicero + Fusión):
      Si se tienen niveles altos en Guerrero, Ritualista y Hechicero, Volcano Alcántrico se potencia: el daño es arcano + maentrico simultáneamente, el radio es máximo y el espíritu de Desmond aparece automáticamente.

    - MAESTRO ASCENDIDO (todas las ramas con nivel alto):
      Howard puede alternar entre modos de combate sobre la marcha sin penalización. La Fusión carga un 50% más rápido. Todos los efectos híbridos duran el doble.

## 9. SISTEMA DE ENEMIGOS

### 9.1 Tipos (basados en la novela)

Marcas: **[Canon]** = aparece en la novela. **[Nuevo]** = sugerencia de juego (no está en la novela).

- **[Canon] Duendes / Goblins**: Enemigos básicos del bosque. Melee, rápidos.
- **[Canon] Lobos / Lobos de Hielo**: Manadas que atacan en grupo. Rápidos, daño medio.
- **[Canon] Espectros / Apariciones**: Enemigos de la mansión. Etéreos, vulnerables a aceite.
- **[Canon] Espectros del bosque** (espíritus / criaturas mágicas del Bosque Embrujado).
- **[Canon] Guerreros del Inframundo**: Soldados de Varlord. Armadura pesada, daño alto (espadachines, arqueros, caballería).
- **[Nuevo] Caballería del Inframundo**: versión montada de los Guerreros (variante de juego).
- **[Canon] Arqueros del Inframundo**: Versión a distancia. Disparan flechas.
- **[Nuevo] Lobos oscuros de caza**: variante de los lobos para zonas de Aveli/Fischer (de la novela hay lobos; los oscuros de caza son una versión para el juego).
- **[Canon] Oso de montaña**: criatura de la Montaña Kahen.
- **[Canon] Demonios**: Invocados por Varlord. Varios tipos (melee, explosivos, voladores).
- **[Nuevo] Criaturas de Paedric (similares a dragones)**: enemigos de la dimensión maentrica (en la novela se mencionan criaturas tipo dragón en Paedric).
- **[Nuevo] Élites**: Versiones potenciadas con modifiers (Veloz, Escudo, Vampírico, etc.) — mecánica de juego.

### 9.2 Jefes

| Jefe | Zona | Descripción |
|------|------|-------------|
| Manada de Lobos | Bosque | Encuentro tutorial de combate |
| Sinnisgard | Mansión | Espectro soldado de Varlord. Ataca con posesión y hechizos de sombra |
| Oso de Montaña | Montaña Kahen | Bestia gigante, ataques de embestida y zarpazos |
| Eldein | Puerto Fischer | Elfo oscuro, general de Varlord. Combate espada + magia maentrica. Usa hechizo que reduce la magia del jugador |
| Varlord | Paedric | Caballero del Inframundo. Monta caballo espectral. Usa conjuro "Diablo Maestro" para invocar demonios. Fase 2: pelea a pie con magia maentrica. Vulnerable al Orbe de Reyes |
| Requivar Dominis | Paedric (final) | Dios de la magia maentrica. Batalla celestial. Fase 1: Howard solo. Fase 2: Desmond ayuda como aliado invocable. Ataques: Fuego Alquímico Corrupto, hechizos de hielo, descarga mágica. Débil a magia fusionada (arcana + maentrica) |

### 9.3 Enemigos y Jefes (del libro)

Marcas: **[Canon]** = aparece en la novela. **[Nuevo]** = sugerencia de juego.

  ENEMIGOS COMUNES:
    - [Canon] Espíritus / espectros / apariciones
    - [Canon] Lobos de hielo
    - [Canon] Oso de montaña
    - [Canon] Guerreros del Inframundo (espadachines, arqueros, caballería)
    - [Nuevo] Lobos oscuros de caza (variante para Aveli/Fischer)
    - [Canon] Demonios (invocados por Varlord)
    - [Canon] Criaturas de Paedric (similares a dragones)

  SUBJEFES:
    - [Canon] Sinnisgard (espectro soldado, Cap. 1)
    - [Canon] Oso de la guarida (opcional, Cap. 3)
    - [Canon] Eldein (general elfo oscuro, Cap. 4)

  JEFES PRINCIPALES:
    - [Canon] Varlord (Caballero del Inframundo, Cap. 6-7)
    - [Canon] Requivar Dominis (ser mítico, jefe final, Cap. 7)

## 10. ITEMS Y LOOT (Lore-based)

### Gemas (Slot Amuleto)
- **Cuarzo** (común): Canaliza magia básica. **Efecto: A DEFINIR**.
- **Citrino** (mágico): Calidad media. Howard usa una en colgante. **Efecto: A DEFINIR**.
- **Amatista** (raro): Extremadamente rara y poderosa. La del Orbe de Reyes. **Efecto: A DEFINIR**.
- Ver §7.1 para el rol narrativo/visual de las gemas.
- **Slot de gemas: A CONFIRMAR** (conversación pendiente con Martin — las gemas son relevantes para la historia). Por ahora el equipamiento es: 2 anillos + 1 amuleto.

### Orbe de Reyes (Item de quest / ultimate)
- Se obtiene en el Capítulo 3 (Zona 3), en la Biblioteca de Spellion. Se usa como habilidad especial contra jefes (drena poder).
- En la batalla final contra Varlord, el orbe se activa automáticamente en una fase de QTE / cinemática.

### Equipamiento general
- **Arma**: ver §10.2 (varios tipos según el Camino).
- **Armadura**: Túnica / armadura de cuero (defensa). Stats variables. Ver §10.3.
- **Anillos** (2): Stats aleatorios (daño mágico, velocidad, defensa, etc.)
- **Amuleto**: efectos mágicos (el rol de gemas: A CONFIRMAR).

### Rarezas (alineadas con el prototipo)
- Común (`common`, blanco) — 1 stat base
- Mágico (`magic`, azul) — 2 stats
- Raro (`rare`, amarillo) — 3 stats
- Único (`unique`, naranja) — 3 stats + efecto especial (ej: +25% daño a espectros)
- Nota: en el prototipo actual `unique` se muestra en amarillo (idéntico a `rare`); **el color naranja es el definitivo — pendiente de corregir en el prototipo**.

### 10.1 Slots de equipamiento
- Mano derecha (arma principal)
- Mano izquierda (secundaria o escudo)
- Torso (armadura)
- Cabeza (casco o gorro)
- 2x Anillos (efectos mágicos y pasivas)
- Amuleto (efectos mágicos)
- (Opcional) Botas, Cinturón, Guantes
- GEMA (cosmético): Howard lleva su Citrino en un colgante. Brilla al usar magia. Sin efecto en stats.
- SLOT DE ORBE: se desbloquea al obtener el Orbe de Reyes (Capítulo 3). Otorga el indicador de Fusión y permite cargar/detonar la mecánica Smart Bomb (ver 7.5). Sin el Orbe, no hay Fusión.

### 10.2 Armas
Howard puede equipar CUALQUIER arma de la lista. Las armas melee (Espadas, Mazas, Hachas, Escudos) pertenecen al Camino del Guerrero. El Arco pertenece al Camino del Rebelde. Para usar un arma eficazmente, el jugador debe invertir puntos en el Camino correspondiente.

  ARMAS MELEE (Camino del Guerrero):
    ESPADAS (canónica):
      - Daga, Corta, Ancha, Larga, Bastarda, Claymore
      - 3 de una mano, 3 de dos manos.
    MAZAS (ruptura):
      - Garrote, Maza redonda, Maza de pinches, Maza con cadena.
      - Justificación: mismo principio que variedad de builds.
    HACHAS (ruptura):
      - Hacha corta, Hacha larga (2 de una mano, 2 de dos manos).
      - Justificación: ídem.
    ESCUDOS:
      - 3 niveles de peso y calidad.

  ARCO (Camino del Rebelde - ruptura justificada):
    - 3 niveles de calidad.

>> JUSTIFICACIÓN GENERAL DE RUPTURA DE ARMAS:
   El libro describe a Howard usando específicamente "una esbelta y afilada espada". Sin embargo, el diseño original propone variedad de armas para que el jugador elija su estilo. Se mantienen TODAS porque:

   1) El juego es un ARPG y la variedad de armas es esperable.
   2) Howard es un nómada que ha recorrido Mistralis; es creíble que sepa manejar distintas armas.
   3) Las armas melee están bajo el Camino del Guerrero; el arco bajo el Camino del Rebelde. El jugador decide su enfoque.
   4) LÍMITE DE RUPTURA: el Howard de las cinemáticas y la narrativa SIEMPRE usa espada. Las otras armas son opcionales.

### 10.3 Armaduras
3 o 4 niveles de peso y calidad. Howard puede usar cualquier armadura, pero las muy pesadas reducen su eficiencia mágica (menos mana, más coste de hechizos). Justificación: es un hechicero, no un caballero pesado, pero puede sacrificar magia por protección.

### 10.4 Anillos y Amuletos
Efectos mágicos y habilidades pasivas varias (ver sección 10.5).

### 10.5 Efectos mágicos

#### 10.5.1 Resistencias porcentuales
- Resistencia a Fuego
- Resistencia a Electricidad
- Resistencia a Magia (arcana)
- Resistencia a Veneno
- Resistir Todo
- Resistencia a MAENTRICA (reduce daño maentrico específicamente)

#### 10.5.2 Daño añadido
- Daño de Fuego
- Daño de Electricidad
- Daño Mágico (arcano)
- Veneno aplicado
- Daño MAENTRICO: ignora resistencias mágicas normales. Solo la resistencia a maentrica lo reduce. Drena vida del objetivo al impactar.

#### 10.5.3 Buffs, Debuffs y efectos especiales
- Buff/Debuff a atributos (Fuerza, Agilidad, Magia, Vitalidad)
- Buff/Debuff a Vida
- Buff/Debuff a Mana
- Resistencia/Debilidad a daño físico
- Luz/Oscuridad ambiental
- Pérdida constante de Vida/Mana
- Robo de Vida/Mana al golpear
- Regeneración de Vida/Mana
- Convertir daño recibido en Mana
- Devolver daño recibido
- Impacto (empuje)
- Stun
- Curación directa
- Drenaje de poder (Orbe de Reyes): al dañar enemigos con magia, un % del daño carga el indicador de Fusión (ver 7.5).
- Purificación arcana: elimina efectos maentricos negativos.
- Fusión Espiritual: mejora del Camino del Ascendido — al detonar, el espíritu de Desmond aparece para un ataque combinado.

## 11. SISTEMA DE PROGRESIÓN

- **XP** por enemigos eliminados y misiones completadas. Al alcanzar el umbral se sube de nivel (`xp_to_next = 50 × nivel`).
- **Al subir de nivel**: se obtienen **puntos de atributo asignables** (3 por nivel en el prototipo) para repartir en los atributos primarios.
- **Atributos primarios** (como en el prototipo): **Fuerza (Strength), Agilidad (Agility), Inteligencia (Intelligence), Vitalidad (Vitality)**.
- **Stats derivados**: Vida, Maná, Daño físico (mín/máx), Daño de hechizo, Velocidad de ataque, Defensa, Prob. crítica, Regeneración de HP/MP, etc.
- **Aprendizaje de habilidades / Caminos**: los 4 Caminos (ver §8.4) comparten puntos de habilidad de nivel; el Camino del Ascendido progresa por hitos narrativos. El detalle de cómo se reparten los puntos entre atributos y Caminos: **A DEFINIR**.
- **Elección de mejoras al subir de nivel** (ej. elegir entre 3 opciones aleatorias): **A DEFINIR**.

## 12. INTERFAZ (UI)

- **Barra de vida y maná** (esquina superior izquierda, con número de nivel)
- **Barra de XP** (debajo de vida/maná)
- **Barra de RIESGO** (magia maentrica, ver §7.4) — requiere elemento UI dedicado: A DEFINIR
- **Medidor de Fusión** (junto al Orbe de Reyes, ver §7.5) — requiere elemento UI dedicado: A DEFINIR
- **Slots de habilidades** (barra inferior, 4 teclas Q/E/R/F) — la conexión con los Caminos: A DEFINIR
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
| Castear hechizo seleccionado | Clic derecho |
| Habilidad 1-4 | Q / E / R / F |
| Fusión (Smart Bomb) | A DEFINIR (tecla dedicada) |
| Esquivar (roll) | Espacio |
| Inventario | I |
| Panel personaje | C |
| Pausa | Escape |
| Interactuar / Hablar | F |
| Lorefen ataque especial | Shift (cuando esté disponible) |

### 13.1 Controles generales
- WASD para mover relativo a cámara.
- Click izquierdo: ataque con arma equipada en dirección del cursor.
- Click derecho: castear hechizo/habilidad seleccionada.
- Entidades tienen rango de impacto melee dinámico según alcance del arma.
- El prototipo castea hechizos con click derecho. La relación entre el click derecho y la barra Q/E/R/F (qué hechizos van en la barra y cómo se seleccionan): A DEFINIR.

Justificación: El combate refleja las escenas de acción del libro, donde Howard enfrenta oleadas combinando espada y magia. Los controles estándar ARPG permiten traducir fielmente esas escenas a jugabilidad.

### 13.2 Ataque melee
- Varias animaciones, resultado práctico es el mismo.
- Sostener click continúa el ataque.
- Momento de impacto: duración sobre el final de la animación donde se producen sonidos y cálculos de daño. En ese momento se puede detonar un ataque continuo que acelera la siguiente animación; caso contrario, el arma vuelve más lentamente a pose de reposo.

Justificación: Sistema genérico funcional. Howard usa su espada en cada combate importante del libro: lobos de hielo, Eldein, Varlord.

### 13.3 Arco y flecha
Dos modos de ataque básico (click izquierdo cuando el arco está equipado):
- Rápido: resuelve el disparo automáticamente. Estilo Diablo 1/2.
- Sostenido: necesita sostener el click, más daño e impacto.

>> JUSTIFICACIÓN DE RUPTURA:
   En la historia, Howard NUNCA usa arco. Solo espada y magia.
   Sin embargo, el arco está disponible como BUILD ALTERNATIVO por:

   1) VARIEDAD DE GAMEPLAY: el diseño original lo contempla como opción básica. Eliminarlo reduciría las opciones del jugador.

   2) JUSTIFICACIÓN NARRATIVA DÉBIL: Howard es un nómada que ha viajado por todo Mistralis. Es plausible que sepa usar un arco aunque no sea su especialidad. El jugador decide si invertir puntos ahí.

   3) COHERENCIA CON EL MUNDO: los arqueros existen en ambas facciones. El arco no es un arma alienígena al universo de Spellion.

   >> LÍMITE DE RUPTURA: el arco NUNCA aparece en cinemáticas ni en la narrativa. Es puramente mecánico. El Howard canónico del libro usa espada + magia.

### 13.4 Hechizos y habilidades especiales
- Siempre disponibles en click derecho.
- Pueden ser de disparo rápido o sostenido según el hechizo.

>> SISTEMA DE MAGIA DUAL (ver sección 7 para detalle completo):

  A) MAGIA ARCANA: rama "heroica". Se aprende en la Academia Spellion. Se canaliza mediante GEMAS. Tres sub-ramas: DESTRUCCIÓN, RESTAURACIÓN, CONJURACIÓN.

   B) MAGIA MAENTRICA: rama "oscura". No usa MP — tiene su propia barra de RIESGO (ver 7.4). Se obtiene mediante sacrificios y devoción a Requivar Dominis. La usan Varlord, Eldein, y los Guerreros del Inframundo. El jugador accede a ella con consecuencias.

  C) FUSIÓN: combinación de ambas magias. Mecánica especial tipo "SMART BOMB" — ver sección 7.5. No se castea con MP.

Justificación: El sistema de magia dual arcana/maentrica y su fusión es el CORAZÓN de la historia. Reducirlo a daño elemental genérico traiciona la narrativa. Cada rama tiene mecánicas, costos y riesgos distintos. La Fusión es el clímax mecánico y narrativo del juego.

### 13.5 Golpes, Esquive y Armor Class
- Armor Class: derivado de Vitalidad, Fuerza y armadura. Reduce daño recibido mediante descuento directo (mínimo 1). Excedentes añaden bonus a esquivar de ataques débiles.
- Esquive: derivado de Agilidad, Armadura y bonus pasivos. La chance de golpe enemigo se computa contra el esquive del protagonista. Las armaduras tienen atributos de reducción de esquive según peso/maldición. Bonus pasivo puede venir de los Caminos (perks).
- Chance de Golpe: derivado de Destreza del atacante (el prototipo no tiene Destreza — su inclusión: A DEFINIR), reducido por el esquive del receptor. Lo afectan: clase de arma, expertise, requisitos.

Justificación: Sistema sólido y funcional. No contradice la historia.

## 14. ESTÉTICA Y ARTE

- **Modelos**: Low-poly (< 500 triángulos por personaje), estilo PS1
- **Texturas**: Resolución baja (64x64 a 256x256), pixel art, dithering
- **Iluminación**: Sin luces dinámicas — baked ao y vértices coloreados
- **Paleta**: Oscura (marrones, grises, negros) con acentos saturados (rojo fuego, azul escarcha, púrpura maentrico)
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
- Sonidos de eventos de RIESGO, Fusión y magia maentrica: **A DEFINIR**
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

## 18. ORIGEN DE LAS DECISIONES DE DISEÑO

Tabla resumen de dónde proviene cada elemento del diseño actual del juego.

ELEMENTO                              | ORIGEN
--------------------------------------|------------------------------
Combate WASD + clicks                 | Diseño de juego
Ataque melee con animaciones          | Diseño de juego
Arco y flecha                         | Diseño de juego (ruptura justificada)
Hechizos en click derecho             | Diseño de juego (arcana con MP, maentrica con RIESGO)
Armor Class, Esquive, Hit Chance      | Diseño de juego
Estructura de mazmorras               | Diseño de juego
Trampas ambientales                   | Diseño de juego
Eventos y Altares                     | Diseño de juego
Spawns sin level scaling              | Diseño de juego
Slots de equipamiento                 | Diseño de juego (+ orbe; gema por definir)
Armas variadas                        | Diseño de juego (bajo 4 Caminos)
Efectos mágicos                       | Diseño de juego (+ daño maentrico)

ELEMENTO                              | ORIGEN
--------------------------------------|------------------------------
Magia arcana (3 ramas)                | Historia (novela)
Magia maentrica con barra RIESGO      | Historia + mecánica nueva
Fusión como Smart Bomb                | Historia + mecánica nueva
Gemas de canalización                 | Historia (novela)
Orbe de Reyes                         | Historia (novela)
Hechizos icónicos                     | Historia (novela)
4 Caminos + Ascendido                 | Input de diseño colaborativo
Sistema de RIESGO (eventos, ticks)    | Input de diseño colaborativo
Skills híbridos (ej: Infusión Arma)   | Input de diseño colaborativo
Zonas detalladas por capítulo         | Input de diseño colaborativo
Howard único protagonista             | Historia (novela)

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
| 1-3 | **MVP** | Movimiento, combate básico, magia arcana, XP/loot, UI framework, enemigo IA simple, herramientas nivel | Player + 1 enemigo (modelos + anims), geometría mapa, wireframes UI menús | SFX: ataque, hit, muerte, click |
| 4-7 | **ALFA** | Magia dual (arcana+maentrica con RIESGO), Fusión, 4 Caminos, loot completo, mazmorras procedurales, balance | 3 enemigos + assets 3 zonas (Bosque/Montaña/Mansión), UI final, VFX partículas | Música: Bosque, Montaña, Mansión. SFX habilidades |
| 8-10 | **BETA** | IA jefes (4), zonas Ciudad+Nether, save/load, menús, post-process, polish | 4 jefes + assets Ciudad+Nether, anims restantes, VFX finales | Música: Ciudad, Nether, boss themes. SFX completos |
| 11-12 | **GOLD** | Bugfixing, optimización, build distribution, balance final | Pulido visual, optimización texturas, ajustes UI | Mezcla final, masterización |

---

## FASE 1 — PROTOTIPO (MVP) ~Meses 1-3

### Core mecánico
- Movimiento WASD + cámara isométrica
- Ataque básico (clic izquierdo) con animación
- Magia arcana básica (hechizos con MP)
- 1 tipo de enemigo melee que spawnea en oleadas
- Sistema de HP / Maná básico (sin regeneración automática)
- XP y subida de nivel (+ puntos de atributo)
- 1 zona jugable: Bosque (1 mapa, combate infinito tipo arena)

### Arte
- 1 personaje jugador (modelo + textura + anim idle/walk/attack)
- 1 enemigo (modelo + textura + anim idle/walk/attack)
- 1 mapa de prueba geometría simple (paredes, piso, sin decoración)

### Entregable: Build jugable con combate y progresión básica

---

## FASE 2 — ALFA ~Meses 4-7

### Gameplay completo
- Magia dual: arcana (MP) + maentrica (barra de RIESGO)
- Sistema de Fusión (Smart Bomb) con Orbe de Reyes
- 4 Caminos de habilidades (Guerrero, Rebelde, Hechicero, Ritualista)
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
- Fusión definitiva (Volcano Alcántrico) + habilidades ultimate
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
| Bruma (caballo de Howard) | ~300 tris | Idle, Walk, Run | Alfa |

### Enemigos
| Asset | Polígonos | Variantes | Animaciones | Prioridad |
|-------|-----------|-----------|-------------|-----------|
| Duende / Goblin (melee) | ~250 tris | 2 skins | Idle, Walk, Attack, Death | MVP |
| Lobos / Lobo de Hielo | ~300 tris | 2 skins | Idle, Walk, Attack, Death | Alfa |
| Espectro / Aparición | ~200 tris | 1 skin | Idle, Float, Possess, Death | Alfa |
| Guerrero del Inframundo | ~400 tris | 2 skins | Idle, Walk, Attack, Death | Alfa |
| Arquero del Inframundo | ~400 tris | 1 skin | Idle, Walk, Shoot, Death | Alfa |
| Caballería del Inframundo | ~450 tris | 1 skin | Idle, Walk, Mounted, Attack, Death | Alfa |
| Lobo oscuro de caza | ~300 tris | 1 skin | Idle, Walk, Attack, Death | Alfa |
| Criatura de Paedric (tipo dragón) | ~350 tris | 1 skin | Idle, Walk, Attack, Death | Beta |
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
| Altares (curación, buffs, trampas ocultas) | 3 | Alfa |
| Trampas ambientales (pinches, barriles, flechas) | 4 | Alfa |
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
| Gemas (cuarzo, citrino, amatista) | 32x32 | 3 | Alfa |

---

## 3. UI / INTERFAZ

| Asset | Cantidad | Prioridad |
|-------|----------|-----------|
| Barra de vida / maná / XP | 3 barras + background | MVP |
| Barra de RIESGO (magia maentrica) | 1 barra | Alfa |
| Medidor de Fusión (Orbe de Reyes) | 1 indicador | Alfa |
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
| Magia maentrica (aura púrpura oscura) | Alfa |

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
