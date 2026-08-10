# Cómo trabaja Fabricio (para Martin)

Este documento te explica cómo labura Fabricio en el proyecto, así coordinamos mejor.

## Su rol

Fabricio es **programador / game designer / niveles**. En la práctica eso significa:
- Todos los sistemas: movimiento, combate, IA, loot, inventario, magia, audio, UI coding, optimización.
- Game design y level design.
- Integración de los assets que vos hacés.

## Su flujo de trabajo

- **OpenCode + Godot MCP**: desarrolla con un asistente de IA que se conecta al editor de Godot vía el plugin MCP. Por eso hay una regla fuerte en el proyecto: las escenas y scripts se editan con las tools del MCP, nunca a mano con scripts externos.
- **Código data-driven**: muchos datos del juego (items, efectos mágicos) viven en archivos JSON (`_item_data.json`, `_magic_effects.json`), no hardcodeados. Eso significa que agregar contenido nuevo a veces es tan simple como tocar un JSON.
- **Dictado por voz**: a veces usa dictado (Vosk/Whisper) para escribir, así que los mensajes pueden salir con formato raro. No es error de tipeo — es su input.

## Sus tools de gestión

Usa triggers de texto para automatizar tareas de gestión:
- `[GITHUB]` → git fetch/commit/push (control de versiones).
- `[JIRA]` → gestión de tareas y sprints. **Jira es la fuente de verdad** del proyecto.
- `[SHEETS]` → lectura/escritura del Google Sheet de assets.

## Qué necesita el código de tus assets

- **Naming de nodos correcto**: `WeaponSword`, `WeaponBow`, etc. (mayúscula inicial). El código detecta las armas por el nombre del nodo — si no matchea, no se muestra bien.
- **Estructura modelo + animaciones separadas**: el pipeline asume un FBX principal + FBX de animaciones individuales.
- **Respetar el canon del GDD**: Howard siempre espada en cinemáticas, grafía "Maentrica", zonas/personajes según el GDD.

## Cómo comunicarse

1. **Dónde dejar los assets**: en las carpetas de `assets/` (models, textures, etc.) con el naming existente.
2. **Marcar en el sheet**: cuando termines un asset, poné LISTO en la columna y una observación breve.
3. **Avisar antes de tocar escenas de gameplay**: las escenas de personajes/jefes ya integradas son delicadas (hay un protocolo de merge de animaciones). Si necesitás modificarlas, avisá antes.
4. **Si algo no se ve o no funciona**: anotalo — casi siempre es un tema de naming o de pipeline, y se resuelve rápido.

## Regla clave

**No tocar scripts ni escenas de gameplay sin avisar.** Tu fuerte es el modelado, texturas y UI. Si encontrás algo que necesitás cambiar en código o en una escena integrada, consultá primero.

## Si algo no funciona

- El método "Make Local" en el editor es el default para dejar meshes editables desde FBX.
- Hay lecciones técnicas documentadas en el AGENTS del proyecto (pipeline FBX, merge de animaciones, naming).
- Siempre se puede preguntar — el proyecto está pensado para colaborar sin pisarse.
