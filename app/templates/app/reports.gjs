import Component from '@glimmer/component';
import { service } from '@ember/service';

const DESIGNER_PERFORMANCE = [
  { name: 'Ciarán Murphy', activeProjects: 8, overdueProjects: 1, completedThisMonth: 3, avgDesignDays: 11 },
  { name: 'Aoife Brennan', activeProjects: 6, overdueProjects: 0, completedThisMonth: 5, avgDesignDays: 9 },
  { name: 'Seán O\'Brien', activeProjects: 9, overdueProjects: 3, completedThisMonth: 2, avgDesignDays: 14 },
  { name: 'Niamh Kelly', activeProjects: 4, overdueProjects: 0, completedThisMonth: 7, avgDesignDays: 8 },
];

class ReportsDashboard extends Component {
  @service projects;

  get totalProjects() {
    return this.projects.projects.length;
  }

  get pendingQuotes() {
    return this.projects.projects.filter((p) => p.status === 'awaiting_quote').length;
  }

  get activeDesigns() {
    return this.projects.projects.filter((p) => p.status === 'design_active').length;
  }

  get overdueProjects() {
    return this.projects.projects.filter((p) => this.projects.getSlaStatus(p) === 'red').length;
  }

  get signedProjects() {
    return this.projects.projects.filter((p) => p.status === 'signed' || p.status === 'approved').length;
  }

  get conversionRate() {
    if (!this.totalProjects) return '0%';
    return `${Math.round((this.signedProjects / this.totalProjects) * 100)}%`;
  }

  get podProjects() {
    return this.projects.projects.filter((p) => p.product_type === 'POD').length;
  }

  get podSignedProjects() {
    return this.projects.projects.filter((p) => p.product_type === 'POD' && (p.status === 'signed' || p.status === 'approved' || p.project_id?.startsWith('POD-'))).length;
  }

  get pdToPodRate() {
    if (!this.podProjects) return '0%';
    return `${Math.round((this.podSignedProjects / this.podProjects) * 100)}%`;
  }

  performanceBadgeClass(overdue) {
    if (overdue === 0) return 'perf-badge perf-badge-green';
    if (overdue <= 1) return 'perf-badge perf-badge-yellow';
    return 'perf-badge perf-badge-red';
  }

  performanceLabel(overdue) {
    if (overdue === 0) return 'On Track';
    if (overdue <= 1) return 'Minor Delays';
    return 'Attention';
  }

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Reports &amp; Analytics</h1>
        <p class="page-subtitle">Admin-only performance overview and KPI tracking</p>
      </div>
    </div>

    <div class="reports-grid">

      {{!-- KPI Cards --}}
      <div class="kpi-card">
        <div class="kpi-icon kpi-icon-blue">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/>
            <polyline points="12 6 12 12 16 14"/>
          </svg>
        </div>
        <div class="kpi-body">
          <div class="kpi-label">Avg Design Time</div>
          <div class="kpi-value">10.5 <span class="kpi-unit">days</span></div>
          <div class="kpi-sub">Based on completed designs this month</div>
        </div>
      </div>

      <div class="kpi-card">
        <div class="kpi-icon kpi-icon-green">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/>
            <polyline points="16 7 22 7 22 13"/>
          </svg>
        </div>
        <div class="kpi-body">
          <div class="kpi-label">Conversion Rate (PD → POD-)</div>
          <div class="kpi-value">{{this.pdToPodRate}}</div>
          <div class="kpi-sub">{{this.podSignedProjects}} of {{this.podProjects}} POD enquiries signed</div>
        </div>
      </div>

      <div class="kpi-card">
        <div class="kpi-icon kpi-icon-amber">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
          </svg>
        </div>
        <div class="kpi-body">
          <div class="kpi-label">Pending Quotes</div>
          <div class="kpi-value">{{this.pendingQuotes}}</div>
          <div class="kpi-sub">Projects awaiting a quote submission</div>
        </div>
      </div>

      <div class="kpi-card">
        <div class="kpi-icon kpi-icon-red">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
            <line x1="12" y1="9" x2="12" y2="13"/>
            <line x1="12" y1="17" x2="12.01" y2="17"/>
          </svg>
        </div>
        <div class="kpi-body">
          <div class="kpi-label">Overdue SLA</div>
          <div class="kpi-value">{{this.overdueProjects}}</div>
          <div class="kpi-sub">Open projects past 14-day SLA</div>
        </div>
      </div>

      <div class="kpi-card">
        <div class="kpi-icon kpi-icon-teal">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="20" x2="18" y2="10"/>
            <line x1="12" y1="20" x2="12" y2="4"/>
            <line x1="6" y1="20" x2="6" y2="14"/>
          </svg>
        </div>
        <div class="kpi-body">
          <div class="kpi-label">Total Projects</div>
          <div class="kpi-value">{{this.totalProjects}}</div>
          <div class="kpi-sub">{{this.activeDesigns}} currently in active design</div>
        </div>
      </div>

      <div class="kpi-card">
        <div class="kpi-icon kpi-icon-green">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 11-5.93-9.14"/>
            <polyline points="22 4 12 14.01 9 11.01"/>
          </svg>
        </div>
        <div class="kpi-body">
          <div class="kpi-label">Overall Conversion</div>
          <div class="kpi-value">{{this.conversionRate}}</div>
          <div class="kpi-sub">{{this.signedProjects}} of {{this.totalProjects}} projects signed</div>
        </div>
      </div>

    </div>

    {{!-- Designer Performance Table --}}
    <div class="reports-section">
      <div class="reports-section-header">
        <div>
          <h2 class="reports-section-title">Designer Performance</h2>
          <p class="reports-section-sub">Current workload and SLA performance by team member</p>
        </div>
        <div class="reports-mock-badge">Mock Data</div>
      </div>

      <div class="perf-table-wrap">
        <table class="perf-table">
          <thead>
            <tr>
              <th>Designer</th>
              <th style="text-align: center;">Active Projects</th>
              <th style="text-align: center;">Overdue</th>
              <th style="text-align: center;">Completed (Month)</th>
              <th style="text-align: center;">Avg Design Time</th>
              <th style="text-align: center;">Status</th>
            </tr>
          </thead>
          <tbody>
            {{#each DESIGNER_PERFORMANCE as |designer|}}
              <tr class="perf-row">
                <td>
                  <div style="display: flex; align-items: center; gap: var(--space-3);">
                    <div class="perf-avatar">{{designer.name.[0]}}</div>
                    <span class="perf-name">{{designer.name}}</span>
                  </div>
                </td>
                <td style="text-align: center; font-weight: 600; font-family: var(--font-mono);">{{designer.activeProjects}}</td>
                <td style="text-align: center; font-family: var(--font-mono);">
                  <span class={{if designer.overdueProjects "perf-overdue-num" ""}}>{{designer.overdueProjects}}</span>
                </td>
                <td style="text-align: center; font-family: var(--font-mono); color: var(--color-secondary-600); font-weight: 600;">{{designer.completedThisMonth}}</td>
                <td style="text-align: center; font-family: var(--font-mono); font-size: var(--text-sm);">{{designer.avgDesignDays}} days</td>
                <td style="text-align: center;">
                  <span class={{this.performanceBadgeClass designer.overdueProjects}}>
                    {{this.performanceLabel designer.overdueProjects}}
                  </span>
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
    </div>

    {{!-- Pipeline Breakdown --}}
    <div class="reports-section" style="margin-top: var(--space-6);">
      <div class="reports-section-header">
        <div>
          <h2 class="reports-section-title">Pipeline Breakdown</h2>
          <p class="reports-section-sub">Live data from the project pipeline</p>
        </div>
      </div>

      <div class="pipeline-grid">
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.new_enquiry}}</div>
          <div class="pipeline-stat-label">New Enquiries</div>
        </div>
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.design_active}}</div>
          <div class="pipeline-stat-label">Design Active</div>
        </div>
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.in_revision}}</div>
          <div class="pipeline-stat-label">In Revision</div>
        </div>
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.awaiting_approval}}</div>
          <div class="pipeline-stat-label">Awaiting Approval</div>
        </div>
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.awaiting_quote}}</div>
          <div class="pipeline-stat-label">Awaiting Quote</div>
        </div>
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.signed}}</div>
          <div class="pipeline-stat-label">Signed</div>
        </div>
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.approved}}</div>
          <div class="pipeline-stat-label">Approved</div>
        </div>
        <div class="pipeline-stat">
          <div class="pipeline-stat-value">{{this.projects.statusCounts.closed}}</div>
          <div class="pipeline-stat-label">Closed</div>
        </div>
      </div>
    </div>

  </template>
}

export default <template><ReportsDashboard /></template>
