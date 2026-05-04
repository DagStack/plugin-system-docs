# Как участвовать

Краткие соглашения для авторов страниц и ревьюеров.

## Язык

- Текст страниц (prose) пишется **на русском**.
- Имена идентификаторов, ключи конфигов, значения-константы, содержимое fenced-блоков — на **английском**.
- Избегать англицизмов в русском тексте там, где русский эквивалент не ломает смысл:
  «регистрация» вместо «register», «подписка» вместо «subscribe», «устаревший» вместо «deprecated», «полезная нагрузка» вместо «payload», «резервный вариант» вместо «fallback», «привязка» / «реализация» вместо «binding», «формат передачи» вместо «wire-format», «снимок» вместо «snapshot».
- `rules` в `context7.json` — **на английском** (LLM-first).

## Табы с примерами кода

Единственный разрешённый паттерн — `<Tabs>` + `<TabItem>` с обычным fenced-кодом внутри:

```mdx
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs groupId="lang" queryString="lang">
  <TabItem value="python" label="Python">
    ```python
    # ...
    ```
  </TabItem>
  <TabItem value="typescript" label="TypeScript">
    ```ts
    // ...
    ```
  </TabItem>
  <TabItem value="go" label="Go">
    ```go
    // ...
    ```
  </TabItem>
</Tabs>
```

Обязательные правила:

- `groupId="lang"` во всех блоках — выбор языка синхронизируется по всему сайту.
- `queryString="lang"` — выбор попадает в URL (`?lang=go`).
- Порядок табов: **Python → TypeScript → Go**.
- `value=` строго `python`, `typescript`, `go` (lowercase, без сокращений).
- Каждый fenced-блок — с явным языком (`python`, `ts`, `go`, `bash`, `yaml`, `json`, `toml`).

**Запрещено**:

- Кастомные JSX-обёртки над кодом (`<CodeExample>`, `<MultiCode>`). Парсер context7 их не понимает — сниппеты теряют язык.
- `<Tabs>` внутри `<details>` или admonition (`:::note`, `:::tip`). Парсер пропускает вложенные структуры.
- Fenced-блок без языка или с `text`.
- `groupId="lang"` на табах, которые переключают **не между языками** (например, между runtime-адаптерами). Для таких сценариев используйте отдельный `groupId` (`"runtime-spec"`, `"os"`, …) или табы без `groupId`.

## Именование классов диспетчеризации и runtime'ов

Канон в prose (текст страниц) — через дефис:

- «singleton», «broadcast-collect», «broadcast-notify», «chain», «capability» (классы диспетчеризации).
- «in_process», «mcp_stdio», «mcp_http» (runtime'ы — snake_case, совпадает с TOML-значением).

В `toml`/`json`/`yaml`/`code` — snake_case для всех (`broadcast_collect`, `broadcast_notify`), потому что так пишется в манифесте и коде.

## Scoping концептов и руководств

- **`docs/concepts/`** — «что это и когда применять». Обзоры, таблицы, flowchart'ы выбора.
- **`docs/guides/`** — «как сделать и запустить». Пошаговые walkthrough'и, CI-интеграция, debug.
- **`docs/spec/adr/`** — «почему так решено». Нормативные synopsis'ы с cross-language примерами + ссылка на полный ADR.
- **`docs/reference/`** — «где посмотреть точную спецификацию». Таблицы всех полей, enum-значений, error-классов.

Пересечения естественны, но каждая страница доминирует в своей категории: concept не должен быть tutorial'ом, guide не должен заменять нормативный spec.

## Заголовки и slug-ы

Русские H2/H3 порождают URL с кириллицей, что некрасиво и плохо для SEO. Всегда указывайте явные slug-ы:

```mdx
---
sidebar_position: 1
title: Регистрация плагина
description: <1-2 предложения — context7 использует как сниппет>
slug: /concepts/registration
---

# Регистрация плагина

## Обзор {#overview}

Содержимое...

## Ошибки {#errors}
```

У каждого H2/H3 — явный `{#id}` на английском.

## Структура страницы

- Frontmatter с `title`, `description`, `slug`, опционально `sidebar_position`.
- Один H1 (генерируется из `title`).
- H2 — одна операция / концепт на заголовок.
- **Prose → `<Tabs>`**, не `<Tabs>` → prose. Описание API → блок с кодом.
- Сниппеты self-contained (каждый исполняется независимо от соседних).
- Реалистичные имена (`acme-corp`, не `foo`).

## Privacy: что НЕ попадает в публичный репозиторий

Имена внутренних систем и интеграций, которые не должны попадать в публичную документацию, зафиксированы в **локальном** файле `.scrub-patterns` (в `.gitignore`, поддерживается core-контрибьюторами). Перед каждым push прогоняйте:

```bash
make scrub-check
```

Команда читает паттерны из `.scrub-patterns` и сообщает о найденных совпадениях в изменённых файлах. Если файл `.scrub-patterns` отсутствует (например, вы внешний контрибьютор), проверка пропускается без ошибки — но будет прогнана внутренним ревьюером перед merge.

Общее правило — **использовать generic-домены в примерах** (SaaS, e-commerce, dev-tool, coding-assistant). Избегайте упоминаний конкретных продуктов, заказчиков и внутренних сервисов. Если пример вдохновлён реальным pilot-кейсом — перепишите на generic.

## Локальная проверка перед PR

```bash
make build        # собрать сайт, убедиться что нет ошибок
make validate     # проверить context7.json + scrub-check
```

## Pre-commit hook (рекомендуется)

После клонирования репозитория один раз выполните:

```bash
make hooks
```

Это настроит `core.hooksPath` на папку `.githooks/`. Перед каждым коммитом автоматически запускается `.githooks/pre-commit`, который проверяет:

- Если в staged есть `context7.json` — что это валидный JSON.
- Если `.scrub-patterns` существует локально — что изменённые файлы не содержат имён из scrub-list.

Пропустить проверку можно через `git commit --no-verify`, но это не рекомендуется — CI всё равно не пропустит невалидные артефакты.

## CI (build gate)

Каждый PR и push в `main` триггерит workflow `.gitea/workflows/docs.yml`:

1. Валидация `context7.json`.
2. `npm ci` + `npm run build` в подпапке `site/` — полная сборка сайта, ломается на broken-links и MDX-ошибках.
3. Проверка наличия `site/build/index.html` и `site/build/plugin-system/docs` — защита от «успешно собрали, но пусто».

Workflow выполняется на тэге `dagstack-runner`.

## Commit-сообщения

- Conventional Commits: `feat(docs): ...`, `fix(docs): ...`, `chore(docs): ...`.
- Первая строка — английский imperative. Подробности в теле — русский ОК.
- Без Co-Authored-By Claude, без «🤖 Generated with ...», без «AI-assisted».

## Identity

```bash
git config user.name "Evgenii Demchenko"
git config user.email "demchenkoev@gmail.com"
```

Для `dagstack/*` репозиториев email — gmail (публичная identity).
