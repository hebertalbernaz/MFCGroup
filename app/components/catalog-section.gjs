import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { CATEGORIES, UNIT_TYPES, unitLabel } from '../services/catalog';

function eq(a, b) { return a === b; }

const BLANK_FORM = () => ({
  name: '',
  category: 'Structure',
  unit_type: 'm2',
  base_cost: '',
});

class CategoryOption extends Component {
  <template><option value={{@value}} selected={{@selected}}>{{@value}}</option></template>
}

class UnitTypeOption extends Component {
  <template><option value={{@value}} selected={{@selected}}>{{@label}}</option></template>
}

export default class CatalogSection extends Component {
  @service catalog;
  @service toast;

  @tracked form = BLANK_FORM();
  @tracked editingId = null;
  @tracked editForm = null;
  @tracked isSaving = false;
  @tracked confirmDeleteId = null;

  get categories() { return CATEGORIES; }
  get unitTypes() { return UNIT_TYPES; }

  get items() { return this.catalog.items; }

  unitLabel = unitLabel;

  formatCost(val) {
    return `€${Number(val).toLocaleString('en-IE', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  }

  handleFormField = (field, e) => {
    this.form = { ...this.form, [field]: e.target.value };
  };

  handleAddSubmit = async (e) => {
    e.preventDefault();
    if (!this.form.name.trim() || !this.form.base_cost) return;
    this.isSaving = true;
    try {
      await this.catalog.createItem({
        name: this.form.name.trim(),
        category: this.form.category,
        unit_type: this.form.unit_type,
        base_cost: parseFloat(this.form.base_cost),
      });
      this.form = BLANK_FORM();
      this.toast.success('Item added to catalog.', { duration: 3000 });
    } catch {
      this.toast.error('Failed to add item.', { duration: 5000 });
    } finally {
      this.isSaving = false;
    }
  };

  startEdit = (item) => {
    this.editingId = item.id;
    this.editForm = { name: item.name, category: item.category, unit_type: item.unit_type, base_cost: String(item.base_cost) };
  };

  handleEditField = (field, e) => {
    this.editForm = { ...this.editForm, [field]: e.target.value };
  };

  saveEdit = async (id) => {
    if (!this.editForm) return;
    this.isSaving = true;
    try {
      await this.catalog.updateItem(id, {
        name: this.editForm.name.trim(),
        category: this.editForm.category,
        unit_type: this.editForm.unit_type,
        base_cost: parseFloat(this.editForm.base_cost),
      });
      this.editingId = null;
      this.editForm = null;
      this.toast.success('Catalog item updated.', { duration: 3000 });
    } catch {
      this.toast.error('Failed to update item.', { duration: 5000 });
    } finally {
      this.isSaving = false;
    }
  };

  cancelEdit = () => {
    this.editingId = null;
    this.editForm = null;
  };

  requestDelete = (id) => { this.confirmDeleteId = id; };
  cancelDelete = () => { this.confirmDeleteId = null; };

  confirmDelete = async (id) => {
    try {
      await this.catalog.deleteItem(id);
      this.confirmDeleteId = null;
      this.toast.success('Item removed from catalog.', { duration: 3000 });
    } catch {
      this.toast.error('Failed to delete item.', { duration: 5000 });
    }
  };

  <template>
    <div class="settings-section">
      <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: var(--space-4); padding-bottom: var(--space-3); border-bottom: 1px solid var(--border-default);">
        <h2 class="settings-section-title" style="margin: 0; border: none; padding: 0;">Item Catalog</h2>
        <span style="font-size: var(--text-xs); font-weight: 600; color: var(--text-tertiary);">{{this.items.length}} items</span>
      </div>

      <p style="font-size: var(--text-sm); color: var(--text-secondary); margin-bottom: var(--space-5); line-height: 1.6;">
        Manage the library of reusable line items available in the quote builder. Costs here act as defaults and can be overridden per quote.
      </p>

      {{#if this.catalog.isLoading}}
        <div class="empty-state" style="padding: var(--space-8);">
          <div class="loading-spinner"></div>
        </div>
      {{else}}
        <div class="catalog-table-wrap">
          <table class="catalog-table">
            <thead>
              <tr>
                <th>Item Name</th>
                <th>Category</th>
                <th>Unit</th>
                <th style="text-align: right;">Base Cost</th>
                <th style="text-align: right; width: 100px;">Actions</th>
              </tr>
            </thead>
            <tbody>
              {{#each this.items as |item|}}
                {{#if (eq this.editingId item.id)}}
                  <tr class="catalog-row-edit">
                    <td>
                      <input
                        class="form-input"
                        style="padding: var(--space-1) var(--space-2); font-size: var(--text-xs);"
                        value={{this.editForm.name}}
                        {{on "input" (fn this.handleEditField "name")}}
                      />
                    </td>
                    <td>
                      <select
                        class="form-select"
                        style="padding: var(--space-1) var(--space-2); font-size: var(--text-xs); padding-right: 24px;"
                        {{on "change" (fn this.handleEditField "category")}}
                      >
                        {{#each this.categories as |cat|}}
                          <CategoryOption @value={{cat}} @selected={{eq cat this.editForm.category}} />
                        {{/each}}
                      </select>
                    </td>
                    <td>
                      <select
                        class="form-select"
                        style="padding: var(--space-1) var(--space-2); font-size: var(--text-xs); padding-right: 24px;"
                        {{on "change" (fn this.handleEditField "unit_type")}}
                      >
                        {{#each this.unitTypes as |ut|}}
                          <UnitTypeOption @value={{ut.value}} @label={{ut.label}} @selected={{eq ut.value this.editForm.unit_type}} />
                        {{/each}}
                      </select>
                    </td>
                    <td>
                      <input
                        class="form-input"
                        type="number"
                        min="0"
                        step="0.01"
                        style="padding: var(--space-1) var(--space-2); font-size: var(--text-xs); text-align: right;"
                        value={{this.editForm.base_cost}}
                        {{on "input" (fn this.handleEditField "base_cost")}}
                      />
                    </td>
                    <td style="text-align: right;">
                      <div style="display: flex; gap: var(--space-1); justify-content: flex-end;">
                        <button type="button" class="btn btn-primary btn-sm" disabled={{this.isSaving}} {{on "click" (fn this.saveEdit item.id)}}>Save</button>
                        <button type="button" class="btn btn-secondary btn-sm" {{on "click" this.cancelEdit}}>Cancel</button>
                      </div>
                    </td>
                  </tr>
                {{else if (eq this.confirmDeleteId item.id)}}
                  <tr class="catalog-row-delete">
                    <td colspan="4" style="font-size: var(--text-sm); color: var(--color-error-500); font-weight: 500;">
                      Delete "{{item.name}}"? This cannot be undone.
                    </td>
                    <td style="text-align: right;">
                      <div style="display: flex; gap: var(--space-1); justify-content: flex-end;">
                        <button type="button" class="btn btn-danger btn-sm" {{on "click" (fn this.confirmDelete item.id)}}>Delete</button>
                        <button type="button" class="btn btn-secondary btn-sm" {{on "click" this.cancelDelete}}>Cancel</button>
                      </div>
                    </td>
                  </tr>
                {{else}}
                  <tr class="catalog-row">
                    <td class="catalog-cell-name">{{item.name}}</td>
                    <td><span class="catalog-category-tag">{{item.category}}</span></td>
                    <td style="font-size: var(--text-xs); color: var(--text-secondary); font-family: var(--font-mono);">{{unitLabel item.unit_type}}</td>
                    <td style="text-align: right; font-weight: 600; font-family: var(--font-mono); font-size: var(--text-sm);">{{this.formatCost item.base_cost}}</td>
                    <td style="text-align: right;">
                      <div style="display: flex; gap: var(--space-1); justify-content: flex-end;">
                        <button type="button" class="btn btn-ghost btn-sm" {{on "click" (fn this.startEdit item)}}>Edit</button>
                        <button type="button" class="btn btn-ghost btn-sm" style="color: var(--color-error-500);" {{on "click" (fn this.requestDelete item.id)}}>Del</button>
                      </div>
                    </td>
                  </tr>
                {{/if}}
              {{else}}
                <tr>
                  <td colspan="5" style="text-align: center; padding: var(--space-8); color: var(--text-tertiary); font-size: var(--text-sm);">
                    No catalog items yet. Add the first item below.
                  </td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        </div>

        <div class="catalog-add-form">
          <div style="font-size: var(--text-sm); font-weight: 600; color: var(--text-primary); margin-bottom: var(--space-3);">Add New Item</div>
          <form style="display: grid; grid-template-columns: 2fr 1fr 1fr 1fr auto; gap: var(--space-3); align-items: flex-end;" {{on "submit" this.handleAddSubmit}}>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="new-item-name">Item Name</label>
              <input
                id="new-item-name"
                type="text"
                class="form-input"
                placeholder="e.g. Steel Frame (unit)"
                value={{this.form.name}}
                {{on "input" (fn this.handleFormField "name")}}
              />
            </div>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="new-item-category">Category</label>
              <select id="new-item-category" class="form-select" {{on "change" (fn this.handleFormField "category")}}>
                {{#each this.categories as |cat|}}
                  <CategoryOption @value={{cat}} @selected={{eq cat this.form.category}} />
                {{/each}}
              </select>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="new-item-unit">Unit Type</label>
              <select id="new-item-unit" class="form-select" {{on "change" (fn this.handleFormField "unit_type")}}>
                {{#each this.unitTypes as |ut|}}
                  <UnitTypeOption @value={{ut.value}} @label={{ut.label}} @selected={{eq ut.value this.form.unit_type}} />
                {{/each}}
              </select>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="new-item-cost">Base Cost (€)</label>
              <input
                id="new-item-cost"
                type="number"
                min="0"
                step="0.01"
                class="form-input"
                placeholder="0.00"
                value={{this.form.base_cost}}
                {{on "input" (fn this.handleFormField "base_cost")}}
              />
            </div>
            <button
              type="submit"
              class="btn btn-primary"
              disabled={{this.isSaving}}
              style="white-space: nowrap;"
            >
              Add Item
            </button>
          </form>
        </div>
      {{/if}}
    </div>
  </template>
}
