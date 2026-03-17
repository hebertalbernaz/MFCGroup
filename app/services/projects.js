import Service, { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { podLifecycleCopy } from 'my-app/utils/pod-lifecycle-copy';

export const STATUSES = [
  { key: 'new_enquiry', label: 'New Enquiries' },
  { key: 'design_active', label: 'Design Active' },
  { key: 'in_revision', label: 'In Revision' },
  { key: 'awaiting_approval', label: 'Awaiting Approval' },
  { key: 'awaiting_quote', label: 'Awaiting Quote' },
  { key: 'signed', label: 'Signed' },
  { key: 'approved', label: 'Approved' },
  { key: 'closed', label: 'Closed' },
];

export const PRODUCT_TYPES = ['MFC', 'POD'];

const POD_LIFECYCLE_STATUSES = new Set(['signed', 'approved']);

export default class ProjectsService extends Service {
  @service supabase;
  @service appSettings;
  @service toast;
  @service auditLog;
  @service auth;

  @tracked projects = [];
  @tracked isLoading = false;
  @tracked error = null;

  get projectsByStatus() {
    const grouped = {};
    for (const status of STATUSES) {
      grouped[status.key] = this.projects.filter((p) => p.status === status.key);
    }
    return grouped;
  }

  get recentProjects() {
    return [...this.projects]
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
      .slice(0, 5);
  }

  get statusCounts() {
    const counts = {};
    for (const status of STATUSES) {
      counts[status.key] = this.projects.filter((p) => p.status === status.key).length;
    }
    return counts;
  }

  getSlaStatus(project) {
    if (!project.created_at) return 'green';
    const created = new Date(project.created_at);
    const now = new Date();
    const daysDiff = Math.floor((now - created) / (1000 * 60 * 60 * 24));

    if (project.status === 'closed' || project.status === 'signed' || project.status === 'approved') return 'green';
    if (daysDiff >= 14) return 'red';
    if (daysDiff >= 7) return 'yellow';
    return 'green';
  }

  async loadProjects() {
    this.isLoading = true;
    this.error = null;
    try {
      const { data, error } = await this.supabase.client
        .from('projects')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      this.projects = data || [];
    } catch (err) {
      this.error = err.message;
    } finally {
      this.isLoading = false;
    }
  }

  async createProject(formData) {
    this.error = null;
    try {
      const isMfc = formData.productType === 'MFC';
      const counter = isMfc ? this.appSettings.nextMfcNumber : this.appSettings.nextPdNumber;
      const projectId = isMfc ? `MFC ${counter}` : `PD${counter}`;

      const deadline = new Date();
      deadline.setDate(deadline.getDate() + 14);

      const { data, error } = await this.supabase.client
        .from('projects')
        .insert({
          project_id: projectId,
          client_name: formData.clientName,
          phone: formData.phone,
          email: formData.email,
          eircode: formData.eircode,
          product_type: formData.productType,
          status: 'new_enquiry',
          sequence_number: counter,
          deadline: deadline.toISOString(),
        })
        .select()
        .maybeSingle();

      if (error) throw error;

      if (isMfc) {
        await this.appSettings.incrementMfcNumber();
      } else {
        await this.appSettings.incrementPdNumber();
      }

      this.projects = [data, ...this.projects];
      this.auditLog.logAction(this.auth.currentUser, 'PROJECT_CREATED', `${projectId} — ${formData.clientName} (${formData.productType})`);
      return data;
    } catch (err) {
      this.error = err.message;
      throw err;
    }
  }

  async updateProjectStatus(projectId, newStatus) {
    this.error = null;
    try {
      const project = this.projects.find((p) => p.id === projectId);
      const prevStatus = project?.status ?? '?';

      const { data, error } = await this.supabase.client
        .from('projects')
        .update({ status: newStatus })
        .eq('id', projectId)
        .select()
        .maybeSingle();

      if (error) throw error;

      this.projects = this.projects.map((p) => (p.id === projectId ? data : p));
      this.auditLog.logAction(
        this.auth.currentUser,
        'PROJECT_STATUS_CHANGED',
        `${project?.project_id ?? projectId}: ${prevStatus} → ${newStatus}`
      );

      if (project && project.product_type === 'POD' && POD_LIFECYCLE_STATUSES.has(newStatus)) {
        const podProjectNumber = this.appSettings.nextPodProjectNumber;
        const newProjectId = `POD-${podProjectNumber}`;

        const result = podLifecycleCopy({
          enquiryProjectId: project.project_id,
          newProjectId,
          clientName: project.client_name,
          podEnquiriesPath: this.appSettings.podEnquiriesPath,
          podProjectsPath: this.appSettings.podProjectsPath,
        });

        const { error: idError } = await this.supabase.client
          .from('projects')
          .update({ project_id: newProjectId })
          .eq('id', projectId);

        if (!idError) {
          this.projects = this.projects.map((p) =>
            p.id === projectId ? { ...data, project_id: newProjectId } : p
          );
          await this.appSettings.incrementPodProjectNumber();
        }

        this.toast.info(result.message, { duration: 8000 });
      }

      return data;
    } catch (err) {
      this.error = err.message;
      throw err;
    }
  }

  async updateProjectNotes(projectId, notes) {
    this.error = null;
    try {
      const { data, error } = await this.supabase.client
        .from('projects')
        .update({ internal_notes: notes })
        .eq('id', projectId)
        .select()
        .maybeSingle();

      if (error) throw error;

      this.projects = this.projects.map((p) => (p.id === projectId ? data : p));
      return data;
    } catch (err) {
      this.error = err.message;
      throw err;
    }
  }

  async updateProjectQuote(projectId, quoteFields) {
    this.error = null;
    try {
      const { data, error } = await this.supabase.client
        .from('projects')
        .update(quoteFields)
        .eq('id', projectId)
        .select()
        .maybeSingle();

      if (error) throw error;
      this.projects = this.projects.map((p) => (p.id === projectId ? data : p));
      return data;
    } catch (err) {
      this.error = err.message;
      throw err;
    }
  }

  async deleteProject(projectId) {
    this.error = null;
    try {
      const project = this.projects.find((p) => p.id === projectId);
      const { error } = await this.supabase.client.from('projects').delete().eq('id', projectId);

      if (error) throw error;

      this.projects = this.projects.filter((p) => p.id !== projectId);
      this.auditLog.logAction(
        this.auth.currentUser,
        'PROJECT_DELETED',
        `${project?.project_id ?? projectId} — ${project?.client_name ?? ''}`
      );
    } catch (err) {
      this.error = err.message;
      throw err;
    }
  }
}
