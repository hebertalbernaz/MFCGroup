import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service auth;
  @service router;

  async beforeModel(transition) {
    const publicRoutes = new Set(['login']);
    const targetRoute = transition.to?.name;

    while (this.auth.isLoading) {
      await new Promise(resolve => setTimeout(resolve, 50));
    }

    if (!this.auth.isAuthenticated && !publicRoutes.has(targetRoute)) {
      this.router.replaceWith('login');
    }
  }
}
