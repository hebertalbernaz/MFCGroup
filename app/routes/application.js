import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service auth;
  @service router;

  async beforeModel(transition) {
    const publicRoutes = new Set(['login']);
    const targetRoute = transition.to?.name;

    try {
      let attempts = 0;
      const maxAttempts = 40;

      while (this.auth.isLoading && attempts < maxAttempts) {
        await new Promise(resolve => setTimeout(resolve, 50));
        attempts++;
      }

      if (attempts >= maxAttempts) {
        console.warn('Auth loading timed out after 2 seconds');
        this.auth.isLoading = false;
      }

      if (!this.auth.isAuthenticated && !publicRoutes.has(targetRoute)) {
        this.router.replaceWith('login');
      }
    } catch (error) {
      console.error('Application route error:', error);
      this.router.replaceWith('login');
    }
  }
}
