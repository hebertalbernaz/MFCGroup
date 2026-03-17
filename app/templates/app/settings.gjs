import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import CatalogSection from 'my-app/components/catalog-section';
import { ROLE_OPTIONS } from 'my-app/services/auth';

function eq(a, b) { return a === b; }
function or(a, b) { return Boolean(a) || Boolean(b); }

class MyProfileTab extends Component {
  @service auth;
  @service toast;

  @tracked newPassword = '';
  @tracked confirmPassword = '';
  @tracked pwError = '';
  @tracked pwSuccess = false;

  updateNewPassword = (e) => { this.newPassword = e.target.value; };
  updateConfirmPassword = (e) => { this.confirmPassword = e.target.value; };

  get roleLabel() {
    const found = ROLE_OPTIONS.find((r) => r.value === this.auth.role);
    return found ? found.label : this.auth.role;
  }

  get roleBadgeClass() {
    const role = this.auth.role;
    if (role === 'admin') return 'settings-role-badge settings-role-admin';
    if (role === 'estimator') return 'settings-role-badge settings-role-estimator';
    return 'settings-role-badge settings-role-designer';
  }

  handleChangePassword = (e) => {
    e.preventDefault();
    this.pwError = '';
    this.pwSuccess = false;
    if (!this.newPassword.trim()) {
      this.pwError = 'New password cannot be empty.';
      return;
    }
    if (this.newPassword !== this.confirmPassword) {
      this.pwError = 'Passwords do not match.';
      return;
    }
    const result = this.auth.changeOwnPassword(this.newPassword);
    if (result.success) {
      this.newPassword = '';
      this.confirmPassword = '';
      this.pwSuccess = true;
      this.toast.success('Password changed', { duration: 3000 });
      setTimeout(() => { this.pwSuccess = false; }, 4000);
    } else {
      this.pwError = result.error;
    }
  };

  <template>
    <div class="settings-section">
      <h2 class="settings-section-title">My Profile</h2>

      <div class="settings-profile-card">
        <div class="settings-profile-avatar">{{this.auth.currentUser.initials}}</div>
        <div class="settings-profile-info">
          <div class="settings-profile-name">{{this.auth.currentUser.displayName}}</div>
          <div class="settings-profile-username">@{{this.auth.currentUser.username}}</div>
          <div class={{this.roleBadgeClass}}>{{this.roleLabel}}</div>
        </div>
      </div>
    </div>

    <div class="settings-section">
      <h2 class="settings-section-title">Change Password</h2>

      <form {{on "submit" this.handleChangePassword}} style="max-width: 400px;">
        {{#if this.pwError}}
          <div class="settings-pw-error">{{this.pwError}}</div>
        {{/if}}
        {{#if this.pwSuccess}}
          <div class="settings-pw-success">Password changed successfully.</div>
        {{/if}}

        <div class="form-group">
          <label class="form-label" for="new-password">New Password</label>
          <input
            id="new-password"
            type="password"
            class="form-input"
            placeholder="Enter new password"
            value={{this.newPassword}}
            {{on "input" this.updateNewPassword}}
          />
        </div>

        <div class="form-group">
          <label class="form-label" for="confirm-password">Confirm Password</label>
          <input
            id="confirm-password"
            type="password"
            class="form-input"
            placeholder="Confirm new password"
            value={{this.confirmPassword}}
            {{on "input" this.updateConfirmPassword}}
          />
        </div>

        <button type="submit" class="btn btn-primary">Update Password</button>
      </form>
    </div>
  </template>
}

class UserManagementTab extends Component {
  @service auth;
  @service toast;

  @tracked newUsername = '';
  @tracked newPassword = '';
  @tracked newRole = 'designer';
  @tracked addError = '';
  @tracked resetTarget = null;
  @tracked resetValue = '';
  @tracked resetError = '';
  @tracked deleteConfirm = null;

  updateNewUsername = (e) => { this.newUsername = e.target.value; };
  updateNewPassword = (e) => { this.newPassword = e.target.value; };
  updateNewRole = (e) => { this.newRole = e.target.value; };
  updateResetValue = (e) => { this.resetValue = e.target.value; };

  handleAddUser = (e) => {
    e.preventDefault();
    this.addError = '';
    const result = this.auth.adminAddUser(this.newUsername, this.newPassword, this.newRole);
    if (result.success) {
      this.newUsername = '';
      this.newPassword = '';
      this.newRole = 'designer';
      this.toast.success('User added', { duration: 3000 });
    } else {
      this.addError = result.error;
    }
  };

  openReset = (userId) => {
    this.resetTarget = userId;
    this.resetValue = '';
    this.resetError = '';
  };

  cancelReset = () => {
    this.resetTarget = null;
    this.resetValue = '';
    this.resetError = '';
  };

  handleResetPassword = (e) => {
    e.preventDefault();
    this.resetError = '';
    const result = this.auth.adminResetUserPassword(this.resetTarget, this.resetValue);
    if (result.success) {
      this.resetTarget = null;
      this.resetValue = '';
      this.toast.success('Password reset', { duration: 3000 });
    } else {
      this.resetError = result.error;
    }
  };

  confirmDelete = (userId) => {
    this.deleteConfirm = userId;
  };

  cancelDelete = () => {
    this.deleteConfirm = null;
  };

  handleDelete = (userId) => {
    const result = this.auth.adminDeleteUser(userId);
    if (result.success) {
      this.deleteConfirm = null;
      this.toast.success('User removed', { duration: 3000 });
    } else {
      this.toast.error(result.error, { duration: 4000 });
      this.deleteConfirm = null;
    }
  };

  roleBadge = (role) => {
    if (role === 'admin') return 'user-role-tag user-role-admin';
    if (role === 'estimator') return 'user-role-tag user-role-estimator';
    return 'user-role-tag user-role-designer';
  };

  roleLabel = (role) => {
    const found = ROLE_OPTIONS.find((r) => r.value === role);
    return found ? found.label : role;
  };

  get roleOptions() { return ROLE_OPTIONS; }

  <template>
    <div class="settings-section">
      <h2 class="settings-section-title">All Users</h2>

      <div class="um-table-wrap">
        <table class="um-table">
          <thead>
            <tr>
              <th>Username</th>
              <th>Display Name</th>
              <th>Role</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {{#each this.auth.users as |user|}}
              <tr>
                <td>
                  <div class="um-user-cell">
                    <div class="um-avatar">{{user.initials}}</div>
                    <span>@{{user.username}}</span>
                  </div>
                </td>
                <td>{{user.displayName}}</td>
                <td><span class={{this.roleBadge user.role}}>{{this.roleLabel user.role}}</span></td>
                <td>
                  <div class="um-actions">
                    {{#if (eq this.resetTarget user.id)}}
                      <form {{on "submit" this.handleResetPassword}} class="um-reset-form">
                        {{#if this.resetError}}
                          <span class="um-reset-error">{{this.resetError}}</span>
                        {{/if}}
                        <input
                          type="password"
                          class="form-input um-reset-input"
                          placeholder="New password"
                          value={{this.resetValue}}
                          {{on "input" this.updateResetValue}}
                        />
                        <button type="submit" class="btn btn-primary btn-sm">Save</button>
                        <button type="button" class="btn btn-ghost btn-sm" {{on "click" this.cancelReset}}>Cancel</button>
                      </form>
                    {{else if (eq this.deleteConfirm user.id)}}
                      <div class="um-confirm-delete">
                        <span class="um-confirm-text">Delete this user?</span>
                        <button type="button" class="btn btn-danger btn-sm" {{on "click" (fn this.handleDelete user.id)}}>Confirm</button>
                        <button type="button" class="btn btn-ghost btn-sm" {{on "click" this.cancelDelete}}>Cancel</button>
                      </div>
                    {{else}}
                      <button type="button" class="btn btn-ghost btn-sm" {{on "click" (fn this.openReset user.id)}}>Reset Password</button>
                      {{#unless (eq user.id this.auth.currentUser.id)}}
                        <button type="button" class="btn btn-ghost btn-sm um-delete-btn" {{on "click" (fn this.confirmDelete user.id)}}>Delete</button>
                      {{/unless}}
                    {{/if}}
                  </div>
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
    </div>

    <div class="settings-section">
      <h2 class="settings-section-title">Add New User</h2>

      <form {{on "submit" this.handleAddUser}} style="max-width: 480px;">
        {{#if this.addError}}
          <div class="settings-pw-error">{{this.addError}}</div>
        {{/if}}

        <div class="form-group">
          <label class="form-label form-label-required" for="add-username">Username</label>
          <input
            id="add-username"
            type="text"
            class="form-input"
            placeholder="e.g. mary_des"
            value={{this.newUsername}}
            {{on "input" this.updateNewUsername}}
          />
          <span class="form-hint">Use lowercase with underscores. Display name will be generated automatically.</span>
        </div>

        <div class="form-group">
          <label class="form-label form-label-required" for="add-user-password">Password</label>
          <input
            id="add-user-password"
            type="password"
            class="form-input"
            placeholder="Initial password"
            value={{this.newPassword}}
            {{on "input" this.updateNewPassword}}
          />
        </div>

        <div class="form-group">
          <label class="form-label" for="add-user-role">Role</label>
          <select id="add-user-role" class="form-input" {{on "change" this.updateNewRole}}>
            {{#each this.roleOptions as |opt|}}
              <option value={{opt.value}} selected={{eq this.newRole opt.value}}>{{opt.label}}</option>
            {{/each}}
          </select>
        </div>

        <button type="submit" class="btn btn-primary">Add User</button>
      </form>
    </div>
  </template>
}

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

  get mfcIdPreview() { return `MFC ${this.nextMfcNumber}`; }
  get podIdPreview() { return `PD${this.nextPdNumber}`; }
  get podProjectIdPreview() { return `POD-${this.nextPodProjectNumber}`; }

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
      this.toast.success('Settings saved', { detail: 'Folder paths and ID counters updated.', duration: 4000 });
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
              <input id="next-mfc-number" type="number" class="form-input" min="1" value={{this.nextMfcNumber}} {{on "input" this.updateNextMfcNumber}} />
              <span class="form-hint">Next ID: <strong>{{this.mfcIdPreview}}</strong></span>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="next-pd-number">Next POD Enquiry Number</label>
              <input id="next-pd-number" type="number" class="form-input" min="1" value={{this.nextPdNumber}} {{on "input" this.updateNextPdNumber}} />
              <span class="form-hint">Next ID: <strong>{{this.podIdPreview}}</strong></span>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="next-pod-project-number">Next POD Project Number</label>
              <input id="next-pod-project-number" type="number" class="form-input" min="1" value={{this.nextPodProjectNumber}} {{on "input" this.updateNextPodProjectNumber}} />
              <span class="form-hint">Next ID: <strong>{{this.podProjectIdPreview}}</strong></span>
            </div>
          </div>
        </div>

        <div style="font-size: var(--text-sm); font-weight: 600; color: var(--text-primary); margin-bottom: var(--space-3);">Template Source Folders</div>

        <div class="form-group">
          <label class="form-label form-label-required" for="mfc-template">MFC Template Folder</label>
          <input id="mfc-template" type="text" class="form-input" placeholder="e.g. Z:/Templates/MFC-Template" value={{this.mfcTemplatePath}} {{on "input" this.updateMfcTemplatePath}} />
          <span class="form-hint">Path to the master MFC template folder on your server or network drive</span>
        </div>

        <div class="form-group">
          <label class="form-label form-label-required" for="pod-template">POD Template Folder</label>
          <input id="pod-template" type="text" class="form-input" placeholder="e.g. Z:/Templates/POD-Template" value={{this.podTemplatePath}} {{on "input" this.updatePodTemplatePath}} />
          <span class="form-hint">Path to the master POD template folder on your server or network drive</span>
        </div>

        <div style="font-size: var(--text-sm); font-weight: 600; color: var(--text-primary); margin-bottom: var(--space-3); margin-top: var(--space-2);">Destination Folders</div>

        <div class="form-group">
          <label class="form-label form-label-required" for="mfc-projects">MFC Projects Folder</label>
          <input id="mfc-projects" type="text" class="form-input" placeholder="e.g. Z:/Projects/MFC" value={{this.mfcProjectsPath}} {{on "input" this.updateMfcProjectsPath}} />
          <span class="form-hint">Where new MFC project folders are created (e.g. <em>MFC 2000 - Client Name</em>)</span>
        </div>

        <div class="form-group">
          <label class="form-label form-label-required" for="pod-enquiries">POD Enquiries Folder</label>
          <input id="pod-enquiries" type="text" class="form-input" placeholder="e.g. Z:/Projects/POD-Enquiries" value={{this.podEnquiriesPath}} {{on "input" this.updatePodEnquiriesPath}} />
          <span class="form-hint">Where new POD enquiry folders are created (e.g. <em>PD1000 - Client Name</em>)</span>
        </div>

        <div class="form-group">
          <label class="form-label form-label-required" for="pod-projects">POD Projects Folder</label>
          <input id="pod-projects" type="text" class="form-input" placeholder="e.g. Z:/Projects/POD-Projects" value={{this.podProjectsPath}} {{on "input" this.updatePodProjectsPath}} />
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

class SettingsPage extends Component {
  @service auth;

  @tracked activeTab = 'profile';

  get visibleTabs() {
    const role = this.auth.role;
    const tabs = [{ id: 'profile', label: 'My Profile' }];
    if (role === 'admin') tabs.push({ id: 'users', label: 'User Management' });
    if (role === 'admin' || role === 'estimator') tabs.push({ id: 'catalog', label: 'Pricing & Catalog' });
    if (role === 'admin' || role === 'designer') tabs.push({ id: 'system', label: 'System Paths & Counters' });
    return tabs;
  }

  setTab = (tabId) => {
    this.activeTab = tabId;
  };

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Settings</h1>
        <p class="page-subtitle">Application preferences, ID counters, and folder engine configuration</p>
      </div>
    </div>

    <div class="settings-tabs-bar">
      {{#each this.visibleTabs as |tab|}}
        <button
          type="button"
          class={{if (eq this.activeTab tab.id) "settings-tab settings-tab-active" "settings-tab"}}
          {{on "click" (fn this.setTab tab.id)}}
        >
          {{tab.label}}
        </button>
      {{/each}}
    </div>

    <div style="max-width: 720px;">
      {{#if (eq this.activeTab "profile")}}
        <MyProfileTab />
      {{/if}}

      {{#if (eq this.activeTab "users")}}
        {{#if this.auth.isAdmin}}
          <UserManagementTab />
        {{/if}}
      {{/if}}

      {{#if (eq this.activeTab "catalog")}}
        {{#if (or this.auth.isAdmin this.auth.isEstimator)}}
          <CatalogSection />
        {{/if}}
      {{/if}}

      {{#if (eq this.activeTab "system")}}
        {{#if (or this.auth.isAdmin this.auth.isDesigner)}}
          <FolderPathSection />
          <AppearanceSection />
          <SlaSection />
          <AboutSection />
        {{/if}}
      {{/if}}
    </div>
  </template>
}

export default <template>
  <SettingsPage />
</template>
