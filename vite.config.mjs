import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import { fileURLToPath } from 'node:url';
import { resolve, dirname, join } from 'node:path';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';

const __dirname = dirname(fileURLToPath(import.meta.url));
const _require = createRequire(import.meta.url);

function ensureEmbroiderCache() {
  return {
    name: 'ensure-embroider-cache',
    enforce: 'pre',
    configResolved() {
      const embroiderDir = join(__dirname, 'node_modules', '.embroider');
      const contentForPath = join(embroiderDir, 'content-for.json');

      if (existsSync(contentForPath)) return;

      const getEnvConfig = _require(join(__dirname, 'config', 'environment.js'));
      const envConfig = getEnvConfig('development');
      const encoded = encodeURIComponent(JSON.stringify(envConfig));
      const metaTag = `<meta name="my-app/config/environment" content="${encoded}" />`;

      const empty = '';
      const contentFor = {
        '/index.html': {
          head: metaTag,
          'test-head': empty,
          'head-footer': empty,
          'test-head-footer': empty,
          body: empty,
          'test-body': empty,
          'body-footer': empty,
          'test-body-footer': empty,
          'config-module': empty,
          'app-boot': empty,
        },
        '/tests/index.html': {
          head: empty,
          'test-head': empty,
          'head-footer': empty,
          'test-head-footer': empty,
          body: empty,
          'test-body': empty,
          'body-footer': empty,
          'test-body-footer': empty,
          'config-module': empty,
          'app-boot': empty,
        },
      };

      mkdirSync(embroiderDir, { recursive: true });
      writeFileSync(contentForPath, JSON.stringify(contentFor, null, 2));
    },
  };
}

export default defineConfig({
  server: {
    port: 5173,
    strictPort: true,
    hmr: {
      clientPort: 5173,
    },
  },
  resolve: {
    alias: {
      'my-app/config/environment': resolve(__dirname, 'app/environment.js'),
      'my-app/': resolve(__dirname, 'app') + '/',
    },
  },
  plugins: [
    ensureEmbroiderCache(),
    classicEmberSupport(),
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
});
