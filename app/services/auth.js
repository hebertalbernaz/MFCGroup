import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export const ROLES = {
  ADMIN: 'admin',
  DESIGNER: 'designer',
  ESTIMATOR: 'estimator',
};

const MOCK_USERS = {
  admin: {
    username: 'admin',
    password: '1234',
    role: ROLES.ADMIN,
    displayName: 'Admin User',
    initials: 'AU',
  },
  designer: {
    username: 'designer',
    password: 'designer',
    role: ROLES.DESIGNER,
    displayName: 'Design Team',
    initials: 'DT',
  },
  estimator: {
    username: 'estimator',
    password: 'estimator',
    role: ROLES.ESTIMATOR,
    displayName: 'Estimator',
    initials: 'ES',
  },
};

const SESSION_KEY = 'mfc_session_user';

export default class AuthService extends Service {
  @tracked currentUser = null;

  constructor() {
    super(...arguments);
    const stored = sessionStorage.getItem(SESSION_KEY);
    if (stored) {
      try {
        this.currentUser = JSON.parse(stored);
      } catch {
        sessionStorage.removeItem(SESSION_KEY);
      }
    }
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

  login(username, password) {
    const user = MOCK_USERS[username?.toLowerCase()];
    if (!user || user.password !== password) {
      return { success: false, error: 'Invalid username or password.' };
    }
    const sessionUser = {
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
}
