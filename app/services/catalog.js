import Service, { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export const CATEGORIES = ['Structure', 'Insulation', 'Finishes', 'Appliances', 'Site Works', 'General'];
export const UNIT_TYPES = [
  { value: 'm2', label: 'm²' },
  { value: 'unit', label: 'Unit' },
  { value: 'linear_m', label: 'Linear m' },
  { value: 'fixed', label: 'Fixed' },
];

export function unitLabel(unitType) {
  return UNIT_TYPES.find((u) => u.value === unitType)?.label ?? unitType;
}

export default class CatalogService extends Service {
  @service supabase;

  @tracked items = [];
  @tracked isLoading = false;
  @tracked error = null;

  async load() {
    this.isLoading = true;
    this.error = null;
    try {
      const { data, error } = await this.supabase.client
        .from('catalog_items')
        .select('*')
        .order('sort_order', { ascending: true })
        .order('name', { ascending: true });

      if (error) throw error;
      this.items = data || [];
    } catch (err) {
      this.error = err.message;
    } finally {
      this.isLoading = false;
    }
  }

  async createItem(fields) {
    this.error = null;
    const maxOrder = this.items.reduce((max, i) => Math.max(max, i.sort_order ?? 0), 0);
    const { data, error } = await this.supabase.client
      .from('catalog_items')
      .insert({ ...fields, sort_order: maxOrder + 10 })
      .select()
      .maybeSingle();

    if (error) { this.error = error.message; throw error; }
    this.items = [...this.items, data];
    return data;
  }

  async updateItem(id, fields) {
    this.error = null;
    const { data, error } = await this.supabase.client
      .from('catalog_items')
      .update(fields)
      .eq('id', id)
      .select()
      .maybeSingle();

    if (error) { this.error = error.message; throw error; }
    this.items = this.items.map((i) => (i.id === id ? data : i));
    return data;
  }

  async deleteItem(id) {
    this.error = null;
    const { error } = await this.supabase.client
      .from('catalog_items')
      .delete()
      .eq('id', id);

    if (error) { this.error = error.message; throw error; }
    this.items = this.items.filter((i) => i.id !== id);
  }

  getItemById(id) {
    return this.items.find((i) => i.id === id);
  }
}
