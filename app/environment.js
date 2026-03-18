const prefix = 'my-app';
const defaultConfig = {
  modulePrefix: 'my-app',
  podModulePrefix: 'my-app/pods',
  environment: 'development',
  rootURL: '/',
  locationType: 'history',
  EmberENV: { EXTEND_PROTOTYPES: false, FEATURES: {} },
  APP: {},
};

let config;
try {
  const metaName = prefix + '/config/environment';
  const metaEl = document.querySelector('meta[name="' + metaName + '"]');
  if (metaEl) {
    config = JSON.parse(decodeURIComponent(metaEl.getAttribute('content')));
  } else {
    config = defaultConfig;
  }
} catch (err) {
  config = defaultConfig;
}
export default config;
