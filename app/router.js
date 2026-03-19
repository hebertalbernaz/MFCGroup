import EmberRouter from '@embroider/router';
import config from './environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('login');
  this.route('app', { path: '/' }, function () {
    this.route('dashboard', { path: '/' });
    this.route('projects');
    this.route('design-desk');
    this.route('calendar');
    this.route('settings');
    this.route('tpf-settings');
    this.route('quoting-desk');
    this.route('reports');
  });
});
