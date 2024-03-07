import { Controller } from "@hotwired/stimulus"
import ProgressBar from "progressbar.js";

// Connects to data-controller="habits--index"
export default class extends Controller {
  connect() {
    this.initProgressBars();
    this.initGoalTrackersSidebar();
  }

  handleDateChanged(e) {
    const date = e.currentTarget.dataset.date;
    const search = new URLSearchParams(location.search);

    if (search.has('date') && search.get('date') == date) return;
    search.set('date', date);
    window.location.search = search.toString();
  }

  handleInputDateChanged(event) {
    const date = event.target.value;
    const search = new URLSearchParams(location.search);
    search.set('date', date);
    window.location.search = search.toString();
  }

  initProgressBars() {
    const progressBars = document.querySelectorAll('.goal-progress-bar')
    if (progressBars.length == 0) return;
    progressBars.forEach((progressBar) => {
      if (progressBar.children.length > 0) return;

      const bar = new ProgressBar.Circle(progressBar, {
        strokeWidth: 15,
        easing: 'easeInOut',
        duration: 1400,
        color: '#2563eb',
        trailColor: '#eee',
        trailWidth: 15,
        svgStyle: null
      });

      bar.animate(progressBar.dataset.goalValue);
    })
  }

  toggleCompleteHabit(event) {
    event.stopPropagation();
    const habitId = event.target.dataset.habitId
    const form = document.getElementById(`form-completed-${habitId}`)
    Rails.fire(form, 'submit')
  }

  toggleHabitAndGoalTracker(evt) {
    // Ignore event if clicked within element
    if (evt.target.tagName == 'INPUT' || evt.target.tagName == 'svg' || evt.target.tagName == 'path' || evt.target.dataset.modalTarget) {
      return
    }

    const habitId = evt.currentTarget.dataset.habitId
    const activeHabit = document.querySelector('.habit-details-wrapper.active');
    const currentHabitId = activeHabit ? activeHabit.firstElementChild.dataset.habitId : null

    console.log(currentHabitId, habitId)

    if (currentHabitId == habitId) {
      this.toggleSameHabitAndGoalTracker(activeHabit)
      return false;
    }

    document.querySelectorAll('.habit-details-wrapper').forEach((habit) => {
      habit.classList.remove('active')
    })
    evt.currentTarget.parentElement.classList.add('active')
    const search = new URLSearchParams(location.search);
    const current_date = search.has('date') ? search.get('date') : ""

    Rails.ajax({
      url: `/habits/${habitId}/goal_trackers?date=${current_date}`,
      type: 'GET',
      dataType: 'script',
      success: () => {
        const goalTrackerSection = document.querySelector('#goal-tracker-section')
        goalTrackerSection.classList.remove('w-0')
        goalTrackerSection.classList.add('w-2/3')
        search.set('habit_id', habitId);
        window.history.replaceState(null, null, `?${search.toString()}`);
      }
    })
  }

  toggleSameHabitAndGoalTracker(activeHabit) {
    const goalTrackerSection = document.querySelector('#goal-tracker-section')
    console.log(activeHabit)
    activeHabit.classList.remove('active')
    goalTrackerSection.classList.remove('w-2/3')
    goalTrackerSection.classList.add('w-0')

    goalTrackerSection.parentElement.children[0].querySelector(".date-time-habit-wrapper").classList.remove("lg:flex-col");

    const search = new URLSearchParams(location.search);
    search.delete('habit_id');
    window.history.replaceState(null, null, `?${search.toString()}`);
  }

  initGoalTrackersSidebar() {
    const search = new URLSearchParams(location.search);
    const habitId = search.has('habit_id') ? search.get('habit_id') : null
    if (!habitId) return;

    const habit = document.querySelector(`[data-habit-id="${habitId}"]`)
    if (!habit) return;

    habit.parentElement.classList.add('active')
    const current_date = search.has('date') ? search.get('date') : ""

    Rails.ajax({
      url: `/habits/${habitId}/goal_trackers?date=${current_date}`,
      type: 'GET',
      dataType: 'script',
      success: () => {
        const goalTrackerSection = document.querySelector('#goal-tracker-section')
        goalTrackerSection.classList.remove('w-0')
        goalTrackerSection.classList.add('w-2/3')
      }
    })
  }
}