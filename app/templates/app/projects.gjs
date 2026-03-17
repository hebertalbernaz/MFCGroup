import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { STATUSES } from 'my-app/services/projects';
import KanbanCard from 'my-app/components/kanban-card';
import ProjectDetailPanel from 'my-app/components/project-detail-panel';

class KanbanColumn extends Component {
  @service projects;

  get cards() {
    return this.projects.projects.filter((p) => p.status === this.args.statusKey);
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

  get columns() {
    return STATUSES;
  }

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
    </div>

    {{#if this.projects.isLoading}}
      <div class="empty-state">
        <div class="loading-spinner" style="width:32px;height:32px;"></div>
      </div>
    {{else}}
      <div class="kanban-board">
        {{#each this.columns as |column|}}
          <KanbanColumn @statusKey={{column.key}} @label={{column.label}} @onOpen={{this.openDetail}} />
        {{/each}}
      </div>
    {{/if}}

    <ProjectDetailPanel @project={{this.selectedProject}} @onClose={{this.closeDetail}} />
  </template>
}

export default <template><ProjectsPage /></template>
