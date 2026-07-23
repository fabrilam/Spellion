# Process Notes — Spellion Development with OpenCode + Godot MCP

## Setup

### Godot MCP Plugin
- **Plugin**: `godot_mcp` (community plugin by yurineko73)
- **Instalación**: Desde AssetLib o copiando `addons/godot_mcp/` al proyecto
- **Activación**: `auto_start=true` en `plugin.cfg`. El servidor HTTP arranca en puerto 9080
- **Conexión OpenCode**: Configurar en `opencode.json`:
  ```json
  {
    "mcp": {
      "godot-mcp": {
        "type": "remote",
        "url": "http://localhost:9080/mcp"
      }
    }
  }
  ```

## Flujo de trabajo

### Comunicación con Godot
- **LLAMAR herramientas**: Via `tools/call` con JSON-RPC:
  ```json
  {"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create_node","arguments":{...}}}
  ```
- **Herramientas disponibles**: Usar `tools/list` primero para obtener la lista actual

### Lo que funcionó bien

#### Operaciones confiables vía MCP
1. **Crear nodos** (`create_node`) → siempre funcionó
2. **Renombrar nodos** (`rename_node`) → funcionó
3. **Asignar scripts** (`attach_script`) → funcionó
4. **Obtener árbol de escenas** (`get_scene_tree`) → funcionó (pero output truncado para escenas grandes)
5. **Actualizar propiedades** (`update_node_property`) → funcionó para valores simples (position, rotation, scale)
6. **Abrir/guardar escenas** (`open_scene`, `save_scene`) → funcionó
7. **Ejecutar script en editor** (`execute_editor_script`) → funcionó para lógica simple pero no persiste cambios al guardar
8. **Ejecutar proyecto** (`run_project`, `stop_project`) → funcionó con `allow_window: true`

#### Operaciones que funcionaron con limitaciones
1. **Crear recursos via `execute_editor_script`**:
   - `ResourceSaver.save()` crea el .tres pero el contenido puede no persistir correctamente
   - Mejor: escribir el .tres manualmente con `write` tool (formato texto plano)
2. **Hacer editable un instance**:
   - `node.set_editable_instance(root, true)` en `execute_editor_script` → funciona pero NO persiste al guardar
   - El `editable = true` en .tscn funciona si se pone en el formato correcto
3. **Agregar hijos a nodos existentes**:
   - `create_node` para crear, `add_child` en editor script para hijos más complejos
   - El `owner` del hijo debe setearse al root de la escena para persistir

### Lo que NO funcionó / fue problemático

#### Problemas con `execute_editor_script`
1. **Los cambios en nodos NO PERSISTEN al guardar la escena**:
   - `add_child()` en editor script → el hijo aparece en editor pero no se guarda al .tscn
   - `set_property()` en nodos → algunos cambios se guardan, otros no
   - **Solución**: Editar el .tscn directamente con la tool `write` o `edit`
2. **No se puede capturar output** de `print()` desde el script:
   - El campo `output` siempre es `[]`
   - **Solución**: Escribir a un archivo con `FileAccess` y luego leerlo
3. **Script compilation falló** con scripts multi-línea que usan `get_node()` o referencias a paths
   - **Solución**: Mantener scripts simples, usar `create_node` para crear estructuras

#### Problemas con archivos .tscn
1. **Insertar sub_recursos en medio del archivo** → rompe el formato
   - Ocurrió al copiar animación Sword1 desde Mystic
   - **Solución**: Usar `execute_editor_script` con `add_animation()` en vez de editar el archivo manualmente
2. **Formato del archivo**: Godot 4 usa format 3 o 4. No mezclar.
   - Format 3: `[gd_scene format=3]`
   - Format 4: `[gd_scene format=4]` (más nuevo, permite más estructuras)

#### Problemas con el flujo de trabajo
1. **No se puede ver output de runtime**: `get_runtime_info`, `get_runtime_scene_tree` etc. están deshabilitados en modo seguro
2. **Tiempo de respuesta**: Cada llamada MCP toma ~1-3s. Operaciones secuenciales lentas.
3. **PowerShell escaping**: JSON con Python inline en PowerShell requiere escapes complejos
   - **Solución**: Escribir scripts Python a archivo .py y ejecutarlos
4. **UIDs de recursos**: Al crear archivos con `write`, no tienen UID hasta que Godot hace filesystem scan
   - **Solución**: Trigger `EditorInterface.get_resource_filesystem().scan()` después de crear archivos

### Lecciones aprendidas

#### Para crear escenas complejas
1. Usar `create_scene` para crear la escena vacía
2. Usar `create_node` + `update_node_property` para armar la estructura
3. No confiar en `execute_editor_script` para cambios que deben persistir
4. Para cambios complejos, editar el .tscn directamente con `write` tool

#### Para importar assets de otros proyectos
1. Copiar archivos via bash (`Copy-Item`)
2. Trigger filesystem scan en Godot
3. Verificar imports via `.godot/imported/` folder
4. Crear escenas wrapper que referencien los modelos importados

#### Debugging
- `print()` en editor script → no se ve
- Escribir a archivo con `FileAccess` → funciona pero requiere lectura separada
- La forma más confiable: correr el proyecto y observar visualmente
- `get_editor_logs()` funciona para capturar errores del editor

## Comandos MCP útiles

```bash
# Listar herramientas
python -c "import requests; r=requests.post('http://localhost:9080/mcp', json={'jsonrpc':'2.0','id':1,'method':'tools/list','params':{}}); print(r.json())"

# Estado del editor
python -c "import requests; r=requests.post('http://localhost:9080/mcp', json={'jsonrpc':'2.0','id':1,'method':'tools/call','params':{'name':'get_editor_state','arguments':{}}}); print(r.json())"

# Abrir escena
python -c "import requests; r=requests.post('http://localhost:9080/mcp', json={'jsonrpc':'2.0','id':1,'method':'tools/call','params':{'name':'open_scene','arguments':{'scene_path':'res://main.tscn','allow_ui_focus':True}}}); print(r.json())"

# Ejecutar proyecto
python -c "import requests; r=requests.post('http://localhost:9080/mcp', json={'jsonrpc':'2.0','id':1,'method':'tools/call','params':{'name':'run_project','arguments':{'allow_window':True}}}); print(r.json())"

# Detener proyecto
python -c "import requests; r=requests.post('http://localhost:9080/mcp', json={'jsonrpc':'2.0','id':1,'method':'tools/call','params':{'name':'stop_project','arguments':{'allow_window':True}}}); print(r.json())"
```

## Sesión 2026-05-17 — Blood effects, sonidos, minimapa, bosque

### Qué funcionó bien
- **Sistema impact → particles → decals** sólido una vez entendido el flujo
- `create_tween()` secuencial con `set_parallel(true)` para animaciones paralelas (escalar + fade)
- `material_override.duplicate()` para evitar compartir material entre instancias de decals
- `Sprite3D` con billboard para impacto (simple, sin mesh, sin material custom)
- `CPUParticles3D` con propiedades inline funciona en GL Compatibility
- `is_instance_valid()` para proteger callbacks contra padres inválidos
- `Callable()` con `CONNECT_ONE_SHOT` para conexiones de un solo uso
- Sonidos descargados de Mixkit via `Invoke-WebRequest` directo al CDN
- `_unused/` folder para sonidos de respaldo no usados
- `Control` + `_draw()` para minimapa (en lugar de CanvasLayer directo)
- `Basis.looking_at(-dir)` para invertir orientación de enemigos
- Setear `position` antes de `add_child` evita bugs de `global_position` en `_ready()`

### Qué falló / pérdida de tiempo
- **`visible = false` en `blood_spray.tscn`** — horas de debug. El nodo spawneaba invisible.
- `GPUParticles3D` con `draw_pass_1` en .tscn no preloadaba → migrar a código o `CPUParticles3D`
- `clamp()` y `surface_get_material()` devuelven `Variant` → warnings como errores en Godot 4.6
- `_ready()` se dispara antes de que `add_child` termine de posicionar → usar `position` antes de `add_child`
- `quad.surface_set_material()` no es confiable para `draw_pass_1` → mejor `material_override` en `MeshInstance3D`
- No revisar `visible = false` desde el principio
- Decals al mismo Y que el piso causan z-fighting → usar `y = -0.49` vs piso en `-0.5`
- `randomize()` en `_ready()` de decals → todas las instancias del mismo frame comparten seed

### Lecciones nuevas
- **Siempre revisar `visible`** en escenas instanciadas antes de debuggear materiales o posiciones
- Usar `SFXPlayer2` como segundo canal de audio para sonidos superpuestos
- `PackedScene.instantiate()` duplica sub-recursos → pero `.duplicate()` manual es más seguro
- Posicionar objetos decorativos 0.01u por encima del piso para evitar z-fighting
- Preload de sonidos en `Dictionary` es rápido y limpio
- Para sonidos Mixkit: el patrón de URL es `https://assets.mixkit.co/active_storage/sfx/ID/ID-preview.mp3`
- **Script `scripts/fetch_mixkit_sounds.py`** para listar y descargar sonidos de Mixkit por tag con nombres descriptivos:
  ```
  python scripts/fetch_mixkit_sounds.py punch           # lista todos los sonidos
  python scripts/fetch_mixkit_sounds.py punch --download 2155  # baja uno
  ```
  El script parsea el HTML de Mixkit buscando `data-audio-player-item-id-value` (ID) y `item-grid-card__title` (título).
  Los sonidos se guardan en `assets/audio/_unused/` como `mixkit_ID_nombre_del_sonido.mp3`.

### Búsqueda de assets 3D online
- **Quaternius** (itch.io, CC0): mejores assets low-poly. Pero itch.io requiere sesión para descargar → no automatizable desde OpenCode.
- **KayKit** (itch.io, CC0): personajes + armas low-poly. Mismo problema de sesión.
- **OpenGameArt.org**: descarga directa sin sesión. Buena fuente para texturas y modelos simples.
- **Mixamo** (Adobe, gratis): animaciones humanoides FBX. Requiere re-targeting al skeleton de Howard.
- **Solución para armas PS1**: generación procedural de escenas Godot con geometría simple (BoxMesh, CylinderMesh, SphereMesh). Rápido, confiable, estéticamente consistente. Script en `scripts/generate_weapons.py`.

## Sesión 2026-05-19 — Inventario, items, sonidos, decor, save/load

### Nuevos sistemas implementados
- **Inventario completo**: grid 10×4 con drag & drop, equip slots (7), swap items, drop to world con modelo 3D. Layout desde `_inventory_layout.json` con backdrop image.
- **Items**: Resource `Item.gd` con `str_scale_min/max`, `grid_width/height`, `stats` dictionary. `Inventory.gd` con soporte multi-celda.
- **Daño por arma**: fórmula `daño = item_base + fuerza × item_str_scale`. Cada arma tiene su propia escala de fuerza. Unarmed: base 1-2, scale 0.15/0.3. Espada: base 4-7, scale 0.4/0.7.
- **Attack speed**: base 1.8, ganancia por agilidad 0.015, modificador por arma (espada -0.5). Stats screen muestra min-max.
- **Puños aleatorios**: `play_sfx_random("punch")` con 15 sonidos de Mixkit + pitch variation. Sin arma → puños.
- **World item pickup**: `item_world.gd` con Area3D radius 2.5, Label 2D proyectado, tecla E para recoger. Items con `scene_path` usan modelo 3D real al dropear.
- **Save/Load**: SaveManager autoload (F5/F9 + botones en menú Stats). Guarda stats, posición, inventario grid + equipado en JSON.
- **Decor transparencia**: `decor_fade.gd` en árboles/bush/plantas. Fade al 15% si `oz > pz + 1.0` (sur del jugador). Material `.duplicate()` + `set_surface_override_material()` para no compartir.
- **Enemigos deambulan**: wander aleatorio cuando lejos (> 15u). Miran hacia wander_target.
- **Rage orb**: orbe púrpura que aplica ×4 visión + ×1.5 velocidad a TODOS los enemigos por 10s.
- **Click sostenido ataca**: sin gate `_mouse_held`. Mientras mouse presionado + cooldown → ataca.
- **Armas en mano**: 4 escenas `weapon_hand_X.tscn` pre-instanciadas en `SwordAttach` (BoneAttachment3D en hand.r). Se togglea `visible` según arma equipada. Ajustable visualmente en editor.

### Bugs corregidos
- `_melee_damage_max` se sobrescribía a sí misma en `_update_derived()` → daño crecía infinito. Separado en `_item_dmg_min/max` (base) y `_dmg_min/max` (computado).
- `.tscn` generados con sub-resources después del `[node]` → Godot no lo acepta. **Orden correcto**: todos los `[sub_resource]` primero, luego `[node]`.
- `is_key_just_pressed()` no existe en Godot 4 → usar patrón held/released con flags.
- `CanvasLayer.position` no existe → usar `Control` hijo para posicionar elementos 2D.
- Shared materials en decor → `.duplicate()` obligatorio para cada instancia.
- `GPUParticles3D` no preload en tscn → crear en código o usar `CPUParticles3D`.
- `clamp()` y `surface_get_material()` devuelven `Variant` → warning como error en Godot 4.6.

### Assets descargados (Mixkit)
- 15 sonidos de puño → `_unused/hit/` (impact_of_a_strong_punch, body_punch_quick_hit, etc.)
- 11 sonidos de sword → `_unused/sword/` (sword_strikes_armor, samurai_sword_impact, etc.)
- Sonidos player_hit, orb_pickup, ui_click desde tags "pain", "drink", "click"
- `scripts/fetch_mixkit_sounds.py` — herramienta para buscar y descargar por tag con nombres reales

### Assets generados proceduralmente
- `scripts/generate_weapons.py` → 5 armas low-poly: hand_axe, mace, flail, arrow, dagger
- Format: `[sub_resource]` antes de `[node]` en .tscn
- Materiales StandardMaterial3D con colores planos (estilo PS1)

### Assets externos copiados
- `rf_sfx_database/` → 214 WAVs de Age of Wonders (Attack, Hit_Death, Events, Int, Moves, Places)
- `Nivel1_Assets/` → texturas y modelos de Visitantes (árboles, arbustos, plantas, edificios)

### Metodologías establecidas
- **Armas en mano**: crear escena `weapon_hand_CATEGORIA.tscn` con el transform de posición horneado. Pre-instancia como hijo de `SwordAttach` en `character_root.tscn`. Toggle visible según arma equipada.
- **Items**: definir en `player.gd._setup_inventory()` con array de datos. Item `scene_path` para modelo 3D world, escena `weapon_hand_X` para modelo en mano.
- **Sonidos**: descargar con `fetch_mixkit_sounds.py`, organizar en `_unused/CATEGORIA/`, referenciar desde `audio_manager.gd._sound_groups[]`.
- **Decoración**: scatter con `forest_scatter.gd` + `decor_fade.gd` por objeto para transparencia.

### Próximos pasos
- Hit chance / Dodge / Crit system (stats: dexterity-based)
- Arco y flecha como ataque ranged (arrow projectile)
- Mazmorras con trampas, altares, spawns por leveled list
- Modelos 3D reales desde Blender/Mixamo para reemplazar generados

Stack técnico

| Herramienta | Uso |
|-------------|-----|
| Godot Engine 4.6 | Motor de juego (GL Compatibility, Jolt Physics) |
| OpenCode | Asistente AI de codificación |
| Godot MCP Native | Plugin de integración MCP (v1.0.0) |
| Blender | Modelado 3D de assets externos |
| Python 3.12 | Scripts auxiliares para MCP |
| PowerShell 5.1 | Operaciones de archivos |
