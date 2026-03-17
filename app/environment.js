const prefix = 'my-app';
let config;
try {
  const metaName = prefix + '/config/environment';
  const rawConfig = document
    .querySelector('meta[name="' + metaName + '"]')
    .getAttribute('content');
  config = JSON.parse(decodeURIComponent(rawConfig));
} catch (err) {
  throw new Error(
    'Could not read config from meta tag with name "' + prefix + '/config/environment".'
  );
}
export default config;
