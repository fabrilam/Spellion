# Jira — RedSky Games / Spellion

**URL:** https://fabriciolamorte.atlassian.net/jira/software/projects/KAN/boards/2
**Proyecto:** KAN (RedSky Games - Spellion)
**CLI:** `python tools/jira.py <comando>`

---

## Comandos útiles

```bash
# Listar todas las issues
python tools/jira.py list

# Crear tarea
python tools/jira.py create "Resumen de la tarea"

# Ver detalle
python tools/jira.py get KAN-1

# Cambiar estado
python tools/jira.py update KAN-1 "En curso"
```

## Estados disponibles

- Tareas por hacer
- En curso
- Hecho

## Notas

- La config de credenciales está en `tools/jira_config.json` (excluído del repo)
- Para configurar: `python tools/jira.py config`
