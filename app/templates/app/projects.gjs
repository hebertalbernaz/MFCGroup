import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { STATUSES } from '../../services/projects';
import KanbanCard from '../../components/kanban-card';
import ProjectDetailPanel from '../../components/project-detail-panel';

class KanbanColumn extends Component {
  get cards() {
    const all = this.args.projects ?? [];
    return all.filter((p) => p.status === this.args.statusKey);
  }

  <template>
    <div class="kanban-column">
      <div class="kanban-column-header">
        <span class="kanban-column-title">{{@label}}</span>
        <span class="kanban-count">{{this.cards.length}}</span>
      </div>
      <div class="kanban-cards">
        {{#if this.cards.length}}
          {{#each this.cards as |project|}}
            <KanbanCard @project={{project}} @onOpen={{@onOpen}} />
          {{/each}}
        {{else}}
          <div class="kanban-empty">No items</div>
        {{/if}}
      </div>
    </div>
  </template>
}

class ProjectsPage extends Component {
  @service projects;

  @tracked selectedProject = null;
  @tracked searchQuery = '';

  get columns() {
    return STATUSES;
  }

  get visibleProjects() {
    const q = this.searchQuery.trim().toLowerCase();
    const all = this.projects.projects.filter((p) => p.status !== 'archived');
    if (!q) return all;
    return all.filter(
      (p) =>
        p.client_name?.toLowerCase().includes(q) ||
        p.project_id?.toLowerCase().includes(q) ||
        p.eircode?.toLowerCase().includes(q)
    );
  }

  get isFiltered() {
    return this.searchQuery.trim().length > 0;
  }

  handleSearch = (e) => {
    this.searchQuery = e.target.value;
  };

  openDetail = (project) => {
    this.selectedProject = project;
  };

  closeDetail = () => {
    this.selectedProject = null;
  };

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Projects</h1>
        <p class="page-subtitle">Kanban board — manage projects across stages</p>
      </div>
      <div style="position: relative; min-width: 280px;">
        <svg style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: var(--text-tertiary); pointer-events: none;"
          width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input
          type="text"
          class="form-input"
          style="padding-left: 32px; font-size: var(--text-sm);"
          placeholder="Search by client name or ID..."
          value={{this.searchQuery}}
          {{on "input" this.handleSearch}}
        />
      </div>
    </div>

    {{#if this.isFiltered}}
      <div style="
        margin-bottom: var(--space-3);
        font-size: var(--text-sm);
        color: var(--text-secondary);
        padding: var(--space-2) var(--space-3);
        background: var(--bg-surface-raised);
        border-radius: var(--radius-md);
        border: 1px solid var(--border-default);
        display: inline-block;
      ">
        Showing {{this.visibleProjects.length}} result(s) for "{{this.searchQuery}}"
      </div>
    {{/if}}

    {{#if this.projects.isLoading}}
      <div class="empty-state">
        <div class="loading-spinner" style="width:32px;height:32px;"></div>
      </div>
    {{else}}
      <div class="kanban-board">
        {{#each this.columns as |column|}}
          <KanbanColumn
            @statusKey={{column.key}}
            @label={{column.label}}
            @projects={{this.visibleProjects}}
            @onOpen={{this.openDetail}}
          />
        {{/each}}
      </div>
    {{/if}}

    <ProjectDetailPanel @project={{this.selectedProject}} @onClose={{this.closeDetail}} />
  </template>
}

export default <template><ProjectsPage /></template>
