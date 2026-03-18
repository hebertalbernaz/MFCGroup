import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class ToastService extends Service {
  @tracked toasts = [];

  _add(type, message, options = {}) {
    const id = crypto.randomUUID();
    const duration = options.duration ?? 4000;
    const toast = { id, type, message, detail: options.detail ?? null };
    this.toasts = [...this.toasts, toast];

    if (duration > 0) {
      setTimeout(() => this.dismiss(id), duration);
    }

    return id;
  }

  success(message, options) {
    return this._add('success', message, options);
  }

  error(message, options) {
    return this._add('error', message, options);
  }

  info(message, options) {
    return this._add('info', message, options);
  }

  dismiss(id) {
    this.toasts = this.toasts.filter((t) => t.id !== id);
  }
}
