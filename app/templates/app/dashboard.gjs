import { service } from '@ember/service';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

class DashboardPage extends Component {
  @service projects;
  @service auth;
  @service toast;
  @service supabase;
  @tracked isCreatingProject = false;

  get totalProjects() {
    return this.projects.projects.length;
  }

  get openProjects() {
    return this.projects.projects.filter((p) => p.status !== 'Archived').length;
  }

  get newEnquiries() {
    return this.projects.projects.filter((p) => p.status === 'New Enquiry').length;
  }

  get inDesign() {
    return this.projects.projects.filter((p) => p.status === 'In Design').length;
  }

  get approved() {
    return this.projects.projects.filter((p) => p.status === 'Approved').length;
  }

  get recentProjects() {
    return this.projects.projects
      .slice()
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
      .slice(0, 5);
  }

  formatDate(dateStr) {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleDateString('en-IE', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  }

  statusBadgeClass(status) {
    const map = {
      'New Enquiry': 'badge badge-blue',
      'In Design': 'badge badge-purple',
      'Awaiting Quote': 'badge badge-yellow',
      'Revisions': 'badge badge-orange',
      'Approved': 'badge badge-green',
      'Archived': 'badge badge-gray',
    };
    return map[status] || 'badge';
  }

  createTestProject = async () => {
    if (this.isCreatingProject) return;
    this.isCreatingProject = true;

    try {
      const { data: settingsData, error: settingsError } = await this.supabase.client
        .from('app_settings')
        .select('value')
        .eq('key', 'next_pod_number')
        .maybeSingle();

      if (settingsError) throw settingsError;

      const currentNumber = parseInt(settingsData?.value || '1000', 10);
      const tpfId = `POD-${currentNumber}`;

      const { error: insertError } = await this.supabase.client
        .from('projects')
        .insert({
          tpf_id: tpfId,
          client_name: 'Test Client',
          status: 'New Enquiry',
          internal_notes: 'Test project created from Dashboard',
        });

      if (insertError) throw insertError;

      const { error: updateError } = await this.supabase.client
        .from('app_settings')
        .update({ value: String(currentNumber + 1) })
        .eq('key', 'next_pod_number');

      if (updateError) throw updateError;

      this.toast.success(`Project ${tpfId} created successfully`);

      await this.projects.fetchProjects();
    } catch (error) {
      console.error('Error creating project:', error);
      this.toast.error('Failed to create project');
    } finally {
      this.isCreatingProject = false;
    }
  };

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Dashboard</h1>
        <p class="page-subtitle">Overview of The Pod Factory projects and enquiries</p>
      </div>
      {{#if this.auth.isAdmin}}
        <button
          type="button"
          class="btn btn-primary"
          disabled={{this.isCreatingProject}}
          {{on "click" this.createTestProject}}
        >
          {{#if this.isCreatingProject}}
            <div class="loading-spinner" style="width:14px;height:14px;border-width:2px;"></div>
            Creating...
          {{else}}
            Test: Create Project
          {{/if}}
        </button>
      {{/if}}
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
          <div class="stat-card-label">New Enquiries</div>
          <div class="stat-card-value">{{this.newEnquiries}}</div>
          <div class="stat-card-sub">Pending review</div>
        </div>
        <div class="stat-card">
          <div class="stat-card-label">In Design</div>
          <div class="stat-card-value">{{this.inDesign}}</div>
          <div class="stat-card-sub">Active design</div>
        </div>
        <div class="stat-card">
          <div class="stat-card-label">Approved</div>
          <div class="stat-card-value">{{this.approved}}</div>
          <div class="stat-card-sub">Ready to proceed</div>
        </div>
        <div class="stat-card">
          <div class="stat-card-label">Open Projects</div>
          <div class="stat-card-value">{{this.openProjects}}</div>
          <div class="stat-card-sub">Not archived</div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">Recent Projects</span>
        </div>
        {{#if this.recentProjects.length}}
          <div class="card-body" style="padding: 0;">
            <table style="width: 100%; border-collapse: collapse;">
              <thead>
                <tr style="border-bottom: 1px solid var(--border-default);">
                  <th style="padding: var(--space-3) var(--space-6); text-align: left; font-size: var(--text-xs); font-weight: 600; color: var(--text-secondary); text-transform: uppercase;">Project ID</th>
                  <th style="padding: var(--space-3) var(--space-6); text-align: left; font-size: var(--text-xs); font-weight: 600; color: var(--text-secondary); text-transform: uppercase;">Client</th>
                  <th style="padding: var(--space-3) var(--space-6); text-align: left; font-size: var(--text-xs); font-weight: 600; color: var(--text-secondary); text-transform: uppercase;">Status</th>
                  <th style="padding: var(--space-3) var(--space-6); text-align: left; font-size: var(--text-xs); font-weight: 600; color: var(--text-secondary); text-transform: uppercase;">Created</th>
                </tr>
              </thead>
              <tbody>
                {{#each this.recentProjects as |project|}}
                  <tr style="border-bottom: 1px solid var(--border-default);">
                    <td style="padding: var(--space-3) var(--space-6);">
                      <span style="font-family: var(--font-mono); font-size: var(--text-sm); font-weight: 600; color: var(--text-primary);">{{or project.tpf_id project.project_id}}</span>
                    </td>
                    <td style="padding: var(--space-3) var(--space-6);">
                      <span style="font-size: var(--text-sm); color: var(--text-primary);">{{project.client_name}}</span>
                    </td>
                    <td style="padding: var(--space-3) var(--space-6);">
                      <span class={{this.statusBadgeClass project.status}}>{{project.status}}</span>
                    </td>
                    <td style="padding: var(--space-3) var(--space-6);">
                      <span style="font-size: var(--text-sm); color: var(--text-secondary);">{{this.formatDate project.created_at}}</span>
                    </td>
                  </tr>
                {{/each}}
              </tbody>
            </table>
          </div>
        {{else}}
          <div class="empty-state" style="padding: var(--space-8);">
            <p class="empty-state-desc">No projects yet. Create one using the test button above.</p>
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}

function or(a, b) { return a || b; }

export default <template><DashboardPage /></template>
