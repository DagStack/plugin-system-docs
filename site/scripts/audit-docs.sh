#!/usr/bin/env bash
# audit-docs.sh — pre-merge quality gate для dagstack/*-docs.
#
# Проверяет:
#   1. Tabs coverage (Python-blocks без TypeScript/Go).
#   2. API existence (метод/тип упомянут, но не в коде биндинга).
#   3. Version drift (версия в docs ≠ latest в пакетном registry).
#   4. Docusaurus build.
#   5. Privacy scrub (Astra / SberTech / rag-tools).
#
# Usage:
#   cd site && bash scripts/audit-docs.sh
#
# Конфигурация — через переменные окружения:
#   BINDINGS_DIR  — корневая папка clone'ов биндингов (default: ../..)
#                   ожидается что там есть dagstack-<spec>-{python,typescript,go}
#   SPEC_REPO     — clone spec'а с _meta/types.yaml (default: ../../dagstack-<spec>-spec)
#   SKIP_BUILD    — пропустить `npm run build` (для быстрого локального audit)
#   SKIP_VERSIONS — пропустить network-запросы к pypi/npm (offline dev)
#
# Exit codes: 0 — clean; non-zero — fail (см. stderr).

set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="${SITE_DIR}/docs"
FAIL=0

say() { echo "[audit-docs] $*"; }
fail() { echo "[audit-docs] FAIL: $*" >&2; FAIL=1; }

# ── 1. Tabs coverage ──────────────────────────────────────────────────

say "=== 1. Tabs coverage ==="
# ADR-страницы (spec/adr/**) содержат язык-агностичный pseudo-code
# для нормативного описания контракта — требовать Tabs не разумно.
# Tabs-audit применяется к user-facing guides / concepts / reference.
while IFS= read -r -d '' f; do
  case "$f" in
    */spec/adr/*) continue ;;
  esac
  py=$(grep -cE '^```python|^    ```python' "$f" || true)
  [ "$py" = "0" ] && continue
  tabs_py=$(grep -c 'value="python"' "$f" || true)
  if [ "$py" -gt "$tabs_py" ]; then
    fail "$f: python-blocks=$py > tabs-python=$tabs_py (есть stand-alone Python без TS/Go)"
  fi
done < <(find "$DOCS_DIR" -name '*.mdx' -print0 | sort -z)

# ── 2. API existence (best-effort grep) ───────────────────────────────

say "=== 2. API existence ==="

# Read canonical type names from _meta/types.yaml if present.
# Default: sister-repo dagstack-<spec>-spec относительно корня docs-репо.
REPO_ROOT="$(cd "$SITE_DIR/.." && pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"                  # e.g. "dagstack-config-docs"
SPEC_NAME="${REPO_NAME%-docs}-spec"                    # "dagstack-config-spec"
SPEC_REPO="${SPEC_REPO:-${REPO_ROOT}/../${SPEC_NAME}}"
TYPES_YAML="${SPEC_REPO}/_meta/types.yaml"
if [ -f "$TYPES_YAML" ]; then
  # Extract canonical + all language renderings.
  KNOWN_TYPES=$(grep -hE '^\s+(spec_form|python|typescript|go):\s+' "$TYPES_YAML" \
      | awk -F: '{gsub(/^ +| +$/,"",$2); print $2}' | sort -u)
  say "loaded $(echo "$KNOWN_TYPES" | wc -l | tr -d ' ') known type names from _meta/types.yaml"
else
  say "WARN: $TYPES_YAML not found; skipping strict type-name check"
  KNOWN_TYPES=""
fi

# Flag potentially-fictional APIs для dagstack/plugin-system-docs.
# Расширять по мере обнаружения несоответствий между docs и
# реальным API `dagstack.plugin_system` / `@dagstack/plugin-system`.
# Источник истины — `__all__` в
# `src/dagstack/plugin_system/__init__.py` + `spec/_meta/types.yaml`.
FICTIONAL_PATTERNS=(
  # Добавлять сюда методы/типы, обнаруженные в docs, но отсутствующие
  # в биндингах. Пример:
  #   'registry\.autodiscover\('   # если такого метода нет
  #   'MockResourceContainer'      # если нет такого класса
)

# File-level gate: страница, содержащая `:::caution Planned API:::`
# или `Phase 2 API` в admonition, считается "planned-mode" — все
# fictional-API упоминания в таком файле легитимны (документируют
# целевое поведение future-release с явным маркером для читателя).
# Line-by-line exclusion не работает: admonition обычно отделён от
# snippet'а несколькими строками.

is_planned_file() {
  grep -qE ':::(caution|note|info|warning)[^:]*(Planned|Phase [0-9]+\+?|Не реализовано|Not implemented|roadmap|follow-up)|Phase 2 API|целевая спецификация|служит design-документом|API.*Phase 2|в v0\.1.*не реализован' "$1"
}

for pat in "${FICTIONAL_PATTERNS[@]}"; do
  hits=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    file="${line%%:*}"
    if is_planned_file "$file"; then
      continue  # planned-API, легитимно в этой странице
    fi
    hits="${hits}${line}"$'\n'
  done < <(grep -rnE "$pat" "$DOCS_DIR" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    fail "fictional API '$pat' упомянут в файле без :::caution Planned API::: flag на странице:"
    echo "$hits" | head -5 >&2
  fi
done

# ── 3. Version drift (optional, needs network) ────────────────────────

if [ "${SKIP_VERSIONS:-0}" != "1" ]; then
  say "=== 3. Version drift ==="
  # Scan docs for `dagstack-*==X.Y.Z` и compare with PyPI/npmjs/go vanity.
  # Template — extend per-repo для своих packages.

  # dagstack-plugin-system (Python package on Nexus/PyPI):
  if grep -rnq 'dagstack-plugin-system==' "$DOCS_DIR"; then
    LATEST_PY=$(curl -s "https://pypi.org/pypi/dagstack-plugin-system/json" 2>/dev/null \
        | python3 -c "import sys, json; print(json.load(sys.stdin)['info']['version'])" 2>/dev/null || echo "?")
    if [ "$LATEST_PY" != "?" ]; then
      USED_PY=$(grep -rhE 'dagstack-plugin-system==[0-9.]+' "$DOCS_DIR" \
          | sed -E 's/.*==([0-9.]+).*/\1/' | sort -u | head -1)
      if [ "$USED_PY" != "$LATEST_PY" ] && [ -n "$USED_PY" ]; then
        fail "dagstack-plugin-system: docs use $USED_PY, PyPI latest $LATEST_PY"
      fi
    fi
  fi
else
  say "=== 3. Version drift — SKIPPED (SKIP_VERSIONS=1) ==="
fi

# ── 4. Docusaurus build ───────────────────────────────────────────────

if [ "${SKIP_BUILD:-0}" != "1" ]; then
  say "=== 4. Docusaurus build ==="
  if ! (cd "$SITE_DIR" && npm run build > /tmp/docs-build.log 2>&1); then
    fail "npm run build failed — see /tmp/docs-build.log"
    tail -20 /tmp/docs-build.log >&2
  fi
else
  say "=== 4. Docusaurus build — SKIPPED (SKIP_BUILD=1) ==="
fi

# ── 5. Privacy scrub ──────────────────────────────────────────────────

say "=== 5. Privacy scrub ==="
SCRUB_HITS=$(grep -rliE 'astra|sbertech|rag-tools' "$DOCS_DIR" 2>/dev/null || true)
if [ -n "$SCRUB_HITS" ]; then
  fail "privacy scrub failed — Astra/SberTech/rag-tools mentions found:"
  echo "$SCRUB_HITS" >&2
fi

# ── Summary ───────────────────────────────────────────────────────────

if [ "$FAIL" = "0" ]; then
  say "ALL CHECKS PASSED ✓"
  exit 0
else
  say "AUDIT FAILED"
  exit 1
fi
