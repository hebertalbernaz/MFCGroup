'use strict';

const { existsSync, mkdirSync, writeFileSync } = require('fs');
const { join } = require('path');

const projectRoot = join(__dirname, '..');
const embroiderDir = join(projectRoot, 'node_modules', '.embroider');
const contentForPath = join(embroiderDir, 'content-for.json');

if (existsSync(contentForPath)) {
  process.exit(0);
}

const getEnvConfig = require(join(projectRoot, 'config', 'environment.js'));
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
console.log('Generated .embroider/content-for.json');
