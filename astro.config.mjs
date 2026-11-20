// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

const repo = 'https://github.com/bartrumb/edgefetch';

// https://astro.build/config
export default defineConfig({
  site: 'https://edgefetch.dev',

  integrations: [
      starlight({
          title: 'EdgeFetch',
          description:
              'Self-hosted, MIT-licensed web scraping and search MCP server for AI agents. One Go binary, zero open ports.',
          social: [{ icon: 'github', label: 'GitHub', href: repo }],
          logo: { src: './src/assets/edgefetch-raven-mark.png', alt: 'EdgeFetch' },
          favicon: '/favicon.png',
          customCss: ['./src/styles/theme.css'],
          components: { Hero: './src/components/Hero.astro' },
          head: [
              { tag: 'link', attrs: { rel: 'preconnect', href: 'https://fonts.googleapis.com' } },
              { tag: 'link', attrs: { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' } },
              {
                  tag: 'link',
                  attrs: {
                      rel: 'stylesheet',
                      href: 'https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=Schibsted+Grotesk:wght@400;500;600;700;800&display=swap',
                  },
              },
              { tag: 'meta', attrs: { property: 'og:image', content: 'https://edgefetch.dev/og.png' } },
              { tag: 'meta', attrs: { name: 'twitter:card', content: 'summary_large_image' } },
              { tag: 'meta', attrs: { name: 'theme-color', content: '#101c2c' } },
          ],
          sidebar: [
              {
                  label: 'Start here',
                  items: [
                      { label: 'Quick start', slug: 'start/quick-start' },
                      { label: 'Install', slug: 'start/install' },
                      { label: 'Connect an MCP client', slug: 'start/mcp-clients' },
                  ],
              },
              {
                  label: 'Deploy',
                  items: [
                      { label: 'One-click deploys', slug: 'deploy/one-click' },
                      { label: 'Deploy a hub', slug: 'guides/deploy-hub' },
                      { label: 'Add worker nodes', slug: 'guides/workers' },
                      { label: 'Roll your own', slug: 'deploy/roll-your-own' },
                  ],
              },
              {
                  label: 'Guides',
                  items: [
                      { label: 'Verify a release', slug: 'guides/verify-release' },
                      { label: 'Troubleshooting & OTel traces', slug: 'guides/troubleshooting' },
                  ],
              },
              {
                  label: 'Adapters',
                  items: [
                      { label: 'Site adapters', slug: 'adapters' },
                      { label: 'Write an adapter', slug: 'adapters/write' },
                  ],
              },
              {
                  label: 'How it works',
                  items: [
                      { label: 'Architecture', slug: 'concepts/architecture' },
                      { label: 'Politeness rules', slug: 'concepts/politeness' },
                      { label: 'Security model', slug: 'concepts/security' },
                  ],
              },
              {
                  label: 'Reference',
                  items: [
                      { label: 'MCP tools', slug: 'reference/tools' },
                      { label: 'Docs on GitHub', slug: 'reference/github-docs' },
                  ],
              },
              {
                  label: 'Project',
                  items: [
                      { label: 'Contributing', slug: 'contributing' },
                      { label: 'Registries and bot lists', slug: 'registries' },
                      { label: 'For website owners', slug: 'site-owners' },
                      { label: 'Status and contact', slug: 'project' },
                      { label: 'Sponsor on GitHub', link: 'https://github.com/sponsors/bartrumb', attrs: { target: '_blank', rel: 'noopener' } },
                      { label: 'Raven merch shop', link: 'https://edgefetch-shop.fourthwall.com', attrs: { target: '_blank', rel: 'noopener' } },
                  ],
              },
          ],
      }),
	],
});