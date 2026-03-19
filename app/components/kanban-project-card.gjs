import Component from '@glimmer/component';
import { service } from '@ember/service';
import { on } from '@ember/modifier';

export default class KanbanProjectCard extends Component {
  @service supabase;

  get slaStatus() {
    const { project, slaTargets } = this.args;
    if (!project.status_updated_at || !slaTargets) return 'neutral';

    const statusKey = this.getStatusKey(project.status);
    const targetDays = slaTargets[statusKey];

    if (!targetDays) return 'neutral';

    const daysSinceUpdate = this.calculateDaysSince(project.status_updated_at);

    if (daysSinceUpdate > targetDays) {
      return 'overdue';
    }
    return 'on-time';
  }

  get slaBadgeClass() {
    const status = this.slaStatus;
    if (status === 'overdue') return 'sla-badge sla-badge-overdue';
    if (status === 'on-time') return 'sla-badge sla-badge-on-time';
    return 'sla-badge sla-badge-neutral';
  }

  get slaBadgeText() {
    const { project, slaTargets } = this.args;
    if (!project.status_updated_at) return 'New';

    const daysSinceUpdate = this.calculateDaysSince(project.status_updated_at);
    const statusKey = this.getStatusKey(project.status);
    const targetDays = slaTargets?.[statusKey] || 0;

    return `${daysSinceUpdate}/${targetDays}d`;
  }

  get podModelClass() {
    const model = this.args.project.pod_model || '';
    if (model.includes('17')) return 'pod-model-tag pod-model-17';
    if (model.toLowerCase().includes('custom')) return 'pod-model-tag pod-model-custom';
    return 'pod-model-tag pod-model-default';
  }

  calculateDaysSince(dateString) {
    const now = new Date();
    const then = new Date(dateString);
    const diffTime = Math.abs(now - then);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  }

  getStatusKey(status) {
    const map = {
      'New Enquiry': 'sla_new_enquiry',
      'In Design': 'sla_in_design',
      'Awaiting Quote': 'sla_awaiting_quote',
      'Revisions': 'sla_revisions',
    };
    return map[status] || null;
  }

  handleClick = (e) => {
    e.preventDefault();
    if (this.args.onClick) {
      this.args.onClick(this.args.project);
    }
  };

  <template>
    <div class="kanban-card" {{on "click" this.handleClick}}>
      <div class="kanban-card-header">
        <span class="kanban-card-id">{{@project.tpf_id}}</span>
        <span class={{this.slaBadgeClass}}>{{this.slaBadgeText}}</span>
      </div>

      <div class="kanban-card-client">{{@project.client_name}}</div>

      <div class="kanban-card-footer">
        {{#if @project.eircode}}
          <span class="kanban-card-eircode">{{@project.eircode}}</span>
        {{/if}}
        {{#if @project.pod_model}}
          <span class={{this.podModelClass}}>{{@project.pod_model}}</span>
        {{/if}}
      </div>
    </div>
  </template>
}
