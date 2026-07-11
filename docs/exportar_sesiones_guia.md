# Exportar sesiones de OpenCode a Markdown

## Ubicación de los datos

```
Base de datos:  C:\Users\Zeke\.local\share\opencode\opencode.db  (SQLite, ~127 MB)
Backup files:   C:\Users\Zeke\.local\share\opencode\storage\session\global\*.json
                C:\Users\Zeke\.local\share\opencode\storage\message\<session_id>\*.json
                C:\Users\Zeke\.local\share\opencode\storage\part\<message_id>\*.json
Prompt history: C:\Users\Zeke\.local\state\opencode\prompt-history.jsonl  (solo prompts, sin respuestas)
```

## Esquema SQLite

**session** — cada conversación
| columna | tipo |
|---------|------|
| id | TEXT (ej: `ses_1d0e4bc43ffeGOVcoH34bCRnmF`) |
| title | TEXT |
| slug | TEXT |
| directory | TEXT (path del proyecto) |
| time_created | INTEGER (timestamp UNIX ms) |

**message** — cada mensaje dentro de una sesión
| columna | tipo |
|---------|------|
| id | TEXT (ej: `msg_e52aa42b9001vzsJ2D1Us8Rc8Y`) |
| session_id | TEXT FK → session.id |
| data | TEXT (JSON: `{role: "user"|"assistant", ...}`) |
| time_created | INTEGER |

**part** — contenido real de cada mensaje (texto, tool calls)
| columna | tipo |
|---------|------|
| id | TEXT (ej: `prt_be3dee7850024s8PYRjx72iI10`) |
| message_id | TEXT FK → message.id |
| data | TEXT (JSON: `{type: "text"|"tool"|"step-start"|"step-finish", text: "...", ...}`) |
| time_created | INTEGER |

## Consulta SQL para obtener una sesión completa

```sql
SELECT
    m.time_created,
    json_extract(m.data, '$.role') AS role,
    p.data AS part_data
FROM message m
JOIN part p ON p.message_id = m.id
WHERE m.session_id = 'ses_ID_AQUI'
ORDER BY m.time_created, p.time_created;
```

## Script Python

La implementación completa está en:

```
tools/export_sessions/export_sessions.py
```

Uso básico:

```bash
# Listar sesiones recientes
python tools/export_sessions/export_sessions.py --list

# Exportar una sesión específica
python tools/export_sessions/export_sessions.py --session ses_1d0e4bc43ffeGOVcoH34bCRnmF --output spellion.md

# Con límite de mensajes
python tools/export_sessions/export_sessions.py --session ses_1d0e4bc43ffeGOVcoH34bCRnmF --limit 50

# DB en ubicación no estándar
python tools/export_sessions/export_sessions.py --list --db "C:\Users\Zeke\.local\share\opencode\opencode.db"
```

## Tips

- El timestamp `time_created` está en **milisegundos UNIX** → `datetime.fromtimestamp(ts/1000)`
- Tool calls tienen `tool`, `callID`, `state.input`, `state.output` dentro del JSON de part.data
- Si un mensaje no tiene parts (raro), skip
- La DB suele estar bloqueada si OpenCode está abierto — conectar en modo `PRAGMA locking_mode = NORMAL`

## Sesiones conocidas de Spellion

| ID | Mensajes | Descripción |
|----|----------|-------------|
| `ses_1d0e4bc43ffeGOVcoH34bCRnmF` | 2363 | Sesión principal de Spellion (completa) |
| `ses_1d1a6b605ffeJHbNIDlNmIJTfw` | 311 | Fork de MCP work |
