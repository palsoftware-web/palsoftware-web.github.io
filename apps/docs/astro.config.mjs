import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://pastiera.eu',
  integrations: [
    starlight({
      title: 'Pastiera',
      description: 'User-focused documentation for the Pastiera physical-keyboard Android app.',
      locales: {
        root: { label: 'English', lang: 'en' },
        de: { label: 'Deutsch', lang: 'de' },
        it: { label: 'Italiano', lang: 'it' }
      },
      defaultLocale: 'root',
      sidebar: [
        {
          label: 'Get Started',
          items: [
            { slug: 'guides/getting-started' },
            { slug: 'guides/feature-overview' },
            { slug: 'guides/practical-setup-recipes' }
          ]
        },
        {
          label: 'Features',
          items: [
            { slug: 'guides/typing-and-navigation' },
            { slug: 'guides/languages-and-layouts' },
            { slug: 'guides/sym-and-variations' },
            { slug: 'guides/suggestions-and-dictionaries' },
            { slug: 'guides/device-profiles' },
            { slug: 'guides/backup-and-updates' }
          ]
        },
        {
          label: 'FAQ',
          items: [{ slug: 'faq' }]
        },
        {
          label: 'Developer',
          items: [
            { slug: 'developer/overview' },
            { slug: 'developer/release-channels' }
          ]
        }
      ],
      social: {
        github: 'https://github.com/palsoftware'
      }
    }),
    sitemap()
  ]
});
