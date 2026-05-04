# Целевая карта сайта — `plugin-system-docs`

Зафиксированный план наполнения. P1 — то, что должно быть к моменту отправки в context7 (≈25 страниц). P2/P3 — расширения после первого submission.

## Принципы

- Одна страница — один концепт или одна задача.
- Prose на русском, идентификаторы на английском; анлицизмы минимизируем.
- Примеры кода — `<Tabs groupId="lang" queryString="lang">` с порядком Python → TypeScript → Go.
- `context7.json` — публичный API-контракт сайта для LLM; содержит 20–30 императивных rules.
- Privacy scrub (`make scrub-check`) — перед каждым push'ом.

## Карта

### 0. Homepage

- `/` (React-страница) — hero, value proposition, ссылка на `docs/intro`.

### 1. Быстрый старт — `docs/getting-started/`

- `intro` — `[P1] ★` Быстрый старт за 5 минут (есть).
- `what-is-a-plugin` — `[P1]` Концептуальный обзор для новичка.
- `installation` — `[P1]` venv, зависимости, совместимость версий.
- `first-plugin` — `[P1]` Расширенный walkthrough echo-плагина с тестами (≈15 минут).

### 2. Понятия — `docs/concepts/`

- `registry` — `[P1] ★` Реестр плагинов (есть).
- `manifest` — `[P1] ★` Манифест `dagstack.toml` (есть).
- `discovery` — `[P1] ★` Обнаружение плагинов (есть).
- `kinds` — `[P1]` Виды плагинов, встроенные + кастомные.
- `runtimes` — `[P1]` Исполняющие среды (`in_process` / `mcp_stdio` / `mcp_http`).
- `dispatch` — `[P1]` Обзор пяти классов диспетчеризации.
- `resources` — `[P1]` Resources DI, стандартные Protocol'ы.
- `invariants` — `[P1]` 8 runtime-инвариантов (ADR-0003).
- `lifecycle` — `[P1]` Жизненный цикл плагина (перенести из guides/).

### 3. Руководства — `docs/guides/`

- `writing-a-plugin` — `[P1] ★` Пошаговое руководство (есть).
- `configuration` — `[P1] ★` Конфигурация через config-spec (есть).
- `testing` — `[P1]` Unit + contract suite + тестовые ресурсы.
- `dependencies` — `[P1]` `depends_on`, topo sort, `DependencyCycle`.
- `dispatchers/` — `[P1]` пять подстраниц (singleton / broadcast-collect / broadcast-notify / chain / capability).
- `resources-di` — `[P2]` Как задекларировать и подменить.
- `versioning` — `[P2]` `core_version`, semver, миграции.
- `packaging` — `[P2]` pip-пакет через `pyproject.toml[tool.dagstack.plugin]`.
- `debugging` — `[P2]` Типичные ошибки, troubleshooting.
- `out-of-process` — `[P2]` MCP stdio/http, когда применять.

### 4. Спецификация — `docs/spec/`

*Вариант B: синопсисы ADR на русском + ссылки на полный текст в `dagstack/plugin-system-spec`.*

- `overview` — `[P1]` Что такое спецификация, как читать.
- `adr/`
  - `0001-core` — `[P1]` Архитектура ядра.
  - `0002-hook-invocation` — `[P1]` Пять классов диспетчеризации — нормативно.
  - `0003-runtime-invariants` — `[P1]` 8 инвариантов с таблицей и примерами.
  - `0004-hookspec` — `[P1]` YAML-wrapper + emit types.
  - `0005-horizontal-hooks` — `[P1]` Governance/quota/observability.
  - `0006-discovery` — `[P1]` File-based discovery контракт.
- `conformance` — `[P2]` Как binding'и подтверждают соответствие.
- `cross-spec` — `[P2]` Связь с config-spec, logger-spec, tenancy-spec.

**Принцип раздела**: каждый ADR-page — 3–5 параграфов русскоязычного резюме + нормативные таблицы (если применимо) + 1–2 кросс-языковых примера. В конце — явная ссылка на полный ADR в Gitea (для авторов binding'ов, которые читают formal normative text).

### 5. Справочник форматов — `docs/reference/`

- `manifest-schema` — `[P1]` Полная схема `dagstack.toml`.
- `kinds-list` — `[P1]` Все встроенные виды + контракты.
- `runtimes-list` — `[P1]` Все runtime'ы с таблицей свойств.
- `resources-list` — `[P2]` Clock / Rng / BlobStore / HttpClient + тестовые реализации.
- `errors` — `[P1]` Полная таксономия `PluginRegistryError`.

### 6. Справочник API — `docs/api/`

- `python/` — `[P1] ★` Автогенерация через `pydoc-markdown` (placeholder есть; рабочая генерация — PR 3).
- `typescript` — `[P2] ★` Placeholder (есть); полноценная документация — когда binding выйдет.
- `go` — `[P2] ★` Placeholder (есть); полноценная документация — когда binding выйдет.

### 7. Интеграции — `docs/integrations/`

- `config` — `[P2]` Связка с `dagstack/config`.
- `logger` — `[P2]` Trace correlation, structured logs.
- `tenancy` — `[P2]` `TenantContext`, изоляция.
- `fastapi` — `[P2]` Lifespan, DI, тестирование.
- `dagster` — `[P2]` Asset-mapping, partition_keys.
- `celery` — `[P2]` Task-wrapping, serialization boundaries.
- `pytest` — `[P2]` Fixtures, contract suite.

### 8. Hookspec — `docs/hookspec/`

*Продвинутая тема для авторов собственных видов плагинов.*

- `overview` — `[P2]` ADR-0004 на человеческом языке.
- `defining-a-kind` — `[P2]` Hookspec YAML + emit types.
- `publishing` — `[P2]` Как распространить свой kind.
- `testing-a-kind` — `[P2]` Contract-suite для авторов kind'ов.

### 9. Туториалы — `docs/tutorials/`

- `echo-plugin` — `[P2]` End-to-end walkthrough.
- `custom-chunker` — `[P2]` 30-минутный туториал.
- `openai-llm` — `[P2]` LLM-плагин.
- `qdrant-vector-store` — `[P2]` VectorStore-плагин.
- `custom-kind` — `[P2]` Свой hookspec с нуля.

### 10. Горизонтальные расширения — `docs/horizontal/`

*ADR-0005, продвинутое.*

- `overview` — `[P3]`
- `governance` — `[P3]`
- `observability` — `[P3]`
- `audit` — `[P3]`

### 11. Справка — `docs/meta/`

- `glossary` — `[P1]` Мульти-язычный глоссарий терминов (готовит к i18n).
- `faq` — `[P2]` Частые вопросы.
- `changelog` — `[P2]` Ссылки на release notes binding'ов.
- `migrations` — `[P2]` `0.x → 1.0`, когда случится.

## Счёт страниц

| Приоритет | Страниц | Цель |
|---|---|---|
| P1 (уже есть в PR #1) | 8 | Baseline |
| P1 expansion | ~24 | К context7 submission |
| **P1 итого** | **~32** | **Quality-bar для submission** |
| P2 | ~25 | После submission, итеративно |
| P3 | ~5 | По мере содержания |
| ИТОГО | ≈62 | Полная карта |

## Roadmap PR

- **PR #1** — Bootstrap (есть): intro + concepts/3 + guides/3 + api-placeholders.
- **PR #2** — CI + pre-commit hook (build gate, JSON validate, scrub-check).
- **PR #3** — Spec-раздел (овerview + 6 ADR-резюме). **Следующий** после merge #1.
- **PR #4** — Расширение concepts (kinds, runtimes, dispatch, resources, invariants).
- **PR #5** — Расширение guides (testing, dependencies, dispatchers/×5).
- **PR #6** — Reference (manifest-schema, kinds-list, runtimes-list, errors).
- **PR #7** — Auto-gen Python API reference (требует чистки docstring'ов в plugin-system-python).
- **PR #8** — Getting-started расширение (what-is-a-plugin, installation, first-plugin).
- **PR #9** — Glossary (подготовка к i18n).
- **После P1 submission в context7** — итеративно P2 разделы.
