import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'dagstack plugin-system',
  tagline: 'Orchestration-neutral plugin framework — one contract for Python, TypeScript, and Go.',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  // Public URL — GitHub Pages on a custom subdomain.
  // baseUrl='/' because the subdomain already isolates the site; the
  // umbrella landing lives separately on the apex dagstack.dev.
  url: 'https://plugin-system.dagstack.dev',
  baseUrl: '/',

  organizationName: 'dagstack',
  projectName: 'plugin-system-docs',

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'ru'],
    localeConfigs: {
      en: { label: 'English', direction: 'ltr', htmlLang: 'en-US' },
      ru: { label: 'Русский', direction: 'ltr', htmlLang: 'ru-RU', path: 'ru', translate: true },
    },
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl:
            'https://github.com/dagstack/plugin-system-docs/_edit/main/site/',
          showLastUpdateTime: true,
          showLastUpdateAuthor: false,
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themes: [
    '@docusaurus/theme-mermaid',
    [
      require.resolve('@easyops-cn/docusaurus-search-local'),
      {
        hashed: true,
        language: ['en', 'ru'],
        indexDocs: true,
        indexBlog: false,
        indexPages: false,
        docsRouteBasePath: '/docs',
        highlightSearchTermsOnTargetPage: true,
        explicitSearchResultPath: true,
      },
    ],
  ],

  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  themeConfig: {
    // OpenGraph social card — to be added later (1200×630, with the logo).
    // For now Docusaurus uses the default without an explicit image.

    navbar: {
      title: 'plugin-system',
      logo: {
        alt: 'dagstack',
        src: 'img/logo-mark.svg',
        srcDark: 'img/logo-mark-dark.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'mainSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          href: 'https://github.com/dagstack/plugin-system-spec',
          label: 'Specification',
          position: 'right',
        },
        {
          type: 'localeDropdown',
          position: 'right',
        },
      ],
    },

    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            { label: 'Quick start', to: '/docs/intro' },
            { label: 'Concepts', to: '/docs/concepts/registry' },
            { label: 'Guides', to: '/docs/guides/writing-a-plugin' },
            { label: 'API reference', to: '/docs/api/python' },
          ],
        },
        {
          title: 'plugin-system',
          items: [
            { label: 'Specification (ADR overview)', to: '/docs/spec/overview' },
            { label: 'Full spec repository', href: 'https://github.com/dagstack/plugin-system-spec' },
            { label: 'Python binding', href: 'https://github.com/dagstack/plugin-system-python' },
            { label: 'TypeScript binding (roadmap)', href: 'https://github.com/dagstack/plugin-system-typescript' },
          ],
        },
        {
          title: 'dagstack ecosystem',
          items: [
            { label: 'config — hierarchical configuration', href: 'https://github.com/dagstack/config-spec' },
            { label: 'logger — OTel-compatible logging', href: 'https://github.com/dagstack/logger-spec' },
            { label: 'tenancy — multi-tenancy model', href: 'https://github.com/dagstack/tenancy-spec' },
            { label: 'tenant-registry — SQL tenant registries', href: 'https://github.com/dagstack/tenant-registry-spec' },
            { label: 'postgres — shared database patterns', href: 'https://github.com/dagstack/postgres-spec' },
            { label: 'All repositories', href: 'https://github.com/dagstack' },
          ],
        },
      ],
      copyright: `© ${new Date().getFullYear()} dagstack. Licensed under Apache-2.0.`,
    },

    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['python', 'go', 'bash', 'toml'],
    },

    colorMode: {
      defaultMode: 'light',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
