# AI / Online Tools para generación de iconos — Spellion

> Investigación: 26 mayo 2026
> Contexto: necesitábamos iconos 48×48 para UI de hechizos, inventario y stats.

---

## ✅ Funcionan

### game-icons.net — SVG, CC0, sin API key
- **URL base:** `https://game-icons.net/icons/ffffff/000000/1x1/{artist}/{icon-name}.svg`
- **Licencia:** CC0 (dominio público, sin atribución requerida)
- **Método:** GET directo, sin headers especiales
- **Ejemplo curl:**
  ```
  curl https://game-icons.net/icons/ffffff/000000/1x1/lorc/fireball.svg -o icon.svg
  ```
- **Artistas que funcionan:** `lorc` (~70% hits), `delapouite` (~40%)
- **Íconos útiles encontrados:**
  | Ícono | Path |
  |-------|------|
  | 🔥 Fireball | `lorc/fireball.svg` |
  | ✚ Heal | `delapouite/healing.svg` |
  | ✨ Magic | `lorc/magic-swirl.svg` |
  | 🎒 Inventory | `lorc/swap-bag.svg` |
  | ⬆️ Stats | `delapouite/upgrade.svg` |
  | 🔥 Fire dash | `lorc/fire-dash.svg` |
  | 🔥 Fire wave | `lorc/fire-wave.svg` |
  | 🔥 Fire bottle | `lorc/fire-bottle.svg` |
  | 🧪 Health potion | `delapouite/health-potion.svg` |
  | 🛡️ Healing shield | `delapouite/healing-shield.svg` |
  | 💡 Light bulb | `lorc/light-bulb.svg` |
  | 🌐 Magic swirl | `lorc/magic-swirl.svg` |
  | 🌐 Magic gate | `lorc/magic-gate.svg` |
  | 🌐 Magic palm | `lorc/magic-palm.svg` |
  | 🌐 Magic portal | `lorc/magic-portal.svg` |
  | 🌐 Magic shield | `lorc/magic-shield.svg` |
  | 🎒 Swap bag | `lorc/swap-bag.svg` |
  | 🎒 Knapsack | `lorc/knapsack.svg` |
  | ✨ Aura | `lorc/aura.svg` |
  | ⬆️ Upgrade | `delapouite/upgrade.svg` |

### Flaticon — PNG, 128×128, requiere atribución
- **URL base:** `https://cdn-icons-png.flaticon.com/128/{id}/{id2}.png`
- **Licencia:** Gratis con atribución al autor
- **Método:** GET directo
- **Ventaja:** PNG listo para usar, sin conversión
- **Desventaja:** Hay que encontrar los IDs correctos, atribución requerida

### OpenClipart — PNG, dominio público
- **URL base:** `https://openclipart.org/image/256px/svg_to_png/{id}/{name}.png`
- **Licencia:** Dominio público
- **Método:** GET directo
- **Desventaja:** Server inestable (HTTP 500 frecuente)

---

## ❌ No funcionan

### pollinations.ai
| Endpoint | Resultado | Notas |
|----------|-----------|-------|
| `https://pollinations.ai/p/{prompt}` | HTML (la web) | No recomendado |
| `https://gen.pollinations.ai/image/{prompt}` | **401 Unauthorized** | Endpoint nuevo requiere auth |

### SVG Repo
| Endpoint | Resultado | Notas |
|----------|-----------|-------|
| `https://www.svgrepo.com/show/{id}/{name}.svg` | **429 Too Many Requests** | Rate limit agresivo |

### Pixabay
| Endpoint | Resultado | Notas |
|----------|-----------|-------|
| `https://pixabay.com/vectors/...` | **403 Forbidden** | Bloquea descargas directas |

---

## Conclusión

Para el proyecto Spellion:
- **game-icons.net** es la mejor fuente — CC0, estable, estilo juego, SVG que Godot importa nativamente
- Los 5 iconos actuales (`spell_fire.svg`, `spell_heal.svg`, `icon_spell.svg`, `icon_inventory.svg`, `icon_stats.svg`) usan esta fuente
- Si se necesitan más iconos en el futuro, buscar primero en `lorc/` y `delapouite/` de game-icons.net
