import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { STATUSES } from 'my-app/services/projects';
import { unitLabel } from 'my-app/services/catalog';

function eq(a, b) { return a === b; }
function or(a, b) { return Boolean(a) || Boolean(b); }

const STOCK_WARN_KEY = 'mfc_stock_warn_dismissed';

function isStockWarnDismissedToday() {
  try {
    const stored = localStorage.getItem(STOCK_WARN_KEY);
    if (!stored) return false;
    return stored === new Date().toISOString().slice(0, 10);
  } catch {
    return false;
  }
}

function dismissStockWarnToday() {
  try {
    localStorage.setItem(STOCK_WARN_KEY, new Date().toISOString().slice(0, 10));
  } catch {
    // ignore
  }
}

class StatusOption extends Component {
  get isSelected() { return this.args.value === this.args.current; }
  <template><option value={{@value}} selected={{this.isSelected}}>{{@label}}</option></template>
}

class CatalogOption extends Component {
  <template><option value={{@id}}>{{@name}} — {{@unitLabelStr}} @ €{{@baseCost}}</option></template>
}

export default class ProjectDetailPanel extends Component {
  @service projects;
  @service catalog;
  @service toast;
  @service auth;
  @service auditLog;

  @tracked activeTab = 'details';
  @tracked quoteMode = 'quick';
  @tracked notes = '';
  @tracked isSavingNotes = false;
  @tracked lastSyncedProjectId = null;
  @tracked isArchiving = false;
  @tracked showArchiveConfirm = false;

  @tracked floorArea = '0';
  @tracked wallArea = '0';
  @tracked ceilingArea = '0';
  @tracked markupPct = '20';
  @tracked contingencyPct = '5';
  @tracked vatPct = '13.5';
  @tracked isSavingQuote = false;
  @tracked selectedCatalogId = '';
  @tracked catalogSearch = '';

  @tracked stockWarnItem = null;
  @tracked stockWarnDismissToday = false;

  get project() { return this.args.project; }
  get isOpen() { return !!this.project; }
  get statuses() { return STATUSES; }

  get canArchive() {
    return this.auth.isAdmin || this.auth.isEstimator;
  }

  get isArchived() {
    return this.project?.status === 'archived';
  }

  get badgeClass() {
    return this.project?.product_type === 'MFC' ? 'badge badge-mfc' : 'badge badge-pod';
  }

  get slaStatus() {
    if (!this.project) return 'green';
    return this.projects.getSlaStatus(this.project);
  }

  get slaBadgeClass() { return `sla-badge sla-badge-${this.slaStatus}`; }
  get slaDotClass() { return `sla-dot sla-dot-${this.slaStatus}`; }
  get slaLabel() {
    return { green: 'On Track', yellow: 'Due Soon', red: 'Overdue' }[this.slaStatus];
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

  get lineItems() {
    return this.project?.quote_line_items || [];
  }

  get filteredCatalogItems() {
    const q = this.catalogSearch.trim().toLowerCase();
    if (!q) return this.catalog.items;
    return this.catalog.items.filter((i) => i.name.toLowerCase().includes(q));
  }

  get baseBuildItem() {
    return this.catalog.items.find((i) => i.name.toLowerCase().includes('base build'));
  }

  get grossBaseBudget() {
    const floor = parseFloat(this.floorArea) || 0;
    const costPerSqm = this.baseBuildItem ? parseFloat(this.baseBuildItem.base_cost) : 0;
    return floor * costPerSqm;
  }

  get lineItemsSubtotal() {
    return this.lineItems.reduce((sum, item) => sum + (parseFloat(item.line_total) || 0), 0);
  }

  get totalBeforeMarkup() {
    return this.grossBaseBudget + this.lineItemsSubtotal;
  }

  formatEur(val) {
    return `€${Number(val).toLocaleString('en-IE', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  }

  unitLabel = unitLabel;

  syncIfNeeded() {
    if (this.project && this.project.id !== this.lastSyncedProjectId) {
      this.notes = this.project.internal_notes || '';
      this.floorArea = String(this.project.floor_area_sqm ?? 0);
      this.wallArea = String(this.project.wall_area_sqm ?? 0);
      this.ceilingArea = String(this.project.ceiling_area_sqm ?? 0);
      this.markupPct = String(this.project.markup_percentage ?? 20);
      this.contingencyPct = String(this.project.contingency_percentage ?? 5);
      this.vatPct = String(this.project.vat_percentage ?? 13.5);
      this.lastSyncedProjectId = this.project.id;
      this.showArchiveConfirm = false;
      if (!this.catalog.items.length && !this.catalog.isLoading) {
        this.catalog.load();
      }
    }
  }

  setTab = (tab) => { this.activeTab = tab; };
  setQuoteMode = (mode) => { this.quoteMode = mode; };

  handleNotesInput = (e) => { this.notes = e.target.value; };
  handleStatusChange = async (e) => {
    await this.projects.updateProjectStatus(this.project.id, e.target.value);
  };

  saveNotes = async () => {
    if (this.isSavingNotes || !this.project) return;
    this.isSavingNotes = true;
    try {
      await this.projects.updateProjectNotes(this.project.id, this.notes);
      this.toast.success('Notes saved.', { duration: 3000 });
    } catch {
      this.toast.error('Failed to save notes.', { duration: 5000 });
    } finally {
      this.isSavingNotes = false;
    }
  };

  requestArchive = () => {
    this.showArchiveConfirm = true;
  };

  cancelArchive = () => {
    this.showArchiveConfirm = false;
  };

  confirmArchive = async () => {
    if (this.isArchiving || !this.project) return;
    this.isArchiving = true;
    this.showArchiveConfirm = false;
    try {
      await this.projects.updateProjectStatus(this.project.id, 'archived');
      this.auditLog.logAction(
        this.auth.currentUser,
        'PROJECT_ARCHIVED',
        `${this.project.project_id} — ${this.project.client_name}`
      );
      this.toast.success(`${this.project.project_id} archived.`, { duration: 3000 });
      this.args.onClose?.();
    } catch {
      this.toast.error('Failed to archive project.', { duration: 5000 });
    } finally {
      this.isArchiving = false;
    }
  };

  handleAreaInput = (field, e) => {
    if (field === 'floor') this.floorArea = e.target.value;
    else if (field === 'wall') this.wallArea = e.target.value;
    else if (field === 'ceiling') this.ceilingArea = e.target.value;
    else if (field === 'markup') this.markupPct = e.target.value;
    else if (field === 'contingency') this.contingencyPct = e.target.value;
    else if (field === 'vat') this.vatPct = e.target.value;
  };

  saveQuoteParams = async () => {
    if (this.isSavingQuote || !this.project) return;
    this.isSavingQuote = true;
    try {
      await this.projects.updateProjectQuote(this.project.id, {
        floor_area_sqm: parseFloat(this.floorArea) || 0,
        wall_area_sqm: parseFloat(this.wallArea) || 0,
        ceiling_area_sqm: parseFloat(this.ceilingArea) || 0,
        markup_percentage: parseFloat(this.markupPct) || 20,
        contingency_percentage: parseFloat(this.contingencyPct) || 5,
        vat_percentage: parseFloat(this.vatPct) || 13.5,
      });
      this.toast.success('Quote parameters saved.', { duration: 3000 });
    } catch {
      this.toast.error('Failed to save parameters.', { duration: 5000 });
    } finally {
      this.isSavingQuote = false;
    }
  };

  handleCatalogSelect = (e) => { this.selectedCatalogId = e.target.value; };
  handleCatalogSearch = (e) => {
    this.catalogSearch = e.target.value;
    this.selectedCatalogId = '';
  };

  addLineItem = async () => {
    if (!this.selectedCatalogId || !this.project) return;
    const item = this.catalog.getItemById(this.selectedCatalogId);
    if (!item) return;

    if (item.track_stock && item.stock <= 0 && !isStockWarnDismissedToday()) {
      this.stockWarnItem = item;
      this.stockWarnDismissToday = false;
      return;
    }

    await this._doAddLineItem(item);
  };

  _doAddLineItem = async (item) => {
    const newLineItem = {
      catalog_item_id: item.id,
      name: item.name,
      category: item.category,
      unit_type: item.unit_type,
      quantity: 1,
      unit_cost: parseFloat(item.base_cost),
      line_total: parseFloat(item.base_cost),
    };

    const updated = [...this.lineItems, newLineItem];
    try {
      await this.projects.updateProjectQuote(this.project.id, { quote_line_items: updated });
      this.selectedCatalogId = '';
      this.catalogSearch = '';
      this.toast.success(`"${item.name}" added to quote.`, { duration: 3000 });
    } catch {
      this.toast.error('Failed to add line item.', { duration: 5000 });
    }
  };

  confirmStockWarn = async () => {
    const item = this.stockWarnItem;
    if (this.stockWarnDismissToday) {
      dismissStockWarnToday();
    }
    this.stockWarnItem = null;
    if (item) await this._doAddLineItem(item);
  };

  cancelStockWarn = () => {
    this.stockWarnItem = null;
    this.stockWarnDismissToday = false;
  };

  toggleStockWarnDismiss = (e) => {
    this.stockWarnDismissToday = e.target.checked;
  };

  removeLineItem = async (index) => {
    if (!this.project) return;
    const updated = this.lineItems.filter((_, i) => i !== index);
    try {
      await this.projects.updateProjectQuote(this.project.id, { quote_line_items: updated });
    } catch {
      this.toast.error('Failed to remove line item.', { duration: 5000 });
    }
  };

  handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) this.args.onClose?.();
  };

  <template>
    {{#if this.isOpen}}
      {{(this.syncIfNeeded)}}

      {{!-- ── STOCK WARNING MODAL ── --}}
      {{#if this.stockWarnItem}}
        <div class="stock-warn-overlay" role="dialog" aria-modal="true">
          <div class="stock-warn-modal">
            <div class="stock-warn-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
            </div>
            <div class="stock-warn-title">Low Stock Warning</div>
            <div class="stock-warn-body">
              Please confirm quantification for <strong>{{this.stockWarnItem.name}}</strong>. Stock might be low — current level is {{this.stockWarnItem.stock}} unit(s).
            </div>
            <label class="stock-warn-dismiss">
              <input type="checkbox" checked={{this.stockWarnDismissToday}} {{on "change" this.toggleStockWarnDismiss}} />
              Do not show this warning again today
            </label>
            <div class="stock-warn-actions">
              <button type="button" class="btn btn-ghost" {{on "click" this.cancelStockWarn}}>Cancel</button>
              <button type="button" class="btn btn-primary" {{on "click" this.confirmStockWarn}}>Add Anyway</button>
            </div>
          </div>
        </div>
      {{/if}}

      {{!-- ── ARCHIVE CONFIRM MODAL ── --}}
      {{#if this.showArchiveConfirm}}
        <div class="stock-warn-overlay" role="dialog" aria-modal="true">
          <div class="stock-warn-modal">
            <div class="stock-warn-icon" style="color: var(--color-warning-500);">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="21 8 21 21 3 21 3 8"/>
                <rect x="1" y="3" width="22" height="5"/>
                <line x1="10" y1="12" x2="14" y2="12"/>
              </svg>
            </div>
            <div class="stock-warn-title">Archive Project?</div>
            <div class="stock-warn-body">
              <strong>{{this.project.project_id}} — {{this.project.client_name}}</strong> will be moved to the Archive. It can be un-archived from the Quoting Desk at any time.
            </div>
            <div class="stock-warn-actions">
              <button type="button" class="btn btn-ghost" {{on "click" this.cancelArchive}}>Cancel</button>
              <button type="button" class="btn btn-danger" disabled={{this.isArchiving}} {{on "click" this.confirmArchive}}>
                {{if this.isArchiving "Archiving..." "Archive Project"}}
              </button>
            </div>
          </div>
        </div>
      {{/if}}

      <div class="panel-overlay" role="dialog" aria-modal="true" {{on "click" this.handleOverlayClick}}>
        <div class="panel-slideover">

          <div class="panel-header">
            <div style="display: flex; align-items: center; gap: var(--space-3); flex-wrap: wrap;">
              <span class="panel-project-id">{{this.project.project_id}}</span>
              <span class={{this.badgeClass}}>{{this.project.product_type}}</span>
              {{#if this.isArchived}}
                <span class="sla-badge" style="background: var(--bg-surface-raised); color: var(--text-secondary); border: 1px solid var(--border-strong);">Archived</span>
              {{else}}
                <div class={{this.slaBadgeClass}}>
                  <div class={{this.slaDotClass}}></div>
                  {{this.slaLabel}}
                </div>
              {{/if}}
            </div>
            <div style="display: flex; align-items: center; gap: var(--space-2);">
              {{#if (and this.canArchive (not this.isArchived))}}
                <button
                  type="button"
                  class="btn btn-ghost btn-sm"
                  style="color: var(--text-secondary); font-size: var(--text-xs);"
                  {{on "click" this.requestArchive}}
                >
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="21 8 21 21 3 21 3 8"/>
                    <rect x="1" y="3" width="22" height="5"/>
                    <line x1="10" y1="12" x2="14" y2="12"/>
                  </svg>
                  Archive
                </button>
              {{/if}}
              <button type="button" class="btn btn-ghost btn-icon" {{on "click" @onClose}}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                </svg>
              </button>
            </div>
          </div>

          <div class="panel-tabs">
            <button
              type="button"
              class={{if (eq this.activeTab "details") "panel-tab panel-tab-active" "panel-tab"}}
              {{on "click" (fn this.setTab "details")}}
            >
              Details
            </button>
            <button
              type="button"
              class={{if (eq this.activeTab "quote") "panel-tab panel-tab-active" "panel-tab"}}
              {{on "click" (fn this.setTab "quote")}}
            >
              Quote Builder
            </button>
          </div>

          <div class="panel-body">

            {{!-- ── DETAILS TAB ── --}}
            {{#if (eq this.activeTab "details")}}
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

              {{#unless this.isArchived}}
                <div class="panel-section">
                  <label class="panel-section-title" for="panel-status-select">Pipeline Status</label>
                  <select id="panel-status-select" class="form-select" {{on "change" this.handleStatusChange}}>
                    {{#each this.statuses as |status|}}
                      <StatusOption @value={{status.key}} @label={{status.label}} @current={{this.project.status}} />
                    {{/each}}
                  </select>
                </div>
              {{/unless}}

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
                  <button type="button" class="btn btn-primary" disabled={{this.isSavingNotes}} {{on "click" this.saveNotes}}>
                    {{if this.isSavingNotes "Saving..." "Save Notes"}}
                  </button>
                </div>
              </div>
            {{/if}}

            {{!-- ── QUOTE BUILDER TAB ── --}}
            {{#if (eq this.activeTab "quote")}}

              {{!-- Quote mode sub-tabs --}}
              <div class="quote-mode-bar">
                <button
                  type="button"
                  class={{if (eq this.quoteMode "quick") "quote-mode-btn quote-mode-btn-active" "quote-mode-btn"}}
                  {{on "click" (fn this.setQuoteMode "quick")}}
                >
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
                  </svg>
                  Quick Estimate
                </button>
                <button
                  type="button"
                  class={{if (eq this.quoteMode "detailed") "quote-mode-btn quote-mode-btn-active" "quote-mode-btn"}}
                  {{on "click" (fn this.setQuoteMode "detailed")}}
                >
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="8" y1="6" x2="21" y2="6"/>
                    <line x1="8" y1="12" x2="21" y2="12"/>
                    <line x1="8" y1="18" x2="21" y2="18"/>
                    <line x1="3" y1="6" x2="3.01" y2="6"/>
                    <line x1="3" y1="12" x2="3.01" y2="12"/>
                    <line x1="3" y1="18" x2="3.01" y2="18"/>
                  </svg>
                  Detailed Quote
                </button>
              </div>

              {{!-- ── QUICK ESTIMATE ── --}}
              {{#if (eq this.quoteMode "quick")}}
                <div class="quote-section">
                  <div class="quote-section-header">
                    <div class="quote-section-title">Area Measurements</div>
                    <div class="quote-section-subtitle">Enter physical dimensions to generate a gross budget estimate</div>
                  </div>

                  <div class="quote-params-grid">
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-floor-q">Floor Area (m²)</label>
                      <input id="q-floor-q" type="number" min="0" step="0.1" class="form-input" value={{this.floorArea}} {{on "input" (fn this.handleAreaInput "floor")}} />
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-wall-q">Wall Area (m²)</label>
                      <input id="q-wall-q" type="number" min="0" step="0.1" class="form-input" value={{this.wallArea}} {{on "input" (fn this.handleAreaInput "wall")}} />
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-ceiling-q">Ceiling Area (m²)</label>
                      <input id="q-ceiling-q" type="number" min="0" step="0.1" class="form-input" value={{this.ceilingArea}} {{on "input" (fn this.handleAreaInput "ceiling")}} />
                    </div>
                  </div>

                  <div style="display: flex; justify-content: flex-end; margin-top: var(--space-4);">
                    <button type="button" class="btn btn-secondary" disabled={{this.isSavingQuote}} {{on "click" this.saveQuoteParams}}>
                      {{if this.isSavingQuote "Saving..." "Save Parameters"}}
                    </button>
                  </div>
                </div>

                <div class="quote-budget-banner">
                  <div>
                    <div class="quote-budget-label">Gross Base Budget</div>
                    <div class="quote-budget-sub">
                      {{this.floorArea}} m² &times; {{if this.baseBuildItem this.baseBuildItem.base_cost "0"}} €/m² (Base Build)
                    </div>
                  </div>
                  <div class="quote-budget-value">{{this.formatEur this.grossBaseBudget}}</div>
                </div>

                <div class="quote-quick-note">
                  Switch to <strong>Detailed Quote</strong> to add line items, insulation, fittings, and site works.
                </div>
              {{/if}}

              {{!-- ── DETAILED QUOTE ── --}}
              {{#if (eq this.quoteMode "detailed")}}

                {{!-- Project Parameters --}}
                <div class="quote-section">
                  <div class="quote-section-header">
                    <div class="quote-section-title">Project Parameters</div>
                    <div class="quote-section-subtitle">Define the physical areas for automatic cost calculations</div>
                  </div>

                  <div class="quote-params-grid">
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-floor">Floor Area (m²)</label>
                      <input id="q-floor" type="number" min="0" step="0.1" class="form-input" value={{this.floorArea}} {{on "input" (fn this.handleAreaInput "floor")}} />
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-wall">Wall Area (m²)</label>
                      <input id="q-wall" type="number" min="0" step="0.1" class="form-input" value={{this.wallArea}} {{on "input" (fn this.handleAreaInput "wall")}} />
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-ceiling">Ceiling Area (m²)</label>
                      <input id="q-ceiling" type="number" min="0" step="0.1" class="form-input" value={{this.ceilingArea}} {{on "input" (fn this.handleAreaInput "ceiling")}} />
                    </div>
                  </div>

                  <div class="quote-params-grid" style="margin-top: var(--space-3);">
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-markup">Markup %</label>
                      <input id="q-markup" type="number" min="0" step="0.5" class="form-input" value={{this.markupPct}} {{on "input" (fn this.handleAreaInput "markup")}} />
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-contingency">Contingency %</label>
                      <input id="q-contingency" type="number" min="0" step="0.5" class="form-input" value={{this.contingencyPct}} {{on "input" (fn this.handleAreaInput "contingency")}} />
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                      <label class="form-label" for="q-vat">VAT % (IE)</label>
                      <input id="q-vat" type="number" min="0" step="0.5" class="form-input" value={{this.vatPct}} {{on "input" (fn this.handleAreaInput "vat")}} />
                    </div>
                  </div>

                  <div style="display: flex; justify-content: flex-end; margin-top: var(--space-4);">
                    <button type="button" class="btn btn-secondary" disabled={{this.isSavingQuote}} {{on "click" this.saveQuoteParams}}>
                      {{if this.isSavingQuote "Saving..." "Save Parameters"}}
                    </button>
                  </div>
                </div>

                {{!-- Gross Base Budget --}}
                <div class="quote-budget-banner">
                  <div>
                    <div class="quote-budget-label">Gross Base Budget</div>
                    <div class="quote-budget-sub">
                      {{this.floorArea}} m² &times; {{if this.baseBuildItem this.baseBuildItem.base_cost "0"}} €/m² (Base Build)
                    </div>
                  </div>
                  <div class="quote-budget-value">{{this.formatEur this.grossBaseBudget}}</div>
                </div>

                {{!-- Line Items --}}
                <div class="quote-section">
                  <div class="quote-section-header">
                    <div class="quote-section-title">Quote Line Items</div>
                    <div class="quote-section-subtitle">Additional items on top of the base build cost</div>
                  </div>

                  {{#if this.lineItems.length}}
                    <div class="quote-line-table">
                      <div class="quote-line-thead">
                        <span>Item</span>
                        <span>Category</span>
                        <span style="text-align: right;">Unit Cost</span>
                        <span style="text-align: right;">Total</span>
                        <span></span>
                      </div>
                      {{#each this.lineItems as |item idx|}}
                        <div class="quote-line-row">
                          <span class="quote-line-name">{{item.name}}</span>
                          <span><span class="catalog-category-tag">{{item.category}}</span></span>
                          <span style="text-align: right; font-family: var(--font-mono); font-size: var(--text-xs);">
                            {{this.formatEur item.unit_cost}} / {{unitLabel item.unit_type}}
                          </span>
                          <span style="text-align: right; font-weight: 600; font-family: var(--font-mono); font-size: var(--text-sm);">
                            {{this.formatEur item.line_total}}
                          </span>
                          <span style="text-align: right;">
                            <button type="button" class="btn btn-ghost btn-sm" style="color: var(--color-error-500);" {{on "click" (fn this.removeLineItem idx)}}>
                              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                              </svg>
                            </button>
                          </span>
                        </div>
                      {{/each}}
                      <div class="quote-line-subtotal">
                        <span style="grid-column: 1 / 4;">Line Items Subtotal</span>
                        <span style="text-align: right; font-weight: 700; font-family: var(--font-mono);">{{this.formatEur this.lineItemsSubtotal}}</span>
                        <span></span>
                      </div>
                    </div>
                  {{else}}
                    <div style="padding: var(--space-5); text-align: center; color: var(--text-tertiary); font-size: var(--text-sm); background-color: var(--bg-surface-raised); border-radius: var(--radius-md); border: 1px dashed var(--border-strong);">
                      No line items added yet. Use the search below to find and add items from the catalog.
                    </div>
                  {{/if}}

                  {{!-- Search + add from catalog --}}
                  <div class="quote-catalog-search-row">
                    <div class="quote-catalog-search-wrap">
                      <svg class="quote-catalog-search-icon" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                      </svg>
                      <input
                        type="text"
                        class="form-input quote-catalog-search-input"
                        placeholder="Search catalog items..."
                        value={{this.catalogSearch}}
                        {{on "input" this.handleCatalogSearch}}
                      />
                    </div>
                  </div>

                  <div class="quote-add-row">
                    <select class="form-select" style="flex: 1;" {{on "change" this.handleCatalogSelect}}>
                      <option value="">— Select from catalog —</option>
                      {{#each this.filteredCatalogItems as |item|}}
                        <CatalogOption
                          @id={{item.id}}
                          @name={{item.name}}
                          @unitLabelStr={{unitLabel item.unit_type}}
                          @baseCost={{item.base_cost}}
                        />
                      {{/each}}
                    </select>
                    <button
                      type="button"
                      class="btn btn-primary"
                      disabled={{if this.selectedCatalogId false true}}
                      {{on "click" this.addLineItem}}
                    >
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                      </svg>
                      Add Item
                    </button>
                  </div>

                  {{!-- Running total --}}
                  {{#if (or this.grossBaseBudget this.lineItemsSubtotal)}}
                    <div class="quote-totals-block">
                      <div class="quote-totals-row">
                        <span>Gross Base Budget</span>
                        <span>{{this.formatEur this.grossBaseBudget}}</span>
                      </div>
                      <div class="quote-totals-row">
                        <span>Line Items</span>
                        <span>{{this.formatEur this.lineItemsSubtotal}}</span>
                      </div>
                      <div class="quote-totals-divider"></div>
                      <div class="quote-totals-row quote-totals-total">
                        <span>Total (excl. markup &amp; VAT)</span>
                        <span>{{this.formatEur this.totalBeforeMarkup}}</span>
                      </div>
                    </div>
                  {{/if}}
                </div>
              {{/if}}

            {{/if}}

          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
