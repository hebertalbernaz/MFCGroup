import { service } from '@ember/service';
import Component from '@glimmer/component';
import { STATUSES } from 'my-app/services/projects';

class DashboardPage extends Component {
  @service projects;

  get totalProjects() {
    return this.projects.projects.length;
  }

  get openProjects() {
    return this.projects.projects.filter((p) => p.status !== 'closed').length;
  }

  get mfcCount() {
    return this.projects.projects.filter((p) => p.product_type === 'MFC').length;
  }

  get podCount() {
    return this.projects.projects.filter((p) => p.product_type === 'POD').length;
  }

  get redSlaCount() {
    return this.projects.projects.filter((p) => this.projects.getSlaStatus(p) === 'red').length;
  }

  get pipelineRows() {
    return STATUSES.map((s) => ({
      label: s.label,
      count: this.projects.projects.filter((p) => p.status === s.key).length,
    }));
  }

  get recentProjects() {
    return this.projects.recentProjects;
  }

  formatDate(dateStr) {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleDateString('en-IE', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    });
  }

  slaLabel(project) {
    const s = this.projects.getSlaStatus(project);
    return s === 'green' ? 'On Track' : s === 'yellow' ? 'Due Soon' : 'Overdue';
  }

  slaClass(project) {
    return `sla-badge sla-badge-${this.projects.getSlaStatus(project)}`;
  }

  slaDotClass(project) {
    return `sla-dot sla-dot-${this.projects.getSlaStatus(project)}`;
  }

  badgeClass(project) {
    return project.product_type === 'MFC' ? 'badge badge-mfc' : 'badge badge-pod';
  }

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Dashboard</h1>
        <p class="page-subtitle">Overview of all MFC Group projects and enquiries</p>
      </div>
    </div>

    {{#if this.projects.isLoading}}
      <div class="empty-state">
        <div class="loading-spinner" style="width:32px;height:32px;"></div>
      </div>
    {{else}}
      <div class="dashboard-grid">
        <div class="stat-card stat-card-accent">
          <div class="stat-card-label">Total Projects</div>
          <div class="stat-card-value">{{this.totalProjects}}</div>
          <div class="stat-card-sub">All time</div>
        </div>
        <div class="stat-card">
          <div class="stat-card-label">Open</div>
          <div class="stat-card-value">{{this.openProjects}}</div>
          <div class="stat-card-sub">Active projects</div>
        </div>
        <div class="stat-card">
          <div class="stat-card-label">MFC Projects</div>
          <div class="stat-card-value">{{this.mfcCount}}</div>
          <div class="stat-card-sub">Modular Frame</div>
        </div>
        <div class="stat-card">
          <div class="stat-card-label">POD Projects</div>
          <div class="stat-card-value">{{this.podCount}}</div>
          <div class="stat-card-sub">Pre-built Off-site</div>
        </div>
        <div class="stat-card" style="border-left: 3px solid var(--color-error-500);">
          <div class="stat-card-label">SLA Overdue</div>
          <div class="stat-card-value" style="color: var(--color-error-500);">{{this.redSlaCount}}</div>
          <div class="stat-card-sub">Needs attention</div>
        </div>
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-4);">
        <div class="card">
          <div class="card-header">
            <span class="card-title">Pipeline Status</span>
          </div>
          <div class="card-body" style="padding: var(--space-4) var(--space-6);">
            {{#each this.pipelineRows as |row|}}
              <div style="display: flex; align-items: center; justify-content: space-between; padding: var(--space-2) 0; border-bottom: 1px solid var(--border-default);">
                <span style="font-size: var(--text-sm); color: var(--text-secondary);">{{row.label}}</span>
                <span style="font-size: var(--text-sm); font-weight: 600; color: var(--text-primary);">{{row.count}}</span>
              </div>
            {{/each}}
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <span class="card-title">Recent Enquiries</span>
          </div>
          {{#if this.recentProjects.length}}
            <div class="card-body" style="padding: 0;">
              {{#each this.recentProjects as |project|}}
                <div style="display: flex; align-items: center; justify-content: space-between; padding: var(--space-3) var(--space-6); border-bottom: 1px solid var(--border-default);">
                  <div>
                    <div style="display: flex; align-items: center; gap: var(--space-2);">
                      <span style="font-family: var(--font-mono); font-size: var(--text-xs); font-weight: 700; color: var(--text-secondary);">{{project.project_id}}</span>
                      <span class={{this.badgeClass project}}>{{project.product_type}}</span>
                    </div>
                    <div style="font-size: var(--text-sm); font-weight: 500; color: var(--text-primary); margin-top: 2px;">{{project.client_name}}</div>
                  </div>
                  <div style="text-align: right;">
                    <div class={{this.slaClass project}}>
                      <div class={{this.slaDotClass project}}></div>
                      {{this.slaLabel project}}
                    </div>
                    <div style="font-size: var(--text-xs); color: var(--text-tertiary); margin-top: 2px;">{{this.formatDate project.created_at}}</div>
                  </div>
                </div>
              {{/each}}
            </div>
          {{else}}
            <div class="empty-state" style="padding: var(--space-8);">
              <p class="empty-state-desc">No enquiries yet. Create one using the "New Enquiry" button.</p>
            </div>
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}

export default <template><DashboardPage /></template>
