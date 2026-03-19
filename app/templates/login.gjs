import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

class LoginPage extends Component {
  @service auth;
  @service router;

  @tracked email = '';
  @tracked password = '';
  @tracked error = '';
  @tracked isLoading = false;

  updateEmail = (e) => { this.email = e.target.value; };
  updatePassword = (e) => { this.password = e.target.value; };

  handleSubmit = async (e) => {
    e.preventDefault();
    this.error = '';
    this.isLoading = true;

    const result = await this.auth.login(this.email, this.password);
    if (result.success) {
      const role = this.auth.role;
      if (role === 'Estimator') {
        this.router.transitionTo('app.quoting-desk');
      } else if (role === 'Designer') {
        this.router.transitionTo('app.projects');
      } else {
        this.router.transitionTo('app.dashboard');
      }
    } else {
      this.error = result.error || 'Invalid email or password';
    }
    this.isLoading = false;
  };

  <template>
    <div class="login-shell">
      <div class="login-card">
        <div class="login-logo">
          <div class="login-logo-mark">TPF</div>
        </div>
        <div class="login-header">
          <h1 class="login-title">The Pod Factory</h1>
          <p class="login-subtitle">Enterprise Resource Planning System</p>
        </div>

        <form class="login-form" {{on "submit" this.handleSubmit}}>
          {{#if this.error}}
            <div class="login-error">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/>
              </svg>
              {{this.error}}
            </div>
          {{/if}}

          <div class="form-group">
            <label class="form-label" for="login-email">Email Address</label>
            <input
              id="login-email"
              type="email"
              class="form-input"
              placeholder="Enter your email"
              autocomplete="email"
              value={{this.email}}
              {{on "input" this.updateEmail}}
              required
            />
          </div>

          <div class="form-group">
            <label class="form-label" for="login-password">Password</label>
            <input
              id="login-password"
              type="password"
              class="form-input"
              placeholder="Enter your password"
              autocomplete="current-password"
              value={{this.password}}
              {{on "input" this.updatePassword}}
              required
            />
          </div>

          <button type="submit" class="btn btn-primary login-submit" disabled={{this.isLoading}}>
            {{#if this.isLoading}}
              <div class="loading-spinner" style="width:14px;height:14px;border-width:2px;"></div>
              Signing in...
            {{else}}
              Sign In
            {{/if}}
          </button>
        </form>
      </div>

      <div class="login-footer">
        The Pod Factory System &mdash; Ireland
      </div>
    </div>
  </template>
}

export default <template>
  <LoginPage />
</template>
