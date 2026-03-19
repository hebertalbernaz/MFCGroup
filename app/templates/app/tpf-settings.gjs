import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

class TpfSettingsPage extends Component {
  @service supabase;
  @service toast;
  @service auth;

  @tracked nextPodNumber = 1000;
  @tracked slaNewEnquiry = 2;
  @tracked slaInDesign = 7;
  @tracked slaAwaitingQuote = 3;
  @tracked slaRevisions = 5;
  @tracked isLoading = true;
  @tracked isSaving = false;

  constructor() {
    super(...arguments);
    this.loadSettings();
  }

  async loadSettings() {
    try {
      const { data, error } = await this.supabase.client
        .from('app_settings')
        .select('key, value')
        .in('key', ['next_pod_number', 'sla_new_enquiry', 'sla_in_design', 'sla_awaiting_quote', 'sla_revisions']);

      if (error) throw error;

      data.forEach(item => {
        if (item.key === 'next_pod_number') {
          this.nextPodNumber = parseInt(item.value || '1000', 10);
        } else if (item.key === 'sla_new_enquiry') {
          this.slaNewEnquiry = parseInt(item.value || '2', 10);
        } else if (item.key === 'sla_in_design') {
          this.slaInDesign = parseInt(item.value || '7', 10);
        } else if (item.key === 'sla_awaiting_quote') {
          this.slaAwaitingQuote = parseInt(item.value || '3', 10);
        } else if (item.key === 'sla_revisions') {
          this.slaRevisions = parseInt(item.value || '5', 10);
        }
      });
    } catch (error) {
      console.error('Error loading settings:', error);
      this.toast.error('Failed to load settings');
    } finally {
      this.isLoading = false;
    }
  }

  updateNextPodNumber = (e) => {
    const value = parseInt(e.target.value, 10);
    if (!isNaN(value) && value > 0) {
      this.nextPodNumber = value;
    }
  };

  updateSlaNewEnquiry = (e) => {
    const value = parseInt(e.target.value, 10);
    if (!isNaN(value) && value > 0) {
      this.slaNewEnquiry = value;
    }
  };

  updateSlaInDesign = (e) => {
    const value = parseInt(e.target.value, 10);
    if (!isNaN(value) && value > 0) {
      this.slaInDesign = value;
    }
  };

  updateSlaAwaitingQuote = (e) => {
    const value = parseInt(e.target.value, 10);
    if (!isNaN(value) && value > 0) {
      this.slaAwaitingQuote = value;
    }
  };

  updateSlaRevisions = (e) => {
    const value = parseInt(e.target.value, 10);
    if (!isNaN(value) && value > 0) {
      this.slaRevisions = value;
    }
  };

  handleSave = async (e) => {
    e.preventDefault();
    if (this.isSaving) return;

    this.isSaving = true;

    try {
      const updates = [
        { key: 'next_pod_number', value: String(this.nextPodNumber) },
        { key: 'sla_new_enquiry', value: String(this.slaNewEnquiry) },
        { key: 'sla_in_design', value: String(this.slaInDesign) },
        { key: 'sla_awaiting_quote', value: String(this.slaAwaitingQuote) },
        { key: 'sla_revisions', value: String(this.slaRevisions) }
      ];

      for (const update of updates) {
        const { error } = await this.supabase.client
          .from('app_settings')
          .update({ value: update.value })
          .eq('key', update.key);

        if (error) throw error;
      }

      this.toast.success('Settings saved successfully');
    } catch (error) {
      console.error('Error saving settings:', error);
      this.toast.error('Failed to save settings');
    } finally {
      this.isSaving = false;
    }
  };

  get nextProjectId() {
    return `POD-${this.nextPodNumber}`;
  }

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Settings</h1>
        <p class="page-subtitle">Configure The Pod Factory system settings</p>
      </div>
    </div>

    {{#if this.isLoading}}
      <div class="empty-state">
        <div class="loading-spinner" style="width:32px;height:32px;"></div>
      </div>
    {{else}}
      <div class="card" style="max-width: 600px;">
        <div class="card-header">
          <span class="card-title">Project ID Counter</span>
        </div>
        <div class="card-body">
          <p style="font-size: var(--text-sm); color: var(--text-secondary); margin-bottom: var(--space-6); line-height: 1.6;">
            This setting controls the sequential numbering for new projects. The next project created will use ID <strong>{{this.nextProjectId}}</strong>.
          </p>

          <form {{on "submit" this.handleSave}}>
            <div class="form-group">
              <label class="form-label form-label-required" for="next-pod-number">
                Next POD Number
              </label>
              <input
                id="next-pod-number"
                type="number"
                class="form-input"
                min="1"
                value={{this.nextPodNumber}}
                {{on "input" this.updateNextPodNumber}}
                required
              />
              <span class="form-hint">
                Next project ID will be: <strong>{{this.nextProjectId}}</strong>
              </span>
            </div>

            <button
              type="submit"
              class="btn btn-primary"
              disabled={{this.isSaving}}
            >
              {{#if this.isSaving}}
                <div class="loading-spinner" style="width:14px;height:14px;border-width:2px;"></div>
                Saving...
              {{else}}
                Save Settings
              {{/if}}
            </button>
          </form>
        </div>
      </div>

      <div class="card" style="max-width: 600px; margin-top: var(--space-4);">
        <div class="card-header">
          <span class="card-title">SLA Targets (Days)</span>
        </div>
        <div class="card-body">
          <p style="font-size: var(--text-sm); color: var(--text-secondary); margin-bottom: var(--space-6); line-height: 1.6;">
            Configure the maximum number of days allowed for each project status. Projects exceeding these targets will be flagged with a red SLA badge on the Design Desk.
          </p>

          <form {{on "submit" this.handleSave}}>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-4);">
              <div class="form-group">
                <label class="form-label form-label-required" for="sla-new-enquiry">
                  New Enquiry
                </label>
                <input
                  id="sla-new-enquiry"
                  type="number"
                  class="form-input"
                  min="1"
                  value={{this.slaNewEnquiry}}
                  {{on "input" this.updateSlaNewEnquiry}}
                  required
                />
                <span class="form-hint">Days allowed</span>
              </div>

              <div class="form-group">
                <label class="form-label form-label-required" for="sla-in-design">
                  In Design
                </label>
                <input
                  id="sla-in-design"
                  type="number"
                  class="form-input"
                  min="1"
                  value={{this.slaInDesign}}
                  {{on "input" this.updateSlaInDesign}}
                  required
                />
                <span class="form-hint">Days allowed</span>
              </div>

              <div class="form-group">
                <label class="form-label form-label-required" for="sla-awaiting-quote">
                  Awaiting Quote
                </label>
                <input
                  id="sla-awaiting-quote"
                  type="number"
                  class="form-input"
                  min="1"
                  value={{this.slaAwaitingQuote}}
                  {{on "input" this.updateSlaAwaitingQuote}}
                  required
                />
                <span class="form-hint">Days allowed</span>
              </div>

              <div class="form-group">
                <label class="form-label form-label-required" for="sla-revisions">
                  Revisions
                </label>
                <input
                  id="sla-revisions"
                  type="number"
                  class="form-input"
                  min="1"
                  value={{this.slaRevisions}}
                  {{on "input" this.updateSlaRevisions}}
                  required
                />
                <span class="form-hint">Days allowed</span>
              </div>
            </div>

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
                  Save All Settings
                {{/if}}
              </button>
            </div>
          </form>
        </div>
      </div>

      <div class="card" style="max-width: 600px; margin-top: var(--space-4);">
        <div class="card-header">
          <span class="card-title">About TPF System</span>
        </div>
        <div class="card-body">
          <div style="display: flex; flex-direction: column; gap: var(--space-3);">
            <div style="display: flex; justify-content: space-between; padding: var(--space-2) 0; border-bottom: 1px solid var(--border-default);">
              <span style="font-size: var(--text-sm); color: var(--text-secondary);">Application</span>
              <span style="font-size: var(--text-sm); font-weight: 500; color: var(--text-primary);">The Pod Factory ERP</span>
            </div>
            <div style="display: flex; justify-content: space-between; padding: var(--space-2) 0; border-bottom: 1px solid var(--border-default);">
              <span style="font-size: var(--text-sm); color: var(--text-secondary);">Version</span>
              <span style="font-size: var(--text-sm); font-weight: 500; color: var(--text-primary);">Phase 1 — v1.0.0</span>
            </div>
            <div style="display: flex; justify-content: space-between; padding: var(--space-2) 0; border-bottom: 1px solid var(--border-default);">
              <span style="font-size: var(--text-sm); color: var(--text-secondary);">Region</span>
              <span style="font-size: var(--text-sm); font-weight: 500; color: var(--text-primary);">Ireland (en-IE)</span>
            </div>
            <div style="display: flex; justify-content: space-between; padding: var(--space-2) 0; border-bottom: 1px solid var(--border-default);">
              <span style="font-size: var(--text-sm); color: var(--text-secondary);">Database</span>
              <span style="font-size: var(--text-sm); font-weight: 500; color: var(--text-primary);">Supabase (PostgreSQL)</span>
            </div>
            <div style="display: flex; justify-content: space-between; padding: var(--space-2) 0;">
              <span style="font-size: var(--text-sm); color: var(--text-secondary);">Currency</span>
              <span style="font-size: var(--text-sm); font-weight: 500; color: var(--text-primary);">Euro (€)</span>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}

export default <template>
  <TpfSettingsPage />
</template>
