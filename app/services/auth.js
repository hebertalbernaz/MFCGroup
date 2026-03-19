import Service, { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export const ROLES = {
  ADMIN: 'Admin',
  DESIGNER: 'Designer',
  ESTIMATOR: 'Estimator',
  PURCHASING: 'Purchasing',
};

export const ROLE_OPTIONS = [
  { value: 'Admin', label: 'Admin' },
  { value: 'Designer', label: 'Designer' },
  { value: 'Estimator', label: 'Estimator' },
  { value: 'Purchasing', label: 'Purchasing' },
];

export default class AuthService extends Service {
  @service supabase;
  @tracked currentUser = null;
  @tracked profile = null;
  @tracked isLoading = true;

  constructor() {
    super(...arguments);
    this.initAuth();
  }

  async initAuth() {
    try {
      if (!this.supabase.auth) {
        console.error('Supabase auth not available');
        this.isLoading = false;
        return;
      }

      const { data: { session } } = await this.supabase.auth.getSession();
      if (session?.user) {
        await this.loadProfile(session.user.id);
      }
    } catch (error) {
      console.error('Auth initialization error:', error);
    } finally {
      this.isLoading = false;
    }

    if (this.supabase.auth) {
      this.supabase.auth.onAuthStateChange(async (event, session) => {
        if (event === 'SIGNED_IN' && session?.user) {
          await this.loadProfile(session.user.id);
        } else if (event === 'SIGNED_OUT') {
          this.currentUser = null;
          this.profile = null;
        }
      });
    }
  }

  async loadProfile(userId) {
    try {
      const { data, error } = await this.supabase.client
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

      if (error) throw error;

      if (data) {
        this.profile = data;
        this.currentUser = {
          id: data.id,
          email: data.email,
          fullName: data.full_name,
          role: data.role,
          initials: this.buildInitials(data.full_name || data.email),
        };
      }
    } catch (error) {
      console.error('Error loading profile:', error);
    }
  }

  buildInitials(name) {
    if (!name) return 'U';
    const parts = name.split(' ').filter(Boolean);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.slice(0, 2).toUpperCase();
  }

  get isAuthenticated() {
    return !!this.currentUser;
  }

  get role() {
    return this.currentUser?.role ?? null;
  }

  get isAdmin() {
    return this.role === ROLES.ADMIN;
  }

  get isDesigner() {
    return this.role === ROLES.DESIGNER;
  }

  get isEstimator() {
    return this.role === ROLES.ESTIMATOR;
  }

  get isPurchasing() {
    return this.role === ROLES.PURCHASING;
  }

  async login(email, password) {
    try {
      if (!this.supabase.auth) {
        return { success: false, error: 'Database connection not available' };
      }

      const { data, error } = await this.supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        return { success: false, error: error.message };
      }

      if (data.user) {
        await this.loadProfile(data.user.id);
      }

      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async logout() {
    try {
      await this.supabase.auth.signOut();
      this.currentUser = null;
      this.profile = null;
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async signUp(email, password, fullName, role = 'Designer') {
    try {
      const { data, error } = await this.supabase.auth.signUp({
        email,
        password,
      });

      if (error) {
        return { success: false, error: error.message };
      }

      if (data.user) {
        const { error: profileError } = await this.supabase.client
          .from('profiles')
          .insert({
            id: data.user.id,
            email,
            full_name: fullName,
            role,
          });

        if (profileError) {
          return { success: false, error: profileError.message };
        }
      }

      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}
