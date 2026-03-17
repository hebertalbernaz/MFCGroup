import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { STATUSES } from 'my-app/services/projects';

class StatusOption extends Component {
  get isSelected() {
    return this.args.value === this.args.current;
  }

  <template>
    <option value={{@value}} selected={{this.isSelected}}>{{@label}}</option>
  </template>
}

export default class ProjectDetailPanel extends Component {
  @service projects;
  @service toast;

  @tracked notes = '';
  @tracked isSavingNotes = false;
  @tracked lastSavedProjectId = null;

  get project() {
    return this.args.project;
  }

  get isOpen() {
    return !!this.project;
  }

  get statuses() {
    return STATUSES;
  }

  get statusLabel() {
    const s = STATUSES.find((s) => s.key === this.project?.status);
    return s ? s.label : this.project?.status;
  }

  get badgeClass() {
    return this.project?.product_type === 'MFC' ? 'badge badge-mfc' : 'badge badge-pod';
  }

  get slaStatus() {
    if (!this.project) return 'green';
    return this.projects.getSlaStatus(this.project);
  }

  get slaBadgeClass() {
    return `sla-badge sla-badge-${this.slaStatus}`;
  }

  get slaDotClass() {
    return `sla-dot sla-dot-${this.slaStatus}`;
  }

  get slaLabel() {
    const map = { green: 'On Track', yellow: 'Due Soon', red: 'Overdue' };
    return map[this.slaStatus];
  }

  get formattedDate() {
    const d = this.project?.created_at;
    if (!d) return '—';
    return new Date(d).toLocaleDateString('en-IE', { day: '2-digit', month: 'short', year: 'numeric' });
  }

  get formattedDeadline() {
    const d = this.project?.deadline;
    if (!d) return '—';
    return new Date(d).toLocaleDateString('en-IE', { day: '2-digit', month: 'short', year: 'numeric' });
  }

  get mailtoHref() {
    if (!this.project?.email) return '#';
    const subject = encodeURIComponent(`Re: Project ${this.project.project_id} — ${this.project.client_name}`);
    return `mailto:${this.project.email}?subject=${subject}`;
  }

  syncNotesIfNeeded() {
    if (this.project && this.project.id !== this.lastSavedProjectId) {
      this.notes = this.project.internal_notes || '';
      this.lastSavedProjectId = this.project.id;
    }
  }

  handleNotesInput = (e) => {
    this.notes = e.target.value;
  };

  handleStatusChange = async (e) => {
    await this.projects.updateProjectStatus(this.project.id, e.target.value);
  };

  saveNotes = async () => {
    if (this.isSavingNotes || !this.project) return;
    this.isSavingNotes = true;
    try {
      await this.projects.updateProjectNotes(this.project.id, this.notes);
      this.toast.success('Notes saved successfully.', { duration: 3000 });
    } catch {
      this.toast.error('Failed to save notes. Please try again.', { duration: 5000 });
    } finally {
      this.isSavingNotes = false;
    }
  };

  handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) {
      this.args.onClose?.();
    }
  };

  <template>
    {{#if this.isOpen}}
      {{(this.syncNotesIfNeeded)}}
      <div class="panel-overlay" role="dialog" aria-modal="true" {{on "click" this.handleOverlayClick}}>
        <div class="panel-slideover">
          <div class="panel-header">
            <div style="display: flex; align-items: center; gap: var(--space-3);">
              <span class="panel-project-id">{{this.project.project_id}}</span>
              <span class={{this.badgeClass}}>{{this.project.product_type}}</span>
              <div class={{this.slaBadgeClass}}>
                <div class={{this.slaDotClass}}></div>
                {{this.slaLabel}}
              </div>
            </div>
            <button type="button" class="btn btn-ghost btn-icon" {{on "click" @onClose}}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          </div>

          <div class="panel-body">
            <h2 class="panel-client-name">{{this.project.client_name}}</h2>

            <a href={{this.mailtoHref}} class="btn panel-email-btn">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                <polyline points="22,6 12,13 2,6" />
              </svg>
              Email Client
            </a>

            <div class="panel-details-grid">
              <div class="panel-detail-item">
                <span class="panel-detail-label">Email</span>
                <span class="panel-detail-value">{{if this.project.email this.project.email "—"}}</span>
              </div>
              <div class="panel-detail-item">
                <span class="panel-detail-label">Phone</span>
                <span class="panel-detail-value">{{if this.project.phone this.project.phone "—"}}</span>
              </div>
              <div class="panel-detail-item">
                <span class="panel-detail-label">Eircode</span>
                <span class="panel-detail-value font-mono">{{if this.project.eircode this.project.eircode "—"}}</span>
              </div>
              <div class="panel-detail-item">
                <span class="panel-detail-label">Created</span>
                <span class="panel-detail-value">{{this.formattedDate}}</span>
              </div>
              <div class="panel-detail-item">
                <span class="panel-detail-label">SLA Deadline</span>
                <span class="panel-detail-value">{{this.formattedDeadline}}</span>
              </div>
              <div class="panel-detail-item">
                <span class="panel-detail-label">Project ID</span>
                <span class="panel-detail-value font-mono">{{this.project.project_id}}</span>
              </div>
            </div>

            <div class="panel-section">
              <label class="panel-section-title" for="panel-status-select">Pipeline Status</label>
              <select id="panel-status-select" class="form-select" {{on "change" this.handleStatusChange}}>
                {{#each this.statuses as |status|}}
                  <StatusOption @value={{status.key}} @label={{status.label}} @current={{this.project.status}} />
                {{/each}}
              </select>
            </div>

            <div class="panel-section">
              <label class="panel-section-title" for="panel-notes">Internal Memos &amp; Engineering Notes</label>
              <textarea
                id="panel-notes"
                class="form-input panel-notes-textarea"
                placeholder="Add internal questions, engineering notes, site visit observations..."
                value={{this.notes}}
                {{on "input" this.handleNotesInput}}
              ></textarea>
              <div style="display: flex; justify-content: flex-end; margin-top: var(--space-3);">
                <button
                  type="button"
                  class="btn btn-primary"
                  disabled={{this.isSavingNotes}}
                  {{on "click" this.saveNotes}}
                >
                  {{if this.isSavingNotes "Saving..." "Save Notes"}}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
