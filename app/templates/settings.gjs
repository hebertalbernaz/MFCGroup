import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

class FolderPathSection extends Component {
  @service appSettings;
  @service toast;

  @tracked mfcTemplatePath = '';
  @tracked podTemplatePath = '';
  @tracked mfcProjectsPath = '';
  @tracked podEnquiriesPath = '';
  @tracked podProjectsPath = '';
  @tracked nextMfcNumber = 2000;
  @tracked nextPdNumber = 1000;
  @tracked nextPodProjectNumber = 42;
  @tracked isSaved = false;

  constructor() {
    super(...arguments);
    this.mfcTemplatePath = this.appSettings.mfcTemplatePath;
    this.podTemplatePath = this.appSettings.podTemplatePath;
    this.mfcProjectsPath = this.appSettings.mfcProjectsPath;
    this.podEnquiriesPath = this.appSettings.podEnquiriesPath;
    this.podProjectsPath = this.appSettings.podProjectsPath;
    this.nextMfcNumber = this.appSettings.nextMfcNumber;
    this.nextPdNumber = this.appSettings.nextPdNumber;
    this.nextPodProjectNumber = this.appSettings.nextPodProjectNumber;
  }

  get configStatusClass() {
    return this.appSettings.isConfigured ? 'config-status config-status-ok' : 'config-status config-status-warn';
  }

  get configStatusLabel() {
    return this.appSettings.isConfigured ? 'Configured' : 'Not Configured';
  }

  get configStatusDot() {
    return this.appSettings.isConfigured ? 'sla-dot sla-dot-green' : 'sla-dot sla-dot-yellow';
  }

  get mfcIdPreview() {
    return `MFC ${this.nextMfcNumber}`;
  }

  get podIdPreview() {
    return `PD${this.nextPdNumber}`;
  }

  get podProjectIdPreview() {
    return `POD-${this.nextPodProjectNumber}`;
  }

  updateMfcTemplatePath = (e) => { this.mfcTemplatePath = e.target.value; };
  updatePodTemplatePath = (e) => { this.podTemplatePath = e.target.value; };
  updateMfcProjectsPath = (e) => { this.mfcProjectsPath = e.target.value; };
  updatePodEnquiriesPath = (e) => { this.podEnquiriesPath = e.target.value; };
  updatePodProjectsPath = (e) => { this.podProjectsPath = e.target.value; };
  updateNextMfcNumber = (e) => { this.nextMfcNumber = parseInt(e.target.value, 10) || 2000; };
  updateNextPdNumber = (e) => { this.nextPdNumber = parseInt(e.target.value, 10) || 1000; };
  updateNextPodProjectNumber = (e) => { this.nextPodProjectNumber = parseInt(e.target.value, 10) || 42; };

  handleSave = async (e) => {
    e.preventDefault();
    try {
      await this.appSettings.save({
        mfcTemplatePath: this.mfcTemplatePath,
        podTemplatePath: this.podTemplatePath,
        mfcProjectsPath: this.mfcProjectsPath,
        podEnquiriesPath: this.podEnquiriesPath,
        podProjectsPath: this.podProjectsPath,
        nextMfcNumber: this.nextMfcNumber,
        nextPdNumber: this.nextPdNumber,
        nextPodProjectNumber: this.nextPodProjectNumber,
      });
      this.isSaved = true;
      this.toast.success('Settings saved', {
        detail: 'Folder paths and ID counters updated.',
        duration: 4000,
      });
      setTimeout(() => { this.isSaved = false; }, 3000);
    } catch {
      this.toast.error('Failed to save settings', { duration: 5000 });
    }
  };

  <template>
    <div class="settings-section">
      <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: var(--space-4); padding-bottom: var(--space-3); border-bottom: 1px solid var(--border-default);">
        <h2 class="settings-section-title" style="margin: 0; border: none; padding: 0;">Folder Template Engine</h2>
        <div class={{this.configStatusClass}}>
          <div class={{this.configStatusDot}}></div>
          {{this.configStatusLabel}}
        </div>
      </div>

      <p style="font-size: var(--text-sm); color: var(--text-secondary); margin-bottom: var(--space-6); line-height: 1.6;">
        Configure source templates, destination paths, and sequential ID counters. MFC projects are copied to the
        MFC Projects folder. New POD enquiries go to the POD Enquiries folder. When a POD is signed or approved,
        the system copies it from the enquiries folder to the POD Projects folder.
      </p>

      <form {{on "submit" this.handleSave}}>

        <div style="margin-bottom: var(--space-6); padding: var(--space-4); background-color: var(--bg-surface-raised); border: 1px solid var(--border-default); border-radius: var(--radius-lg);">
          <div style="font-size: var(--text-sm); font-weight: 600; color: var(--text-primary); margin-bottom: var(--space-4);">Sequential ID Counters</div>
          <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: var(--space-4);">
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="next-mfc-number">Next MFC Number</label>
              <input
                id="next-mfc-number"
                type="number"
                class="form-input"
                min="1"
                value={{this.nextMfcNumber}}
                {{on "input" this.updateNextMfcNumber}}
              />
              <span class="form-hint">Next ID: <strong>{{this.mfcIdPreview}}</strong></span>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="next-pd-number">Next POD Enquiry Number</label>
              <input
                id="next-pd-number"
                type="number"
                class="form-input"
                min="1"
                value={{this.nextPdNumber}}
                {{on "input" this.updateNextPdNumber}}
              />
              <span class="form-hint">Next ID: <strong>{{this.podIdPreview}}</strong></span>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="next-pod-project-number">Next POD Project Number</label>
              <input
                id="next-pod-project-number"
                type="number"
                class="form-input"
                min="1"
                value={{this.nextPodProjectNumber}}
                {{on "input" this.updateNextPodProjectNumber}}
              />
              <span class="form-hint">Next ID: <strong>{{this.podProjectIdPreview}}</strong></span>
            </div>
          </div>
        </div>

        <div style="font-size: var(--text-sm); font-weight: 600; color: var(--text-primary); margin-bottom: var(--space-3);">Template Source Folders</div>

        <div class="form-group">
          <label class="form-label form-label-required" for="mfc-template">MFC Template Folder</label>
          <input
            id="mfc-template"
            type="text"
            class="form-input"
            placeholder="e.g. Z:/Templates/MFC-Template or /Volumes/Server/Templates/MFC"
            value={{this.mfcTemplatePath}}
            {{on "input" this.updateMfcTemplatePath}}
          />
          <span class="form-hint">Path to the master MFC template folder on your server or network drive</span>
        </div>

        <div class="form-group">
          <label class="form-label form-label-required" for="pod-template">POD Template Folder</label>
          <input
            id="pod-template"
            type="text"
            class="form-input"
            placeholder="e.g. Z:/Templates/POD-Template or /Volumes/Server/Templates/POD"
            value={{this.podTemplatePath}}
            {{on "input" this.updatePodTemplatePath}}
          />
          <span class="form-hint">Path to the master POD template folder on your server or network drive</span>
        </div>

        <div style="font-size: var(--text-sm); font-weight: 600; color: var(--text-primary); margin-bottom: var(--space-3); margin-top: var(--space-2);">Destination Folders</div>

        <div class="form-group">
          <label class="form-label form-label-required" for="mfc-projects">MFC Projects Folder</label>
          <input
            id="mfc-projects"
            type="text"
            class="form-input"
            placeholder="e.g. Z:/Projects/MFC or /Volumes/Server/MFC-Projects"
            value={{this.mfcProjectsPath}}
            {{on "input" this.updateMfcProjectsPath}}
          />
          <span class="form-hint">Where new MFC project folders are created (e.g. <em>MFC 2000 - Client Name</em>)</span>
        </div>

        <div class="form-group">
          <label class="form-label form-label-required" for="pod-enquiries">POD Enquiries Folder</label>
          <input
            id="pod-enquiries"
            type="text"
            class="form-input"
            placeholder="e.g. Z:/Projects/POD-Enquiries or /Volumes/Server/POD-Enquiries"
            value={{this.podEnquiriesPath}}
            {{on "input" this.updatePodEnquiriesPath}}
          />
          <span class="form-hint">Where new POD enquiry folders are created (e.g. <em>PD1000 - Client Name</em>)</span>
        </div>

        <div class="form-group">
          <label class="form-label form-label-required" for="pod-projects">POD Projects Folder</label>
          <input
            id="pod-projects"
            type="text"
            class="form-input"
            placeholder="e.g. Z:/Projects/POD-Projects or /Volumes/Server/POD-Projects"
            value={{this.podProjectsPath}}
            {{on "input" this.updatePodProjectsPath}}
          />
          <span class="form-hint">Where POD folders are copied when a project is Signed or Approved (e.g. <em>POD-1000 - Client Name</em>)</span>
        </div>

        {{#if this.appSettings.error}}
          <div class="alert alert-error mb-4">{{this.appSettings.error}}</div>
        {{/if}}

        <div style="display: flex; align-items: center; gap: var(--space-3);">
          <button type="submit" class="btn btn-primary" disabled={{this.appSettings.isSaving}}>
            {{#if this.appSettings.isSaving}}
              <div class="loading-spinner" style="width:14px;height:14px;border-width:2px;"></div>
              Saving...
            {{else}}
              Save Settings
            {{/if}}
          </button>
          {{#if this.isSaved}}
            <span style="font-size: var(--text-sm); color: var(--color-success-500); display: flex; align-items: center; gap: var(--space-2);">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              Saved
            </span>
          {{/if}}
        </div>
      </form>
    </div>
  </template>
}

class AppearanceSection extends Component {
  @service theme;

  toggleTheme = () => { this.theme.toggle(); };

  <template>
    <div class="settings-section">
      <h2 class="settings-section-title">Appearance</h2>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label">Dark Mode</div>
          <div class="settings-row-desc">Switch between light and dark colour scheme</div>
        </div>
        <label class="toggle-switch" title="Toggle dark mode">
          <input type="checkbox" checked={{this.theme.isDark}} {{on "change" this.toggleTheme}} />
          <span class="toggle-slider"></span>
        </label>
      </div>
    </div>
  </template>
}

class SlaSection extends Component {
  <template>
    <div class="settings-section">
      <h2 class="settings-section-title">SLA Policy</h2>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label" style="display: flex; align-items: center; gap: var(--space-2);">
            <div class="sla-dot sla-dot-green"></div>On Track
          </div>
          <div class="settings-row-desc">Project created within the last 7 days</div>
        </div>
      </div>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label" style="display: flex; align-items: center; gap: var(--space-2);">
            <div class="sla-dot sla-dot-yellow"></div>Due Soon
          </div>
          <div class="settings-row-desc">Project open for 7–13 days</div>
        </div>
      </div>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label" style="display: flex; align-items: center; gap: var(--space-2);">
            <div class="sla-dot sla-dot-red"></div>Overdue
          </div>
          <div class="settings-row-desc">Project open for 14 or more days</div>
        </div>
      </div>
    </div>
  </template>
}

class AboutSection extends Component {
  <template>
    <div class="settings-section">
      <h2 class="settings-section-title">About</h2>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label">Application</div>
          <div class="settings-row-desc">MFC Group Design System</div>
        </div>
      </div>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label">Version</div>
          <div class="settings-row-desc">Phase 4 — v0.4.0</div>
        </div>
      </div>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label">Region</div>
          <div class="settings-row-desc">Ireland (en-IE)</div>
        </div>
      </div>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label">Database</div>
          <div class="settings-row-desc">Supabase (PostgreSQL)</div>
        </div>
      </div>
      <div class="settings-row">
        <div class="settings-row-info">
          <div class="settings-row-label">Folder Engine</div>
          <div class="settings-row-desc">Browser simulation — replace with Node.js fs-extra on export</div>
        </div>
      </div>
    </div>
  </template>
}

export default <template>
  <div class="page-header">
    <div>
      <h1 class="page-title">Settings</h1>
      <p class="page-subtitle">Application preferences, ID counters, and folder engine configuration</p>
    </div>
  </div>

  <div style="max-width: 720px;">
    <FolderPathSection />
    <AppearanceSection />
    <SlaSection />
    <AboutSection />
  </div>
</template>
