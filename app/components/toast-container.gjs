import Component from '@glimmer/component';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';

export default class ToastContainer extends Component {
  @service toast;

  dismiss = (id) => {
    this.toast.dismiss(id);
  };

  <template>
    <div class="toast-container">
      {{#each this.toast.toasts as |t|}}
        <div class="toast toast-{{t.type}}">
          <div class="toast-body">
            <span class="toast-message">{{t.message}}</span>
            {{#if t.detail}}
              <span class="toast-detail">{{t.detail}}</span>
            {{/if}}
          </div>
          <button type="button" class="toast-dismiss" {{on "click" (fn this.dismiss t.id)}}>
            &times;
          </button>
        </div>
      {{/each}}
    </div>
  </template>
}
