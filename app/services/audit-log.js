import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class AuditLogService extends Service {
  @tracked logs = [];

  logAction(user, action, details = '') {
    const entry = {
      id: crypto.randomUUID(),
      timestamp: new Date().toISOString(),
      user: user?.displayName ?? user?.username ?? 'System',
      action,
      details,
    };
    this.logs = [entry, ...this.logs];
  }

  get recentLogs() {
    return this.logs.slice(0, 200);
  }

  filterLogs(query) {
    if (!query?.trim()) return this.recentLogs;
    const q = query.trim().toLowerCase();
    return this.recentLogs.filter(
      (l) =>
        l.user.toLowerCase().includes(q) ||
        l.action.toLowerCase().includes(q) ||
        l.details.toLowerCase().includes(q)
    );
  }
}
