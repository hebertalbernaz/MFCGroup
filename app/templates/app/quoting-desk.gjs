import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import ProjectDetailPanel from 'my-app/components/project-detail-panel';

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

  @tracked selectedProject = null;

  get awaitingQuoteProjects() {
    return this.projects.projects.filter((p) => p.status === 'awaiting_quote');
  }

  get isEmpty() {
    return !this.projects.isLoading && this.awaitingQuoteProjects.length === 0;
  }

  openQuote = (project) => {
    this.selectedProject = project;
  };

  closeQuote = () => {
    this.selectedProject = null;
  };

  getGrossBaseBudget(project) {
    const floor = parseFloat(project.floor_area_sqm) || 0;
    const lineItems = project.quote_line_items || [];
    const hasParams = floor > 0 || lineItems.length > 0;
    return hasParams ? formatEur(floor * 1450 + lineItems.reduce((s, i) => s + (parseFloat(i.line_total) || 0), 0)) : '—';
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
        <p class="page-subtitle">Projects awaiting a quote — open any row to access the Quote Builder</p>
      </div>
      <div style="display: flex; align-items: center; gap: var(--space-3);">
        <div class="qd-count-badge">
          <span class="qd-count-num">{{this.awaitingQuoteProjects.length}}</span>
          <span class="qd-count-label">Pending Quotes</span>
        </div>
      </div>
    </div>

    {{#if this.projects.isLoading}}
      <div class="empty-state">
        <div class="loading-spinner"></div>
      </div>
    {{else if this.isEmpty}}
      <div class="empty-state">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="color: var(--text-tertiary);">
          <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
          <polyline points="14 2 14 8 20 8"/>
          <line x1="16" y1="13" x2="8" y2="13"/>
          <line x1="16" y1="17" x2="8" y2="17"/>
        </svg>
        <div class="empty-state-title">No Pending Quotes</div>
        <div class="empty-state-desc">All projects with "Awaiting Quote" status will appear here.</div>
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
            {{#each this.awaitingQuoteProjects as |project|}}
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

    <ProjectDetailPanel
      @project={{this.selectedProject}}
      @onClose={{this.closeQuote}}
    />
  </template>
}

export default <template><QuotingDesk /></template>
