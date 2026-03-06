import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://pastiera.eu',
  integrations: [
    starlight({
      title: 'Pastiera',
      description: 'Project overview, FAQ, and implementation guides.',
      social: {
        github: 'https://github.com/palsoftware'
      }
    }),
    sitemap()
  ]
});
