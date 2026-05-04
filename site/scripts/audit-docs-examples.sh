#!/usr/bin/env bash
# audit-docs-examples.sh — coverage gate для docs_examples.
#
# Проверяет, что каждая MDX-страница с non-admonition `<TabItem value="X">`
# имеет соответствующий test-файл в `dagstack/plugin-system-{python,
# typescript,go}/{tests,tests,docs_examples}/`.
#
# Цель: предотвращение docs/binding drift'а между MDX snippets и реальным API
# биндингов. Каждая страница, у которой есть **не-admonition** TS/Python/Go
# код-snippet, должна быть покрыта тестом.
#
# Usage:
#   bash scripts/audit-docs-examples.sh
#
# Конфигурация:
#   BINDINGS_DIR  — корневая папка clone'ов биндингов (default: ../..)
#
# Exit codes: 0 — clean; 1 — отсутствуют тесты для покрытых страниц.

set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="${SITE_DIR}/docs"
REPO_ROOT="$(cd "${SITE_DIR}/.." && pwd)"
BINDINGS_DIR="${BINDINGS_DIR:-${REPO_ROOT}/..}"

PY_REPO="${BINDINGS_DIR}/plugin-system-python"
TS_REPO="${BINDINGS_DIR}/plugin-system-typescript"
GO_REPO="${BINDINGS_DIR}/plugin-system-go"

FAIL=0

say()  { echo "[docs-examples] $*"; }
fail() { echo "[docs-examples] FAIL: $*" >&2; FAIL=1; }
# Coverage gate is in hard-fail mode (every page has tests; missing tests
# block the merge). Pre-PS-7.13 there was a warn-mode that surfaced gaps
# as informational; that's no longer needed.
warn() { fail "$@"; }

# Convert an MDX path to the corresponding test file name.
# `site/docs/intro.mdx`                  -> `intro` (Python: test_intro.py, Go: intro_test.go, TS: intro.test.ts)
# `site/docs/concepts/registry.mdx`      -> `concepts_registry`
# `site/docs/guides/dispatchers/chain.mdx` -> `guides_dispatchers_chain`
slug_for_mdx() {
  local mdx_path="$1"
  local rel="${mdx_path#${DOCS_DIR}/}"
  rel="${rel%.mdx}"
  echo "${rel}" | tr '/' '_'
}

has_python_tabitem() {
  # Returns 0 (true) if the page has a non-admonition Python TabItem.
  # We look for `<TabItem value="python"` followed by a code fence — this
  # excludes TabItems whose body is a `:::warning ... :::` admonition.
  local f="$1"
  awk '
    /<TabItem value="python"/ { in_tab = 1; in_code = 0; next }
    in_tab && /<\/TabItem>/    { in_tab = 0; next }
    in_tab && /^[[:space:]]*```python/ { in_code = 1 }
    END { exit (in_code ? 0 : 1) }
  ' "$f" 2>/dev/null
}

has_typescript_tabitem() {
  local f="$1"
  # TypeScript TabItems can show either ```ts or ```typescript.
  # Pages currently use admonitions for runtime-API TabItems; only TabItems
  # with a `ts` or `typescript` code fence (not `:::warning`) are coverage targets.
  awk '
    /<TabItem value="typescript"/ { in_tab = 1; has_code = 0; next }
    in_tab && /<\/TabItem>/        { in_tab = 0; next }
    in_tab && /^[[:space:]]*```(ts|typescript)/ { has_code = 1 }
    END { exit (has_code ? 0 : 1) }
  ' "$f" 2>/dev/null
}

has_go_tabitem() {
  local f="$1"
  awk '
    /<TabItem value="go"/ { in_tab = 1; in_code = 0; next }
    in_tab && /<\/TabItem>/ { in_tab = 0; next }
    in_tab && /^[[:space:]]*```go/ { in_code = 1 }
    END { exit (in_code ? 0 : 1) }
  ' "$f" 2>/dev/null
}

check_python_test() {
  local slug="$1" mdx="$2"
  local test_file="${PY_REPO}/tests/docs_examples/test_${slug}.py"
  [ -f "$test_file" ] || warn "missing tests/docs_examples/test_${slug}.py for ${mdx#${DOCS_DIR}/}"
}

check_go_test() {
  local slug="$1" mdx="$2"
  local test_file="${GO_REPO}/docs_examples/${slug}_test.go"
  [ -f "$test_file" ] || warn "missing docs_examples/${slug}_test.go for ${mdx#${DOCS_DIR}/}"
}

check_typescript_test() {
  local slug="$1" mdx="$2"
  local test_file="${TS_REPO}/tests/docs_examples/${slug}.test.ts"
  # The slug can use dashes in the page (e.g., `writing-a-plugin`) — the
  # corresponding TS test file keeps the dash form.
  local alt_slug="${slug//_/-}"
  local alt_file="${TS_REPO}/tests/docs_examples/${alt_slug}.test.ts"
  [ -f "$test_file" ] || [ -f "$alt_file" ] \
    || warn "missing tests/docs_examples/${slug}.test.ts (or ${alt_slug}.test.ts) for ${mdx#${DOCS_DIR}/}"
}

# ── Walk every MDX page and check coverage ────────────────────────────

say "=== Coverage gate: docs_examples per binding ==="
say "Python repo: $PY_REPO"
say "TypeScript repo: $TS_REPO"
say "Go repo: $GO_REPO"

while IFS= read -r -d '' mdx; do
  case "$mdx" in
    */api/*) continue ;;       # auto-generated reference, no snippets to mirror
  esac
  slug="$(slug_for_mdx "$mdx")"

  if has_python_tabitem "$mdx"; then
    check_python_test "$slug" "$mdx"
  fi
  if has_go_tabitem "$mdx"; then
    check_go_test "$slug" "$mdx"
  fi
  if has_typescript_tabitem "$mdx"; then
    check_typescript_test "$slug" "$mdx"
  fi
done < <(find "$DOCS_DIR" -name '*.mdx' -print0 | sort -z)

# ── Summary ────────────────────────────────────────────────────────────

if [ "$FAIL" -ne 0 ]; then
  echo
  echo "[docs-examples] FAIL: at least one binding is missing required tests."
  exit 1
fi

echo "[docs-examples] OK: every page has matching tests in every binding."
