import Component from '@glimmer/component';
import { service } from '@ember/service';
import AppSidebar from 'my-app/components/app-sidebar';
import AppTopbar from 'my-app/components/app-topbar';
import NewEnquiryModal from 'my-app/components/new-enquiry-modal';
import ToastContainer from 'my-app/components/toast-container';
import { tracked } from '@glimmer/tracking';

export default class AppLayout extends Component {
  @service projects;
  @service appSettings;
  @service catalog;
  @tracked showNewEnquiry = false;

  constructor() {
    super(...arguments);
    this.projects.loadProjects();
    this.appSettings.load();
    this.catalog.load();
  }

  openNewEnquiry = () => {
    this.showNewEnquiry = true;
  };

  closeNewEnquiry = () => {
    this.showNewEnquiry = false;
  };

  <template>
    <div class="app-shell">
      <AppSidebar />
      <div class="app-main">
        <AppTopbar @onNewEnquiry={{this.openNewEnquiry}} />
        <div class="app-content">
          {{yield}}
        </div>
      </div>
    </div>

    {{#if this.showNewEnquiry}}
      <NewEnquiryModal @onClose={{this.closeNewEnquiry}} />
    {{/if}}

    <ToastContainer />
  </template>
}
