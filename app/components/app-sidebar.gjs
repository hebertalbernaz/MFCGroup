import Component from '@glimmer/component';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { on } from '@ember/modifier';

export default class AppSidebar extends Component {
  @service auth;
  @service router;

  get user() { return this.auth.currentUser; }
  get isAdmin() { return this.auth.isAdmin; }
  get isDesigner() { return this.auth.isDesigner; }
  get isEstimator() { return this.auth.isEstimator; }

  get roleBadgeClass() {
    const r = this.auth.role;
    if (r === 'admin') return 'sidebar-role-badge sidebar-role-admin';
    if (r === 'designer') return 'sidebar-role-badge sidebar-role-designer';
    if (r === 'estimator') return 'sidebar-role-badge sidebar-role-estimator';
    return 'sidebar-role-badge';
  }

  get roleLabel() {
    const r = this.auth.role;
    if (r === 'admin') return 'Admin';
    if (r === 'designer') return 'Designer';
    if (r === 'estimator') return 'Estimator';
    return r;
  }

  handleLogout = () => {
    this.auth.logout();
    this.router.transitionTo('login');
  };

  <template>
    <aside class="app-sidebar">
      <div class="sidebar-logo">
        <div class="sidebar-logo-mark">MFC</div>
        <div>
          <div class="sidebar-brand-name">MFC Group</div>
          <div class="sidebar-brand-sub">Design System</div>
        </div>
      </div>

      <nav class="sidebar-nav">

        {{#if (or this.isAdmin this.isDesigner)}}
          <div class="sidebar-section-label">Main</div>

          <LinkTo @route="app.dashboard" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="3" width="7" height="7" rx="1"/>
              <rect x="14" y="3" width="7" height="7" rx="1"/>
              <rect x="3" y="14" width="7" height="7" rx="1"/>
              <rect x="14" y="14" width="7" height="7" rx="1"/>
            </svg>
            Dashboard
          </LinkTo>

          <LinkTo @route="app.projects" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 11l3 3L22 4"/>
              <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
            </svg>
            Projects
          </LinkTo>

          <LinkTo @route="app.calendar" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2"/>
              <line x1="16" y1="2" x2="16" y2="6"/>
              <line x1="8" y1="2" x2="8" y2="6"/>
              <line x1="3" y1="10" x2="21" y2="10"/>
            </svg>
            Calendar
          </LinkTo>
        {{/if}}

        {{#if this.isEstimator}}
          <div class="sidebar-section-label">Schedule</div>

          <LinkTo @route="app.calendar" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2"/>
              <line x1="16" y1="2" x2="16" y2="6"/>
              <line x1="8" y1="2" x2="8" y2="6"/>
              <line x1="3" y1="10" x2="21" y2="10"/>
            </svg>
            Calendar
          </LinkTo>

          <div class="sidebar-section-label" style="margin-top: 8px;">Quoting</div>

          <LinkTo @route="app.quoting-desk" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
              <polyline points="10 9 9 9 8 9"/>
            </svg>
            Quoting Desk
          </LinkTo>
        {{/if}}

        {{#if this.isAdmin}}
          <div class="sidebar-section-label" style="margin-top: 8px;">Quoting</div>

          <LinkTo @route="app.quoting-desk" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
              <polyline points="10 9 9 9 8 9"/>
            </svg>
            Quoting Desk
          </LinkTo>

          <div class="sidebar-section-label" style="margin-top: 8px;">System</div>

          <LinkTo @route="app.reports" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="20" x2="18" y2="10"/>
              <line x1="12" y1="20" x2="12" y2="4"/>
              <line x1="6" y1="20" x2="6" y2="14"/>
            </svg>
            Reports
          </LinkTo>

          <LinkTo @route="app.settings" class="sidebar-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="3"/>
              <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/>
            </svg>
            Settings
          </LinkTo>
        {{/if}}

      </nav>

      <div class="sidebar-footer">
        {{#if this.user}}
          <div class="sidebar-user">
            <div class="sidebar-user-avatar">{{this.user.initials}}</div>
            <div class="sidebar-user-info">
              <div class="sidebar-user-name">{{this.user.displayName}}</div>
              <div class={{this.roleBadgeClass}}>{{this.roleLabel}}</div>
            </div>
          </div>
        {{/if}}
        <button type="button" class="sidebar-logout-btn" {{on "click" this.handleLogout}}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
          Sign Out
        </button>
      </div>
    </aside>
  </template>
}

function or(a, b) { return Boolean(a) || Boolean(b); }
