# dagstack/plugin-system-docs

Documentation for `dagstack/plugin-system` — a Docusaurus site with Python, TypeScript, and Go code samples, prepared for indexing in [context7](https://context7.com).

## What's inside

- **`site/`** — Docusaurus 3.x (TypeScript template). Source language: English; the Russian locale lives under `site/i18n/ru/` and is enabled by the locale switcher.
- **`site/docs/`** — user-facing documentation. Layout: `intro.mdx` (quick start) + `concepts/` (registry, manifest, discovery) + `guides/` (practical tasks) + `api/` (per-language reference).
- **`context7.json`** — at the repo root. Declares which folders to index and contains 20+ `rules` (English LLM instructions) used to drive high-quality answers in context7 agents.
- **`pydoc-markdown.yaml`** — configuration for auto-generating the Python API reference from the package sources.
- **`Makefile`** — handy commands: `make install`, `make build`, `make dev`, `make api-python`, `make validate`.

## Running locally

```bash
# Install dependencies
make install

# Start the dev server on :3000
make dev

# Build the static site into site/build/
make build
```

## Refreshing the API reference

The Python API reference is built by `pydoc-markdown` from the installed package:

```bash
# First, install the package in the active environment
pip install dagstack-plugin-system

# Then regenerate the pages
make api-python
```

Generated `.mdx` files land in `site/docs/api/python/` and are committed to the repository — so the reference is visible immediately after cloning, without a generation step.

## Indexing in context7

The repo-root `context7.json` is ready, but submission to [context7.com/add-package](https://context7.com/add-package) is deferred until the quality bar is reached (pages accumulated, final architectural review passed).

## Related repositories

- [`dagstack/plugin-system-spec`](https://github.com/dagstack/plugin-system-spec) — the normative specification, ADRs, wire-format.
- [`dagstack/plugin-system-python`](https://github.com/dagstack/plugin-system-python) — Python binding (`pip install dagstack-plugin-system`).
- [`dagstack/plugin-system-typescript`](https://github.com/dagstack/plugin-system-typescript) — TypeScript binding (roadmap).
- [`dagstack/plugin-system-go`](https://github.com/dagstack/plugin-system-go) — Go binding (`go.dagstack.dev/plugin-system`, Phase 1 rc).

## License

Apache-2.0.
