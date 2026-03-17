import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class SettingsRoute extends Route {
  @service catalog;

  async model() {
    if (!this.catalog.items.length && !this.catalog.isLoading) {
      await this.catalog.load();
    }
  }
}
