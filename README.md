# pastiera monorepo

Project source lives in this monorepo. Documentation and project overview are hosted via GitHub Pages at `https://pastiera.eu`.

## Structure

- `apps/docs` - Astro Starlight docs site (landing page, FAQ, guides, project overview)
- `apps/*` - app projects
- `packages/*` - shared libraries

## Docs development

```bash
npm install
npm run docs:dev
```

## Build docs

```bash
npm run docs:build
```

## Generate showcase images

1. Add raw screenshots as PNG files to `apps/docs/assets/showcase/raw/`
2. Run:

```bash
npm run docs:images
```

Generated images are written to `apps/docs/public/showcase/generated/`.
