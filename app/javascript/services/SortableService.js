import Sortable from "sortablejs";

class SortableService {
  static init({ containerEl, options = {} }) {
    return Sortable.create(containerEl, {
      group: {
        name: 'shared',
        pull: 'clone',
        put: false
      },
      animation: 150,
      forceFallback: true,
      fallbackClass: "timeboxing-items-fallback",
      fallbackOnBody: true,
      draggable: '.fc-event',
      ...options
    });
  }
}

export default SortableService;
