import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import KanbanProjectCard from '../../components/kanban-project-card';
import ProjectDetailsModal from '../../components/project-details-modal';

class DesignDeskPage extends Component {
  @service projects;
  @service supabase;
  @service toast;
  @tracked searchQuery = '';
  @tracked selectedProject = null;
  @tracked slaTargets = null;
  @tracked isLoading = true;

  statuses = [
    { key: 'New Enquiry', label: 'New Enquiry', color: 'blue' },
    { key: 'In Design', label: 'In Design', color: 'purple' },
    { key: 'Awaiting Quote', label: 'Awaiting Quote', color: 'yellow' },
    { key: 'Revisions', label: 'Revisions', color: 'orange' },
    { key: 'Approved', label: 'Approved', color: 'green' },
  ];

  constructor() {
    super(...arguments);
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      await this.projects.fetchProjects();
      await this.loadSlaTargets();
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      this.isLoading = false;
    }
  }

  async loadSlaTargets() {
    try {
      const { data, error } = await this.supabase.client
        .from('app_settings')
        .select('key, value')
        .in('key', ['sla_new_enquiry', 'sla_in_design', 'sla_awaiting_quote', 'sla_revisions']);

      if (error) throw error;

      this.slaTargets = {};
      data.forEach(item => {
        this.slaTargets[item.key] = parseInt(item.value, 10);
      });
    } catch (error) {
      console.error('Error loading SLA targets:', error);
    }
  }

  updateSearch = (e) => {
    this.searchQuery = e.target.value;
  };

  get filteredProjects() {
    const query = this.searchQuery.trim().toLowerCase();
    if (!query) return this.projects.projects;

    return this.projects.projects.filter(project => {
      return (
        project.client_name?.toLowerCase().includes(query) ||
        project.tpf_id?.toLowerCase().includes(query) ||
        project.project_id?.toLowerCase().includes(query) ||
        project.eircode?.toLowerCase().includes(query)
      );
    });
  }

  get newEnquiryProjects() {
    return this.filteredProjects.filter(p => p.status === 'New Enquiry');
  }

  get inDesignProjects() {
    return this.filteredProjects.filter(p => p.status === 'In Design');
  }

  get awaitingQuoteProjects() {
    return this.filteredProjects.filter(p => p.status === 'Awaiting Quote');
  }

  get revisionsProjects() {
    return this.filteredProjects.filter(p => p.status === 'Revisions');
  }

  get approvedProjects() {
    return this.filteredProjects.filter(p => p.status === 'Approved');
  }

  getProjectsForStatus(status) {
    if (status === 'New Enquiry') return this.newEnquiryProjects;
    if (status === 'In Design') return this.inDesignProjects;
    if (status === 'Awaiting Quote') return this.awaitingQuoteProjects;
    if (status === 'Revisions') return this.revisionsProjects;
    if (status === 'Approved') return this.approvedProjects;
    return [];
  }

  handleCardClick = (project) => {
    this.selectedProject = project;
  };

  closeModal = () => {
    this.selectedProject = null;
  };

  handleModalUpdate = async () => {
    await this.projects.fetchProjects();
  };

  moveProject = async (project, newStatus) => {
    try {
      const { error } = await this.supabase.client
        .from('projects')
        .update({
          status: newStatus,
          status_updated_at: new Date().toISOString()
        })
        .eq('id', project.id);

      if (error) throw error;

      this.toast.success(`Moved to ${newStatus}`);
      await this.projects.fetchProjects();
    } catch (error) {
      console.error('Error moving project:', error);
      this.toast.error('Failed to move project');
    }
  };

  clearSearch = () => {
    this.searchQuery = '';
  };

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Design Desk</h1>
        <p class="page-subtitle">Kanban board for managing project workflow</p>
      </div>
    </div>

    <div class="kanban-toolbar">
      <div class="search-box">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"/>
          <path d="m21 21-4.35-4.35"/>
        </svg>
        <input
          type="text"
          class="search-input"
          placeholder="Smart Search: Name, ID, or Eircode..."
          value={{this.searchQuery}}
          {{on "input" this.updateSearch}}
        />
        {{#if this.searchQuery}}
          <button type="button" class="search-clear" {{on "click" this.clearSearch}}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        {{/if}}
      </div>

      <div class="kanban-stats">
        <span class="kanban-stat">{{this.filteredProjects.length}} projects</span>
      </div>
    </div>

    {{#if this.isLoading}}
      <div class="empty-state">
        <div class="loading-spinner" style="width:32px;height:32px;"></div>
      </div>
    {{else}}
      <div class="kanban-board">
        <div class="kanban-column">
          <div class="kanban-column-header kanban-column-header-blue">
            <span class="kanban-column-title">New Enquiry</span>
            <span class="kanban-column-count">{{this.newEnquiryProjects.length}}</span>
          </div>
          <div class="kanban-column-body">
            {{#each this.newEnquiryProjects as |project|}}
              <KanbanProjectCard
                @project={{project}}
                @slaTargets={{this.slaTargets}}
                @onClick={{this.handleCardClick}}
              />
            {{else}}
              <div class="kanban-empty">
                <p>No projects</p>
              </div>
            {{/each}}
          </div>
        </div>

        <div class="kanban-column">
          <div class="kanban-column-header kanban-column-header-purple">
            <span class="kanban-column-title">In Design</span>
            <span class="kanban-column-count">{{this.inDesignProjects.length}}</span>
          </div>
          <div class="kanban-column-body">
            {{#each this.inDesignProjects as |project|}}
              <KanbanProjectCard
                @project={{project}}
                @slaTargets={{this.slaTargets}}
                @onClick={{this.handleCardClick}}
              />
            {{else}}
              <div class="kanban-empty">
                <p>No projects</p>
              </div>
            {{/each}}
          </div>
        </div>

        <div class="kanban-column">
          <div class="kanban-column-header kanban-column-header-yellow">
            <span class="kanban-column-title">Awaiting Quote</span>
            <span class="kanban-column-count">{{this.awaitingQuoteProjects.length}}</span>
          </div>
          <div class="kanban-column-body">
            {{#each this.awaitingQuoteProjects as |project|}}
              <KanbanProjectCard
                @project={{project}}
                @slaTargets={{this.slaTargets}}
                @onClick={{this.handleCardClick}}
              />
            {{else}}
              <div class="kanban-empty">
                <p>No projects</p>
              </div>
            {{/each}}
          </div>
        </div>

        <div class="kanban-column">
          <div class="kanban-column-header kanban-column-header-orange">
            <span class="kanban-column-title">Revisions</span>
            <span class="kanban-column-count">{{this.revisionsProjects.length}}</span>
          </div>
          <div class="kanban-column-body">
            {{#each this.revisionsProjects as |project|}}
              <KanbanProjectCard
                @project={{project}}
                @slaTargets={{this.slaTargets}}
                @onClick={{this.handleCardClick}}
              />
            {{else}}
              <div class="kanban-empty">
                <p>No projects</p>
              </div>
            {{/each}}
          </div>
        </div>

        <div class="kanban-column">
          <div class="kanban-column-header kanban-column-header-green">
            <span class="kanban-column-title">Approved</span>
            <span class="kanban-column-count">{{this.approvedProjects.length}}</span>
          </div>
          <div class="kanban-column-body">
            {{#each this.approvedProjects as |project|}}
              <KanbanProjectCard
                @project={{project}}
                @slaTargets={{this.slaTargets}}
                @onClick={{this.handleCardClick}}
              />
            {{else}}
              <div class="kanban-empty">
                <p>No projects</p>
              </div>
            {{/each}}
          </div>
        </div>
      </div>
    {{/if}}

    <ProjectDetailsModal
      @project={{this.selectedProject}}
      @onClose={{this.closeModal}}
      @onUpdate={{this.handleModalUpdate}}
    />
  </template>
}

export default <template><DesignDeskPage /></template>
