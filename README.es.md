# sessmove

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | **[Español](README.es.md)**

Mueve un directorio de proyecto **y** reescribe el historial local de todos
los agentes de código con IA, en un solo paso.

```
~/abc  ──renombrado──>  ~/cba
  └─ los registros de /home/me/abc de cada agente  ──sessmove──>  /home/me/cba
```

## Motivación

La mayoría de los agentes de código con IA (Claude Code, Codex, la familia
Gemini CLI, OpenCode, omp, Cursor, Windsurf, …) asocian su historial de
sesiones a la **ruta del proyecto**: los nombres de directorio son alguna
codificación de la ruta (guiones / sha256 / md5) y los valores de `cwd`
viven dentro de JSON, JSONL, SQLite y protobuf. Si mueves o renombras el
directorio, las sesiones antiguas «desaparecen» — siguen en el disco, pero
apuntan a una ruta que ya no existe. `sessmove` mueve el directorio y
reasigna todas esas referencias a la nueva ruta de una vez, con deshacer
completo.

## Instalación

Implementación en Rust, sin dependencias en tiempo de ejecución,
disponible en Linux / macOS / Windows:

```bash
# cada Release etiquetada publica artefactos construidos por GitHub Actions:
#   tar.gz / zip (incluye exe) y paquetes nativos .deb / .rpm / .dmg
#   https://github.com/fly88oj/sessmove/releases

cargo install --path .        # instala los comandos `sessmove` y `agentpath`
```

El idioma de la interfaz sigue automáticamente la configuración regional del
sistema (English / 简体中文 / 日本語 / 한국어 / Español / Français / Deutsch /
Português); puede sobrescribirse con `--lang` o `SESSMOVE_LANG`.

## Uso

```bash
# úsalo en lugar de mv — mueve el directorio Y migra todo el historial
sessmove ~/works/abc ~/works/cba          # equivale a: agentpath mv ...
sessmove ~/works/abc ~/works/archived/    # destino existente: se mueve dentro
sessmove --dry-run ~/works/abc ~/works/cba

# ver qué agentes registran una ruta
agentpath scan --from ~/works/abc

# migrar solo (el directorio ya se movió)
agentpath migrate --from ~/works/abc --to ~/works/cba --yes

# deshacer todo
agentpath backups
agentpath undo --id 20260903-131427-644777
```

Si algo falla, un solo `agentpath undo` restaura tanto la ubicación del
directorio como todo el estado de los agentes. Solo acepta directorios;
se rechazan destinos existentes, directorios padre inexistentes y
origen == destino.

| opción | significado |
|---|---|
| `--agents claude,codex` | limitar a agentes concretos (por defecto: todos) |
| `--extra-root RUTA` | reescribir también un árbol arbitrario; repetible |
| `--deep` | reescribir también menciones dentro del contenido del chat |
| `--backup-dir DIR` | directorio de copias de seguridad (por defecto `~/.sessmove/backups`) |
| `--dry-run` | solo informe |
| `--json` | emitir un único documento JSON en stdout |

## Seguridad

- **Sustitución consciente de límites**: `/a/abc` nunca coincide con
  `/a/abc2` ni `/a/abc-def`; los URI `file://`, el escape JSON y las
  subrutas se tratan correctamente.
- **También se sustituyen los tokens derivados**: sha256 completo,
  sha256[:16], md5 y el nombre de directorio codificado de cada fabricante.
- Copia de seguridad completa antes de cada migración (tras un
  `wal_checkpoint`); `undo` lo restaura todo.
- Los renombrados se omiten si el destino existe; se rechaza `--from /`.

## Agentes admitidos

18 agentes (Claude Code / Codex / Gemini / Qwen / iFlow / OpenCode / omp /
ZCode / Cursor / Windsurf / Antigravity / Crush / Factory Droid / Continue /
pi / Zed / Aider / cc-connect). La tabla completa con ubicaciones de estado
y codificaciones está en el
[README en inglés](README.md#supported-agents).

Sin soporte (investigado): GitHub Copilot CLI, Amp, claude-code-router.

## Contribuir

```bash
git clone https://github.com/fly88oj/sessmove && cd sessmove
cargo test --all                          # 32 pruebas deben pasar
cargo clippy --all-targets -- -D warnings # cero advertencias
cargo fmt --all -- --check
pre-commit install                        # ganchos locales (idénticos a CI)
```

Véase [CONTRIBUTING.md](CONTRIBUTING.md), [CHANGELOG.md](CHANGELOG.md),
[SECURITY.md](SECURITY.md) y [docs/research.md](docs/research.md).

## Licencia

Copyright (C) 2026 sessmove contributors.

Este programa es software libre: puede redistribuirlo y/o modificarlo bajo
los términos de la Licencia Pública General GNU tal como la publica la Free
Software Foundation, ya sea la versión 3 o (a su elección) cualquier versión
posterior. Vea [LICENSE](LICENSE).
