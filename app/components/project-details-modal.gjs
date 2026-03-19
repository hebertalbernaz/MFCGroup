import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

export default class ProjectDetailsModal extends Component {
  @service supabase;
  @service toast;
  @tracked internalNotes = '';
  @tracked isSaving = false;

  constructor() {
    super(...arguments);
    this.internalNotes = this.args.project?.internal_notes || '';
  }

  updateNotes = (e) => {
    this.internalNotes = e.target.value;
  };

  handleSaveNotes = async (e) => {
    e.preventDefault();
    if (this.isSaving) return;

    this.isSaving = true;

    try {
      const { error } = await this.supabase.client
        .from('projects')
        .update({ internal_notes: this.internalNotes })
        .eq('id', this.args.project.id);

      if (error) throw error;

      this.toast.success('Notes saved successfully');

      if (this.args.onUpdate) {
        this.args.onUpdate();
      }
    } catch (error) {
      console.error('Error saving notes:', error);
      this.toast.error('Failed to save notes');
    } finally {
      this.isSaving = false;
    }
  };

  handleClose = () => {
    if (this.args.onClose) {
      this.args.onClose();
    }
  };

  handleBackdropClick = (e) => {
    if (e.target === e.currentTarget) {
      this.handleClose();
    }
  };

  formatDate(dateStr) {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleDateString('en-IE', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  get mailtoLink() {
    return `mailto:${this.args.project?.email || ''}`;
  }

  <template>
    {{#if @project}}
      <div class="modal-backdrop" {{on "click" this.handleBackdropClick}}>
        <div class="modal-panel">
          <div class="modal-header">
            <div>
              <h2 class="modal-title">Project Details</h2>
              <p class="modal-subtitle">{{@project.tpf_id}} — {{@project.client_name}}</p>
            </div>
            <button type="button" class="modal-close-btn" {{on "click" this.handleClose}}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"/>
                <line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>

          <div class="modal-body">
            <div class="details-section">
              <h3 class="details-section-title">Client Information</h3>

              <div class="details-grid">
                <div class="details-field">
                  <label class="details-label">Client Name</label>
                  <div class="details-value">{{or @project.client_name '—'}}</div>
                </div>

                <div class="details-field">
                  <label class="details-label">Email</label>
                  {{#if @project.email}}
                    <a href={{this.mailtoLink}} class="details-value details-link">
                      {{@project.email}}
                    </a>
                  {{else}}
                    <div class="details-value">—</div>
                  {{/if}}
                </div>

                <div class="details-field">
                  <label class="details-label">Phone</label>
                  <div class="details-value">{{or @project.phone '—'}}</div>
                </div>

                <div class="details-field">
                  <label class="details-label">Eircode</label>
                  <div class="details-value">{{or @project.eircode '—'}}</div>
                </div>

                <div class="details-field details-field-full">
                  <label class="details-label">Address</label>
                  <div class="details-value">{{or @project.address '—'}}</div>
                </div>
              </div>
            </div>

            <div class="details-section">
              <h3 class="details-section-title">Project Information</h3>

              <div class="details-grid">
                <div class="details-field">
                  <label class="details-label">Project ID</label>
                  <div class="details-value details-mono">{{@project.tpf_id}}</div>
                </div>

                <div class="details-field">
                  <label class="details-label">POD Model</label>
                  <div class="details-value">{{or @project.pod_model '—'}}</div>
                </div>

                <div class="details-field">
                  <label class="details-label">Status</label>
                  <div class="details-value">{{@project.status}}</div>
                </div>

                <div class="details-field">
                  <label class="details-label">Status Updated</label>
                  <div class="details-value">{{this.formatDate @project.status_updated_at}}</div>
                </div>

                <div class="details-field">
                  <label class="details-label">Created</label>
                  <div class="details-value">{{this.formatDate @project.created_at}}</div>
                </div>
              </div>
            </div>

            <div class="details-section">
              <h3 class="details-section-title">Internal Notes</h3>
              <p class="details-section-desc">These notes are visible to staff only and will not be shared with the client.</p>

              <form {{on "submit" this.handleSaveNotes}}>
                <textarea
                  class="form-textarea"
                  rows="6"
                  placeholder="Add internal notes about this project..."
                  value={{this.internalNotes}}
                  {{on "input" this.updateNotes}}
                ></textarea>

                <div style="margin-top: var(--space-4);">
                  <button
                    type="submit"
                    class="btn btn-primary"
                    disabled={{this.isSaving}}
                  >
                    {{#if this.isSaving}}
                      <div class="loading-spinner" style="width:14px;height:14px;border-width:2px;"></div>
                      Saving...
                    {{else}}
                      Save Notes
                    {{/if}}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}

function or(a, b) { return a || b; }
