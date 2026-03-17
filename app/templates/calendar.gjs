import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const DAY_HEADERS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

function buildCalendarDays(year, month, projects, getSlaStatus) {
  const firstDay = new Date(year, month, 1);
  const daysInMonth = new Date(year, month + 1, 0).getDate();

  let startDow = firstDay.getDay();
  startDow = startDow === 0 ? 6 : startDow - 1;

  const todayMs = new Date(
    new Date().getFullYear(),
    new Date().getMonth(),
    new Date().getDate()
  ).getTime();

  const cells = [];

  for (let i = startDow; i > 0; i--) {
    const d = new Date(year, month, 1 - i);
    cells.push({ dayNum: d.getDate(), isCurrentMonth: false, isToday: false, enquiries: [], deadlines: [] });
  }

  for (let d = 1; d <= daysInMonth; d++) {
    const cellMs = new Date(year, month, d).getTime();
    const enquiries = projects
      .filter((p) => {
        if (!p.created_at) return false;
        const pd = new Date(p.created_at);
        return pd.getFullYear() === year && pd.getMonth() === month && pd.getDate() === d;
      })
      .map((p) => ({ id: p.project_id, label: `${p.project_id} ${p.client_name}`, sla: getSlaStatus(p) }));

    const deadlines = projects
      .filter((p) => {
        if (!p.deadline) return false;
        const pd = new Date(p.deadline);
        return pd.getFullYear() === year && pd.getMonth() === month && pd.getDate() === d;
      })
      .map((p) => ({ id: p.project_id, label: `\u25B6 ${p.project_id}`, sla: getSlaStatus(p) }));

    cells.push({
      dayNum: d,
      isCurrentMonth: true,
      isToday: cellMs === todayMs,
      enquiries,
      deadlines,
    });
  }

  const remaining = 42 - cells.length;
  for (let d = 1; d <= remaining; d++) {
    cells.push({ dayNum: d, isCurrentMonth: false, isToday: false, enquiries: [], deadlines: [] });
  }

  return cells;
}

class CalendarCell extends Component {
  get dayNumClass() {
    let cls = 'calendar-day-number';
    if (this.args.cell.isToday) cls += ' today';
    if (!this.args.cell.isCurrentMonth) cls += ' other-month';
    return cls;
  }

  <template>
    <div class="calendar-day">
      <div class={{this.dayNumClass}}>{{@cell.dayNum}}</div>
      {{#each @cell.enquiries as |ev|}}
        <div class="calendar-event calendar-event-{{ev.sla}}" title={{ev.label}}>{{ev.label}}</div>
      {{/each}}
      {{#each @cell.deadlines as |ev|}}
        <div class="calendar-event calendar-event-{{ev.sla}}" title={{ev.label}}>{{ev.label}}</div>
      {{/each}}
    </div>
  </template>
}

class CalendarPage extends Component {
  @service projects;

  @tracked currentYear = new Date().getFullYear();
  @tracked currentMonth = new Date().getMonth();

  get monthLabel() {
    return `${MONTH_NAMES[this.currentMonth]} ${this.currentYear}`;
  }

  get calendarCells() {
    return buildCalendarDays(
      this.currentYear,
      this.currentMonth,
      this.projects.projects,
      (p) => this.projects.getSlaStatus(p)
    );
  }

  prevMonth = () => {
    if (this.currentMonth === 0) {
      this.currentMonth = 11;
      this.currentYear = this.currentYear - 1;
    } else {
      this.currentMonth = this.currentMonth - 1;
    }
  };

  nextMonth = () => {
    if (this.currentMonth === 11) {
      this.currentMonth = 0;
      this.currentYear = this.currentYear + 1;
    } else {
      this.currentMonth = this.currentMonth + 1;
    }
  };

  goToToday = () => {
    this.currentYear = new Date().getFullYear();
    this.currentMonth = new Date().getMonth();
  };

  <template>
    <div class="page-header">
      <div>
        <h1 class="page-title">Calendar</h1>
        <p class="page-subtitle">Project enquiries and deadlines by date</p>
      </div>
    </div>

    <div class="calendar-container">
      <div class="calendar-header">
        <span class="calendar-month-year">{{this.monthLabel}}</span>
        <div class="calendar-nav">
          <button class="btn btn-secondary btn-sm" type="button" {{on "click" this.goToToday}}>Today</button>
          <button class="btn btn-ghost btn-icon" type="button" {{on "click" this.prevMonth}} aria-label="Previous month">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="15 18 9 12 15 6"/>
            </svg>
          </button>
          <button class="btn btn-ghost btn-icon" type="button" {{on "click" this.nextMonth}} aria-label="Next month">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </button>
        </div>
      </div>

      <div class="calendar-grid">
        {{#each DAY_HEADERS as |day|}}
          <div class="calendar-day-header">{{day}}</div>
        {{/each}}

        {{#each this.calendarCells as |cell|}}
          <CalendarCell @cell={{cell}} />
        {{/each}}
      </div>
    </div>

    <div style="display: flex; gap: var(--space-4); margin-top: var(--space-4); flex-wrap: wrap;">
      <div style="display: flex; align-items: center; gap: var(--space-2); font-size: var(--text-xs); color: var(--text-secondary);">
        <div style="width: 12px; height: 12px; border-radius: 2px; background: var(--color-primary-100);"></div>
        Enquiry Created
      </div>
      <div style="display: flex; align-items: center; gap: var(--space-2); font-size: var(--text-xs); color: var(--text-secondary);">
        <div style="width: 12px; height: 12px; border-radius: 2px; background: rgba(239,68,68,0.15);"></div>
        Overdue SLA
      </div>
      <div style="display: flex; align-items: center; gap: var(--space-2); font-size: var(--text-xs); color: var(--text-secondary);">
        <div style="width: 12px; height: 12px; border-radius: 2px; background: rgba(234,179,8,0.15);"></div>
        Due Soon
      </div>
    </div>
  </template>
}

export default <template><CalendarPage /></template>
