# Spellion — Task Tracker

> Fuente de verdad: **Jira** (proyecto TAREA, Sprint 1)
> Ver tareas: `[JIRA] list` o `python tools/jira.py list`

## Estado actual

| Métrica | Valor |
|---------|-------|
| Completadas | 74 ✅ |
| Pendientes | 15 🔄 |
| Asignadas a | Fabricio |

## Pendientes (Jira: TAREA-92 a 106)

- [ ] **TAREA-92** — 18 efectos mágicos pendientes (knockback, resistencias, thorns, magic_find, gold_find, critical_chance, spell_damage, etc.)
- [ ] **TAREA-93** — Tipos de estela alternativos (particle_spray, glow_sweep)
- [ ] **TAREA-94** — Música ambiente por zona
- [ ] **TAREA-95** — Cofres y contenedores de loot
- [ ] **TAREA-96** — Puertas interactivas
- [ ] **TAREA-97** — Sistema de resistencias elementales
- [ ] **TAREA-98** — Trayectoria de flecha curva (trail)
- [ ] **TAREA-99** — Equipar objetos con click derecho
- [ ] **TAREA-100** — Sacudida de cámara (screenshake)
- [ ] **TAREA-101** — Jefe: Sinnisgard (Espectro de la Mansión)
- [ ] **TAREA-102** — Jefe: Oso de Montaña
- [ ] **TAREA-103** — Jefes: Eldein, Varlord, Requivar Dominis
- [ ] **TAREA-104** — Zonas: Montaña, Ciudad, Nether
- [ ] **TAREA-105** — Dash / esquiva (roll)
- [ ] **TAREA-106** — Armadura visible en personaje

---

## Bitácora de sesiones

### 2026-07-23 — Sesión final: Jira + Sheets + Docs cleanup

**Logros:**
- Jira actualizado: 89 tareas en Sprint 1, asignadas a Fabricio
- Google Sheet "Spellion - Lista de assets": 4 páginas, columnas unificadas, colores, enemigos canónicos GDD
- Columnas fantasma eliminadas
- 15 tareas pendientes creadas en Jira
- Todos los docs reorganizados

### 2026-07-23 (noche) — Jira completo + protocolo de sesión

**Logros:**
- Jira project key actualizada (KAN → TAREA), board ID dinámico
- 89 tareas en Sprint 1, asignadas a Fabricio, tipo Programacion/Engine
- 15 tareas pendientes creadas (TAREA-92 a 106)
- Protocolo de sesión formalizado en AGENTS.md
- TODO.md actualizado con pendientes + bitácora
- Corregido unicode + empty response en jira.py

### 2026-07-22 — Sheets + Process Notes

**Logros:**
- tools/sheets.py (lectura/escritura Google Sheets)
- [SHEETS] trigger en workflow
- CHANGELOG.md creado
- PROCESS_NOTES.md reducido
- session-spellion.md archivado
- assets.md volcado al sheet y archivado

### 2026-07-11 — Push masivo sesiones Junio

**Logros:**
- Commit y push de todo el desarrollo de Junio
- Items data-driven, sonidos Diablo, Demon, zoom, cursores, audio 4 canales
- Rings/amuletos, color rarity
- Docs organizados en docs/

### 2026-05-25/27 — Lote inicial

**Logros:**
- Player controller, enemigos (zombie, spider, skeleton), combate, magia, arco
- Sangre, mazmorra procedural, loot, inventario
- Ver CHANGELOG.md para detalle completo
