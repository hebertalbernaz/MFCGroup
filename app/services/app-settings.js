import Service, { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

const KEYS = [
  'mfc_template_path',
  'pod_template_path',
  'mfc_projects_path',
  'pod_enquiries_path',
  'pod_projects_path',
  'next_mfc_number',
  'next_pod_number',
];

export default class AppSettingsService extends Service {
  @service supabase;

  @tracked mfcTemplatePath = '';
  @tracked podTemplatePath = '';
  @tracked mfcProjectsPath = '';
  @tracked podEnquiriesPath = '';
  @tracked podProjectsPath = '';
  @tracked nextMfcNumber = 2000;
  @tracked nextPodNumber = 1000;
  @tracked isLoading = false;
  @tracked isSaving = false;
  @tracked error = null;

  get isConfigured() {
    return (
      this.mfcTemplatePath.trim() !== '' &&
      this.podTemplatePath.trim() !== '' &&
      this.mfcProjectsPath.trim() !== '' &&
      this.podEnquiriesPath.trim() !== '' &&
      this.podProjectsPath.trim() !== ''
    );
  }

  templatePathFor(productType) {
    return productType === 'MFC' ? this.mfcTemplatePath : this.podTemplatePath;
  }

  destinationPathFor(productType) {
    return productType === 'MFC' ? this.mfcProjectsPath : this.podEnquiriesPath;
  }

  async load() {
    this.isLoading = true;
    this.error = null;
    try {
      const { data, error } = await this.supabase.client
        .from('app_settings')
        .select('key, value')
        .in('key', KEYS);

      if (error) throw error;

      for (const row of data || []) {
        if (row.key === 'mfc_template_path') this.mfcTemplatePath = row.value;
        if (row.key === 'pod_template_path') this.podTemplatePath = row.value;
        if (row.key === 'mfc_projects_path') this.mfcProjectsPath = row.value;
        if (row.key === 'pod_enquiries_path') this.podEnquiriesPath = row.value;
        if (row.key === 'pod_projects_path') this.podProjectsPath = row.value;
        if (row.key === 'next_mfc_number') this.nextMfcNumber = parseInt(row.value, 10) || 2000;
        if (row.key === 'next_pod_number') this.nextPodNumber = parseInt(row.value, 10) || 1000;
      }
    } catch (err) {
      this.error = err.message;
    } finally {
      this.isLoading = false;
    }
  }

  async incrementMfcNumber() {
    const next = this.nextMfcNumber + 1;
    const { error } = await this.supabase.client
      .from('app_settings')
      .update({ value: String(next) })
      .eq('key', 'next_mfc_number');
    if (!error) this.nextMfcNumber = next;
  }

  async incrementPodNumber() {
    const next = this.nextPodNumber + 1;
    const { error } = await this.supabase.client
      .from('app_settings')
      .update({ value: String(next) })
      .eq('key', 'next_pod_number');
    if (!error) this.nextPodNumber = next;
  }

  async save({ mfcTemplatePath, podTemplatePath, mfcProjectsPath, podEnquiriesPath, podProjectsPath, nextMfcNumber, nextPodNumber }) {
    this.isSaving = true;
    this.error = null;
    try {
      const upserts = [
        { key: 'mfc_template_path', value: mfcTemplatePath },
        { key: 'pod_template_path', value: podTemplatePath },
        { key: 'mfc_projects_path', value: mfcProjectsPath },
        { key: 'pod_enquiries_path', value: podEnquiriesPath },
        { key: 'pod_projects_path', value: podProjectsPath },
        { key: 'next_mfc_number', value: String(nextMfcNumber) },
        { key: 'next_pod_number', value: String(nextPodNumber) },
      ];

      for (const row of upserts) {
        const { error } = await this.supabase.client
          .from('app_settings')
          .update({ value: row.value })
          .eq('key', row.key);
        if (error) throw error;
      }

      this.mfcTemplatePath = mfcTemplatePath;
      this.podTemplatePath = podTemplatePath;
      this.mfcProjectsPath = mfcProjectsPath;
      this.podEnquiriesPath = podEnquiriesPath;
      this.podProjectsPath = podProjectsPath;
      this.nextMfcNumber = parseInt(nextMfcNumber, 10) || 2000;
      this.nextPodNumber = parseInt(nextPodNumber, 10) || 1000;
    } catch (err) {
      this.error = err.message;
      throw err;
    } finally {
      this.isSaving = false;
    }
  }
}
