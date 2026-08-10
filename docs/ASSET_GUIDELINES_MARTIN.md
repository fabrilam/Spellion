# Asset Guidelines — Spellion (para Martin)

Punto de partida para tu trabajo como Artista 3D / UI del proyecto. Profundizá y agregá tus convenciones con tu OpenCode.

## Resumen del proyecto

- **Spellion**: Diablo-like / Hack & Slash / Action RPG en PC (Godot 4.6).
- **Estética**: 3D poligonal estilo **PS1** — low-poly con texturas pixeladas (64x64 a 256x256), iluminación sin luces dinámicas (baked ao y vértices coloreados).
- **Equipo**: Fabricio (programador/game design), vos (3D/UI), Fede (audio).
- **Referencia principal**: el **GDD absoluto** está en `docs/GDD SPELLION.md` (tiene índice). Leelo antes de modelar cualquier cosa — ahí está el canon, las zonas, los personajes y la lista de assets por fase.

## Tu rol

- Modelado low-poly y texturizado PS1.
- Animación 3D (autorigging).
- Diseño UX/UI, menús, assets de escenario, VFX 3D.

## Pipeline de assets (lineamientos)

- **Formato**: modelos en FBX o GLB listos para Godot.
- **Modelo + animaciones**: el patrón del proyecto es un `.fbx` principal (modelo + esqueleto) + `.fbx` de animaciones individuales (idle, walk, attack, etc.). Seguí esa estructura para que se integren con el pipeline existente.
- **Make Local**: cuando un FBX se importa, para dejar el mesh editable en Godot se usa "Make Local" desde el editor. Es el método que funciona en el proyecto.
- **Integración de animaciones**: hay un protocolo establecido para mergear animaciones de FBX separados en la AnimationLibrary del personaje. Antes de tocar una escena ya integrada, consultá cómo está hecho.

## Naming de nodos

El código del juego detecta las armas por el **nombre del nodo**. Regla importante:

- `WeaponSword`, `WeaponBow`, `WeaponAxe`, `WeaponMace`... (categoría + tipo, con **mayúscula inicial**).
- Si el nombre no matchea la categoría del item, el juego no lo muestra/oculta correctamente.

## Estructura de carpetas

| Carpeta | Qué va |
|---------|--------|
| `assets/models/characters/` | Personajes (Howard, Lorefen, etc.) |
| `assets/models/enemies/` | Enemigos y jefes |
| `assets/models/weapons/` | Armas |
| `assets/models/visitantes/` | Escenario (árboles, plantas, rocas) |
| `assets/textures/` | Texturas por categoría (characters, enemies, floor, ui, items) |

Seguí esta estructura y el naming de archivos que ya existe en cada carpeta.

## Canon narrativo (reglas a respetar)

- **Howard SIEMPRE usa espada en cinemáticas**, sin importar el build del jugador. El arco/hacha/maza son opcionales del gameplay, no del canon.
- La magia oscura se llama **"Maentrica"** (en la novela "maéntrica"). No usar "mántrica".
- Personajes/zonas clave: Howard (protagonista), Lorefen (zorro de fuego), Desmond, van Gunner, Aardin, Varlord, Requivar Dominis; zonas de Riverell a Paedric.
- Antes de diseñar algo visual nuevo (enemigo, jefe, zona), chequeá el GDD: hay marcas **[Canon]** (aparece en la novela) vs **[Nuevo]** (sugerencia de juego).

## Sheet de assets ("Spellion - Lista de assets")

- Ahí se trackean los assets por página (Modelos, Texturas, UI, Sonidos).
- Columnas: `LISTO | Asset | Observaciones | Datos Técnicos | Referencias | Imágenes`.
- Cuando termines un asset: marcá la columna **LISTO** y dejá una observación breve.
- Si necesitás compartir algo con Fabricio, dejalo anotado en Observaciones.

## Backup y verificación

- **Backup**: antes de ediciones grandes, commit o copia del archivo a `tools/backups/` con timestamp.
- **Verificación**: después de guardar, abrí el archivo y confirmá que los nodos/animaciones quedaron. El modelo se tiene que ver en pantalla (no invisible).

## Tu análisis con tu OpenCode

Este documento es el punto de partida. Con tu OpenCode podés:
- Profundizar cada sección (convenciones exactas de Blender, counts de polys, formatos).
- Pedirle que explore el proyecto y documente cómo están hechos los assets existentes.
- Agregar tus propias reglas cuando las definas.
