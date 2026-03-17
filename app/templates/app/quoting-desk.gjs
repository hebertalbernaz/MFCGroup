import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import ProjectDetailPanel from 'my-app/components/project-detail-panel';

function eq(a, b) { return a === b; }

function formatDate(d) {
  if (!d) return '—';
  return new Date(d).toLocaleDateString('en-IE', { day: '2-digit', month: 'short', year: 'numeric' });
}

function formatEur(val) {
  const n = parseFloat(val) || 0;
  return `€${n.toLocaleString('en-IE', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
}

class QuotingDesk extends Component {
  @service projects;
  @service auditLog;
  @service auth;
  @service toast;

  @tracked selectedProject = null;
  @tracked activeTab = 'active';
  @tracked searchQuery = '';
  @tracked unarchivingId = null;

  get awaitingQuoteProjects() {
    return this.projects.projects.filter((p) => p.status === 'awaiting_quote');
  }

  get archivedProjects() {
    return this.projects.projects.filter((p) => p.status === 'archived');
  }

  get filteredActive() {
    return this._applySearch(this.awaitingQuoteProjects);
  }

  get filteredArchived() {
    return this._applySearch(this.archivedProjects);
  }

  _applySearch(list) {
    const q = this.searchQuery.trim().toLowerCase();
    if (!q) return list;
    return list.filter(
      (p) =>
        p.client_name?.toLowerCase().includes(q) ||
        p.project_id?.toLowerCase().includes(q) ||
        p.eircode?.toLowerCase().includes(q)
    );
  }

  get activeCount() { return this.awaitingQuoteProjects.length; }
  get archivedCount() { return this.archivedProjects.length; }

  get isActiveEmpty() {
    return !this.projects.isLoading && this.filteredActive.length === 0;
  }

  get isArchivedEmpty() {
    return !this.projects.isLoading && this.filteredArchived.length === 0;
  }

  setTab = (tab) => {
    this.activeTab = tab;
    this.searchQuery = '';
  };

  handleSearch = (e) => {
    this.searchQuery = e.target.value;
  };

  openQuote = (project) => {
    this.selectedProject = project;
  };

  closeQuote = () => {
    this.selectedProject = null;
  };

  unarchive = async (project) => {
    if (this.unarchivingId) return;
    this.unarchivingId = project.id;
    try {
      await this.projects.updateProjectStatus(project.id, 'awaiting_quote');
      this.auditLog.logAction(
        this.auth.currentUser,
        'PROJECT_UNARCHIVED',
        `${project.project_id} — ${project.client_name} → awaiting_quote`
      );
      this.toast.success(`${project.project_id} restored to Awaiting Quote.`, { duration: 3000 });
    } catch {
      this.toast.error('Failed to un-archive project.', { duration: 5000 });
    } finally {
      this.unarchivingId = null;
    }
  };

  getGrossBaseBudget(project) {
    const floor = parseFloat(project.floor_area_sqm) || 0;
    const lineItems = project.quote_line_items || [];
    const hasParams = floor > 0 || lineItems.length > 0;
    return hasParams
      ? formatEur(floor * 1450 + lineItems.reduce((s, i) => s + (parseFloat(i.line_total) || 0), 0))
      : '—';
  }

  badgeClass(type) {
    return type === 'MFC' ? 'badge badge-mfc' : 'badge badge-pod';
  }

  slaClass(project) {
    const status = this.projects.getSlaStatus(project);
    return `sla-dot sla-dot-${status}`;
  }

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Quoting Desk</h1>
        <p class="page-subtitle">Manage active quotes and review archived clients</p>
      </div>
      <div style="display: flex; align-items: center; gap: var(--space-3);">
        <div class="qd-count-badge">
          <span class="qd-count-num">{{this.activeCount}}</span>
          <span class="qd-count-label">Pending Quotes</span>
        </div>
      </div>
    </div>

    {{!-- Tab Bar + Search Row --}}
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: var(--space-4); gap: var(--space-4);">
      <div class="settings-tabs-bar" style="margin-bottom: 0; border-bottom: none;">
        <button
          type="button"
          class={{if (eq this.activeTab "active") "settings-tab settings-tab-active" "settings-tab"}}
          {{on "click" (fn this.setTab "active")}}
        >
          Active Quotes
          <span style="
            display: inline-flex; align-items: center; justify-content: center;
            margin-left: var(--space-2); min-width: 20px; height: 20px; padding: 0 6px;
            border-radius: 999px; font-size: 11px; font-weight: 700;
            background: var(--color-primary-100); color: var(--color-primary-700);
          ">{{this.activeCount}}</span>
        </button>
        <button
          type="button"
          class={{if (eq this.activeTab "archived") "settings-tab settings-tab-active" "settings-tab"}}
          {{on "click" (fn this.setTab "archived")}}
        >
          Archived Clients
          <span style="
            display: inline-flex; align-items: center; justify-content: center;
            margin-left: var(--space-2); min-width: 20px; height: 20px; padding: 0 6px;
            border-radius: 999px; font-size: 11px; font-weight: 700;
            background: var(--bg-surface-raised); color: var(--text-secondary);
          ">{{this.archivedCount}}</span>
        </button>
      </div>

      <div style="position: relative; min-width: 260px;">
        <svg style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: var(--text-tertiary); pointer-events: none;"
          width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input
          type="text"
          class="form-input"
          style="padding-left: 32px; font-size: var(--text-sm);"
          placeholder="Filter by client, ID or eircode..."
          value={{this.searchQuery}}
          {{on "input" this.handleSearch}}
        />
      </div>
    </div>

    {{#if this.projects.isLoading}}
      <div class="empty-state">
        <div class="loading-spinner"></div>
      </div>

    {{else if (eq this.activeTab "active")}}

      {{#if this.isActiveEmpty}}
        <div class="empty-state">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="color: var(--text-tertiary);">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
          </svg>
          <div class="empty-state-title">
            {{#if this.searchQuery}}No matches found{{else}}No Pending Quotes{{/if}}
          </div>
          <div class="empty-state-desc">
            {{#if this.searchQuery}}Try a different search term.{{else}}Projects with "Awaiting Quote" status will appear here.{{/if}}
          </div>
        </div>
      {{else}}
        <div class="qd-table-wrap">
          <table class="qd-table">
            <thead>
              <tr>
                <th>Project ID</th>
                <th>Client</th>
                <th>Type</th>
                <th>Eircode</th>
                <th>Floor m²</th>
                <th>Est. Budget</th>
                <th>Line Items</th>
                <th>Created</th>
                <th style="text-align: right;">Action</th>
              </tr>
            </thead>
            <tbody>
              {{#each this.filteredActive as |project|}}
                <tr class="qd-row">
                  <td>
                    <div style="display: flex; align-items: center; gap: var(--space-2);">
                      <div class={{this.slaClass project}}></div>
                      <span class="qd-project-id">{{project.project_id}}</span>
                    </div>
                  </td>
                  <td class="qd-client-name">{{project.client_name}}</td>
                  <td><span class={{this.badgeClass project.product_type}}>{{project.product_type}}</span></td>
                  <td class="font-mono" style="font-size: var(--text-xs); color: var(--text-secondary);">
                    {{if project.eircode project.eircode "—"}}
                  </td>
                  <td style="font-family: var(--font-mono); font-size: var(--text-sm);">
                    {{if project.floor_area_sqm project.floor_area_sqm "—"}}
                  </td>
                  <td style="font-weight: 600; font-family: var(--font-mono); font-size: var(--text-sm); color: var(--color-primary-600);">
                    {{this.getGrossBaseBudget project}}
                  </td>
                  <td style="text-align: center;">
                    <span class="qd-items-count">
                      {{if project.quote_line_items project.quote_line_items.length "0"}}
                    </span>
                  </td>
                  <td style="font-size: var(--text-xs); color: var(--text-secondary);">
                    {{formatDate project.created_at}}
                  </td>
                  <td style="text-align: right;">
                    <button
                      type="button"
                      class="btn btn-primary btn-sm"
                      {{on "click" (fn this.openQuote project)}}
                    >
                      Open Quote
                    </button>
                  </td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        </div>
      {{/if}}

    {{else}}

      {{!-- Archived Tab --}}
      {{#if this.isArchivedEmpty}}
        <div class="empty-state">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="color: var(--text-tertiary);">
            <polyline points="21 8 21 21 3 21 3 8"/>
            <rect x="1" y="3" width="22" height="5"/>
            <line x1="10" y1="12" x2="14" y2="12"/>
          </svg>
          <div class="empty-state-title">
            {{#if this.searchQuery}}No matches found{{else}}No Archived Clients{{/if}}
          </div>
          <div class="empty-state-desc">
            {{#if this.searchQuery}}Try a different search term.{{else}}Archived projects will appear here. Use the Archive button on any project to move it here.{{/if}}
          </div>
        </div>
      {{else}}
        <div class="qd-table-wrap">
          <table class="qd-table">
            <thead>
              <tr>
                <th>Project ID</th>
                <th>Client</th>
                <th>Type</th>
                <th>Eircode</th>
                <th>Floor m²</th>
                <th>Est. Budget</th>
                <th>Line Items</th>
                <th>Archived</th>
                <th style="text-align: right;">Action</th>
              </tr>
            </thead>
            <tbody>
              {{#each this.filteredArchived as |project|}}
                <tr class="qd-row" style="opacity: 0.8;">
                  <td>
                    <div style="display: flex; align-items: center; gap: var(--space-2);">
                      <span class="qd-project-id" style="color: var(--text-secondary);">{{project.project_id}}</span>
                    </div>
                  </td>
                  <td class="qd-client-name">{{project.client_name}}</td>
                  <td><span class={{this.badgeClass project.product_type}}>{{project.product_type}}</span></td>
                  <td class="font-mono" style="font-size: var(--text-xs); color: var(--text-secondary);">
                    {{if project.eircode project.eircode "—"}}
                  </td>
                  <td style="font-family: var(--font-mono); font-size: var(--text-sm);">
                    {{if project.floor_area_sqm project.floor_area_sqm "—"}}
                  </td>
                  <td style="font-weight: 600; font-family: var(--font-mono); font-size: var(--text-sm); color: var(--text-secondary);">
                    {{this.getGrossBaseBudget project}}
                  </td>
                  <td style="text-align: center;">
                    <span class="qd-items-count">
                      {{if project.quote_line_items project.quote_line_items.length "0"}}
                    </span>
                  </td>
                  <td style="font-size: var(--text-xs); color: var(--text-secondary);">
                    {{formatDate project.updated_at}}
                  </td>
                  <td style="text-align: right;">
                    <div style="display: flex; align-items: center; justify-content: flex-end; gap: var(--space-2);">
                      <button
                        type="button"
                        class="btn btn-ghost btn-sm"
                        {{on "click" (fn this.openQuote project)}}
                      >
                        View
                      </button>
                      <button
                        type="button"
                        class="btn btn-secondary btn-sm"
                        disabled={{if (eq this.unarchivingId project.id) true false}}
                        {{on "click" (fn this.unarchive project)}}
                      >
                        {{#if (eq this.unarchivingId project.id)}}
                          Restoring...
                        {{else}}
                          Un-archive
                        {{/if}}
                      </button>
                    </div>
                  </td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        </div>
      {{/if}}

    {{/if}}

    <ProjectDetailPanel
      @project={{this.selectedProject}}
      @onClose={{this.closeQuote}}
    />
  </template>
}

export default <template><QuotingDesk /></template>
