import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export const ROLES = {
  ADMIN: 'admin',
  DESIGNER: 'designer',
  ESTIMATOR: 'estimator',
};

export const ROLE_OPTIONS = [
  { value: 'admin', label: 'Admin' },
  { value: 'designer', label: 'Designer' },
  { value: 'estimator', label: 'Estimator' },
];

const SESSION_KEY = 'mfc_session_user';
const USERS_KEY = 'mfc_users_store';

const DEFAULT_USERS = [
  { id: 1, username: 'admin', password: '123', role: 'admin', displayName: 'Admin User', initials: 'AU' },
  { id: 2, username: 'jane_des', password: '123', role: 'designer', displayName: 'Jane Designer', initials: 'JD' },
  { id: 3, username: 'john_est', password: '123', role: 'estimator', displayName: 'John Estimator', initials: 'JE' },
];

function loadUsers() {
  try {
    const stored = localStorage.getItem(USERS_KEY);
    if (stored) return JSON.parse(stored);
  } catch { /* */ }
  return DEFAULT_USERS.map((u) => ({ ...u }));
}

function saveUsers(users) {
  try {
    localStorage.setItem(USERS_KEY, JSON.stringify(users));
  } catch { /* */ }
}

function nextId(users) {
  return users.reduce((max, u) => Math.max(max, u.id), 0) + 1;
}

function buildInitials(username) {
  const parts = username.split(/[_\s]/);
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return username.slice(0, 2).toUpperCase();
}

function buildDisplayName(username) {
  return username.split(/[_\s]/).map((w) => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
}

export default class AuthService extends Service {
  @tracked currentUser = null;
  @tracked users = [];

  constructor() {
    super(...arguments);
    this.users = loadUsers();
    const stored = sessionStorage.getItem(SESSION_KEY);
    if (stored) {
      try {
        this.currentUser = JSON.parse(stored);
      } catch {
        sessionStorage.removeItem(SESSION_KEY);
      }
    }
  }

  get isAuthenticated() { return !!this.currentUser; }
  get role() { return this.currentUser?.role ?? null; }
  get isAdmin() { return this.role === ROLES.ADMIN; }
  get isDesigner() { return this.role === ROLES.DESIGNER; }
  get isEstimator() { return this.role === ROLES.ESTIMATOR; }

  login(username, password) {
    const user = this.users.find(
      (u) => u.username.toLowerCase() === username?.toLowerCase() && u.password === password
    );
    if (!user) {
      return { success: false, error: 'Invalid username or password.' };
    }
    const sessionUser = {
      id: user.id,
      username: user.username,
      role: user.role,
      displayName: user.displayName,
      initials: user.initials,
    };
    this.currentUser = sessionUser;
    sessionStorage.setItem(SESSION_KEY, JSON.stringify(sessionUser));
    return { success: true };
  }

  logout() {
    this.currentUser = null;
    sessionStorage.removeItem(SESSION_KEY);
  }

  changeOwnPassword(newPassword) {
    if (!newPassword?.trim() || !this.currentUser) {
      return { success: false, error: 'Password cannot be empty.' };
    }
    const updated = this.users.map((u) =>
      u.id === this.currentUser.id ? { ...u, password: newPassword } : u
    );
    this.users = updated;
    saveUsers(updated);
    return { success: true };
  }

  adminResetUserPassword(userId, newPassword) {
    if (!this.isAdmin) return { success: false, error: 'Unauthorized.' };
    if (!newPassword?.trim()) return { success: false, error: 'Password cannot be empty.' };
    const updated = this.users.map((u) =>
      u.id === userId ? { ...u, password: newPassword } : u
    );
    this.users = updated;
    saveUsers(updated);
    return { success: true };
  }

  adminAddUser(username, password, role) {
    if (!this.isAdmin) return { success: false, error: 'Unauthorized.' };
    if (!username?.trim()) return { success: false, error: 'Username is required.' };
    if (!password?.trim()) return { success: false, error: 'Password is required.' };
    const exists = this.users.find(
      (u) => u.username.toLowerCase() === username.trim().toLowerCase()
    );
    if (exists) return { success: false, error: 'Username already exists.' };
    const newUser = {
      id: nextId(this.users),
      username: username.trim(),
      password: password.trim(),
      role: role || 'designer',
      displayName: buildDisplayName(username.trim()),
      initials: buildInitials(username.trim()),
    };
    this.users = [...this.users, newUser];
    saveUsers(this.users);
    return { success: true };
  }

  adminDeleteUser(userId) {
    if (!this.isAdmin) return { success: false, error: 'Unauthorized.' };
    if (userId === this.currentUser?.id) {
      return { success: false, error: 'You cannot delete your own account.' };
    }
    this.users = this.users.filter((u) => u.id !== userId);
    saveUsers(this.users);
    return { success: true };
  }
}
