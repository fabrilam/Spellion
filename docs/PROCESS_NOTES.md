# Process Notes — Operaciones MCP y lecciones técnicas

## Lo que funcionó bien

### Operaciones confiables vía MCP
1. **Crear nodos** (`create_node`) → siempre funcionó
2. **Renombrar nodos** (`rename_node`) → funcionó
3. **Asignar scripts** (`attach_script`) → funcionó
4. **Obtener árbol de escenas** (`get_scene_tree`) → funcionó (pero output truncado para escenas grandes)
5. **Actualizar propiedades** (`update_node_property`) → funcionó para valores simples (position, rotation, scale)
6. **Abrir/guardar escenas** (`open_scene`, `save_scene`) → funcionó
7. **Ejecutar script en editor** (`execute_editor_script`) → funcionó para lógica simple pero no persiste cambios al guardar
8. **Ejecutar proyecto** (`run_project`, `stop_project`) → funcionó con `allow_window: true`

### Operaciones que funcionaron con limitaciones
1. **Crear recursos via `execute_editor_script`**:
   - `ResourceSaver.save()` crea el .tres pero el contenido puede no persistir correctamente
   - Mejor: escribir el .tres manualmente con `write` tool (formato texto plano)
2. **Hacer editable un instance**:
   - `node.set_editable_instance(root, true)` en `execute_editor_script` → funciona pero NO persiste al guardar
   - El `editable = true` en .tscn funciona si se pone en el formato correcto
3. **Agregar hijos a nodos existentes**:
   - `create_node` para crear, `add_child` en editor script para hijos más complejos
   - El `owner` del hijo debe setearse al root de la escena para persistir

## Lo que NO funcionó / fue problemático

### Problemas con `execute_editor_script`
1. **Los cambios en nodos NO PERSISTEN al guardar la escena**:
   - `add_child()` en editor script → el hijo aparece en editor pero no se guarda al .tscn
   - `set_property()` en nodos → algunos cambios se guardan, otros no
   - **Solución**: Editar el .tscn directamente con la tool `write` o `edit`
2. **No se puede capturar output** de `print()` desde el script:
   - El campo `output` siempre es `[]`
   - **Solución**: Escribir a un archivo con `FileAccess` y luego leerlo
3. **Script compilation falló** con scripts multi-línea que usan `get_node()` o referencias a paths
   - **Solución**: Mantener scripts simples, usar `create_node` para crear estructuras

### Problemas con archivos .tscn
1. **Insertar sub_recursos en medio del archivo** → rompe el formato
   - Ocurrió al copiar animación Sword1 desde Mystic
   - **Solución**: Usar `execute_editor_script` con `add_animation()` en vez de editar el archivo manualmente
2. **Formato del archivo**: Godot 4 usa format 3 o 4. No mezclar.
   - Format 3: `[gd_scene format=3]`
   - Format 4: `[gd_scene format=4]` (más nuevo, permite más estructuras)

### Problemas con el flujo de trabajo
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

## Búsqueda de assets 3D online
- **Quaternius** (itch.io, CC0): mejores assets low-poly. Pero itch.io requiere sesión para descargar → no automatizable desde OpenCode.
- **KayKit** (itch.io, CC0): personajes + armas low-poly. Mismo problema de sesión.
- **OpenGameArt.org**: descarga directa sin sesión. Buena fuente para texturas y modelos simples.
- **Mixamo** (Adobe, gratis): animaciones humanoides FBX. Requiere re-targeting al skeleton de Howard.
- **Solución para armas PS1**: generación procedural de escenas Godot con geometría simple (BoxMesh, CylinderMesh, SphereMesh). Rápido, confiable, estéticamente consistente. Script en `scripts/generate_weapons.py`.
