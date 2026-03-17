import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class QuotingDeskRoute extends Route {
  @service auth;
  @service router;

  beforeModel() {
    if (!this.auth.isAuthenticated) {
      this.router.replaceWith('login');
      return;
    }
    if (!this.auth.isAdmin && !this.auth.isEstimator) {
      this.router.replaceWith('app.dashboard');
    }
  }
}
