import Component from '@glimmer/component';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { STATUSES } from '../services/projects';

class StatusOption extends Component {
  get isSelected() {
    return this.args.value === this.args.current;
  }

  <template>
    <option value={{@value}} selected={{this.isSelected}}>{{@label}}</option>
  </template>
}

export default class KanbanCard extends Component {
  @service projects;

  get slaStatus() {
    return this.projects.getSlaStatus(this.args.project);
  }

  get slaLabel() {
    const map = { green: 'On Track', yellow: 'Due Soon', red: 'Overdue' };
    return map[this.slaStatus];
  }

  get slaBadgeClass() {
    return `sla-badge sla-badge-${this.slaStatus}`;
  }

  get slaDotClass() {
    return `sla-dot sla-dot-${this.slaStatus}`;
  }

  get badgeClass() {
    return this.args.project.product_type === 'MFC' ? 'badge badge-mfc' : 'badge badge-pod';
  }

  get formattedDate() {
    const d = this.args.project.created_at;
    if (!d) return '';
    return new Date(d).toLocaleDateString('en-IE', { day: '2-digit', month: 'short', year: 'numeric' });
  }

  get statuses() {
    return STATUSES;
  }

  handleCardClick = (e) => {
    if (e.target.closest('select')) return;
    this.args.onOpen?.(this.args.project);
  };

  handleStatusChange = async (e) => {
    e.stopPropagation();
    await this.projects.updateProjectStatus(this.args.project.id, e.target.value);
  };

  <template>
    <div class="kanban-card" role="button" tabindex="0" {{on "click" this.handleCardClick}}>
      <div class="kanban-card-header">
        <span class="kanban-card-id">{{@project.project_id}}</span>
        <span class={{this.badgeClass}}>
          {{@project.product_type}}
        </span>
      </div>
      <div class="kanban-card-name">{{@project.client_name}}</div>
      <div style="font-size: var(--text-xs); color: var(--text-tertiary);">{{@project.eircode}}</div>
      <div class="kanban-card-footer">
        <div class={{this.slaBadgeClass}}>
          <div class={{this.slaDotClass}}></div>
          {{this.slaLabel}}
        </div>
        <span class="kanban-card-date">{{this.formattedDate}}</span>
      </div>
      <div style="margin-top: var(--space-3);">
        <select class="status-select w-full" {{on "change" this.handleStatusChange}}>
          {{#each this.statuses as |status|}}
            <StatusOption @value={{status.key}} @label={{status.label}} @current={{@project.status}} />
          {{/each}}
        </select>
      </div>
    </div>
  </template>
}
