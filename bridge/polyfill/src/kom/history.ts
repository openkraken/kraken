// https://html.spec.whatwg.org/multipage/browsers.html#the-history-interface
let _state: any = null;

function back() {
  console.warn('Unimpl history.back');
}
function forward() {
  console.warn('Unimpl history.forward');
}
function go(delta?: number) {
  console.warn('Unimpl history.go');
}
function pushState(state: any, title: string, url?: string) {
  console.warn('Unimpl history.pushState');
}
function replaceState(state: any, title: string, url?: string) {
  console.warn('Unimpl history.replaceState');
}

export const history = {
  // Returns an Integer representing the number of elements in the session
  // history, including the currently loaded page. For example, for a page
  // loaded in a new tab this property returns 1.
  get length() {
    // @TODO: support navigation and history.
    return 1;
  },

  // Allows web applications to explicitly set default scroll
  // restoration behavior on history navigation. This property
  // can be either auto or manual.
  scrollRestoration: 'auto',

  // Returns an any value representing the state at the top of the history
  // stack. This is a way to look at the state without having to wait for a
  // popstate event.
  get state() {
    return _state;
  },

  // Methods
  back,
  forward,
  go,
  pushState,
  replaceState,
};
