import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { generateProjectFolders } from '../utils/generate-project-folders';

export default class NewEnquiryModal extends Component {
  @service projects;
  @service appSettings;
  @service toast;

  @tracked clientName = '';
  @tracked phone = '';
  @tracked email = '';
  @tracked eircode = '';
  @tracked productType = 'MFC';
  @tracked isSubmitting = false;
  @tracked errors = {};

  validate() {
    const errs = {};
    if (!this.clientName.trim()) errs.clientName = 'Client name is required.';
    if (!this.phone.trim()) errs.phone = 'Phone number is required.';
    if (!this.email.trim()) errs.email = 'Email address is required.';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.email)) errs.email = 'Please enter a valid email address.';
    if (!this.eircode.trim()) errs.eircode = 'Eircode is required.';
    this.errors = errs;
    return Object.keys(errs).length === 0;
  }

  updateClientName = (e) => { this.clientName = e.target.value; };
  updatePhone = (e) => { this.phone = e.target.value; };
  updateEmail = (e) => { this.email = e.target.value; };
  updateEircode = (e) => { this.eircode = e.target.value.toUpperCase(); };
  updateProductType = (e) => { this.productType = e.target.value; };

  get isMFC() { return this.productType === 'MFC'; }
  get isPOD() { return this.productType === 'POD'; }

  get folderConfigured() {
    return this.appSettings.isConfigured;
  }

  handleSubmit = async (e) => {
    e.preventDefault();
    if (!this.validate()) return;
    this.isSubmitting = true;
    try {
      const project = await this.projects.createProject({
        clientName: this.clientName.trim(),
        phone: this.phone.trim(),
        email: this.email.trim(),
        eircode: this.eircode.trim(),
        productType: this.productType,
      });

      this.args.onClose();

      this.toast.success(`Enquiry ${project.project_id} created`, {
        detail: `${project.client_name} · ${project.eircode}`,
        duration: 4000,
      });

      if (this.appSettings.isConfigured) {
        const result = await generateProjectFolders({
          templatePath: this.appSettings.templatePathFor(project.product_type),
          destinationPath: this.appSettings.destinationPathFor(project.product_type),
          projectId: project.project_id,
          clientName: project.client_name,
        });

        this.toast.success(result.message, {
          detail: result.rootFolder,
          duration: 7000,
        });
      } else {
        this.toast.info('Folder paths not configured — skipping folder creation', {
          detail: 'Go to Settings to configure template and destination paths.',
          duration: 6000,
        });
      }
    } catch {
      // error shown via projects service
    } finally {
      this.isSubmitting = false;
    }
  };

  handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) {
      this.args.onClose();
    }
  };

  <template>
    <div class="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="modal-title" {{on "click" this.handleOverlayClick}}>
      <div class="modal">
        <div class="modal-header">
          <h2 class="modal-title" id="modal-title">New Enquiry</h2>
          <button class="btn btn-ghost btn-icon" type="button" {{on "click" @onClose}} aria-label="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <form {{on "submit" this.handleSubmit}}>
          <div class="modal-body">
            {{#if this.projects.error}}
              <div class="alert alert-error mb-4">{{this.projects.error}}</div>
            {{/if}}

            {{#unless this.folderConfigured}}
              <div class="alert" style="background-color: rgba(234,179,8,0.08); border-color: rgba(234,179,8,0.3); color: #ca8a04; margin-bottom: var(--space-4);">
                <strong>Folder paths not configured.</strong> Server folders will not be created. Configure them in Settings.
              </div>
            {{/unless}}

            <div class="form-group">
              <label class="form-label form-label-required" for="client-name">Client Name</label>
              <input
                id="client-name"
                type="text"
                class="form-input"
                placeholder="e.g. Aoife Murphy"
                value={{this.clientName}}
                {{on "input" this.updateClientName}}
                autocomplete="name"
              />
              {{#if this.errors.clientName}}
                <span class="form-error">{{this.errors.clientName}}</span>
              {{/if}}
            </div>

            <div class="form-group">
              <label class="form-label form-label-required" for="phone">Phone Number</label>
              <input
                id="phone"
                type="tel"
                class="form-input"
                placeholder="e.g. 087 123 4567"
                value={{this.phone}}
                {{on "input" this.updatePhone}}
                autocomplete="tel"
              />
              {{#if this.errors.phone}}
                <span class="form-error">{{this.errors.phone}}</span>
              {{/if}}
            </div>

            <div class="form-group">
              <label class="form-label form-label-required" for="email">Email Address</label>
              <input
                id="email"
                type="email"
                class="form-input"
                placeholder="e.g. aoife@example.ie"
                value={{this.email}}
                {{on "input" this.updateEmail}}
                autocomplete="email"
              />
              {{#if this.errors.email}}
                <span class="form-error">{{this.errors.email}}</span>
              {{/if}}
            </div>

            <div class="form-group">
              <label class="form-label form-label-required" for="eircode">Eircode</label>
              <input
                id="eircode"
                type="text"
                class="form-input"
                placeholder="e.g. D01 AB23"
                value={{this.eircode}}
                {{on "input" this.updateEircode}}
                maxlength="8"
              />
              {{#if this.errors.eircode}}
                <span class="form-error">{{this.errors.eircode}}</span>
              {{else}}
                <span class="form-hint">Irish postal code (e.g. D01 AB23)</span>
              {{/if}}
            </div>

            <div class="form-group">
              <label class="form-label form-label-required" for="product-type">Product Type</label>
              <select
                id="product-type"
                class="form-select"
                {{on "change" this.updateProductType}}
              >
                <option value="MFC" selected={{this.isMFC}}>MFC — Modular Frame Construction</option>
                <option value="POD" selected={{this.isPOD}}>POD — Pre-built Off-site Design</option>
              </select>
            </div>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" {{on "click" @onClose}}>
              Cancel
            </button>
            <button type="submit" class="btn btn-primary" disabled={{this.isSubmitting}}>
              {{#if this.isSubmitting}}
                <div class="loading-spinner" style="width:14px;height:14px;border-width:2px;"></div>
                Saving...
              {{else}}
                Create Enquiry
              {{/if}}
            </button>
          </div>
        </form>
      </div>
    </div>
  </template>
}
