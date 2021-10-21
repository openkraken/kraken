const ex = new Error('CustomErrorTest');
let propertyCallbackSuccess = false;
let eventListenerSuccess = false;

// onerror api and Error events test will conflict with jasmine error detection.
window.onerror = function(event, sourceURL, line, column, error) {
  try {
    propertyCallbackSuccess = window.onerror === arguments.callee || error === ex || sourceURL === location.href || event instanceof Event;
  } catch (e) {
    propertyCallbackSuccess = false;
  }
};

window.addEventListener('error', (e) => {
  eventListenerSuccess = e.error === ex;
});

describe('window onerror', () => {
  it('window onerror works', () => {
    expect(eventListenerSuccess).toBe(true, 'event listener success');
    expect(propertyCallbackSuccess).toBe(true, 'property callback success');
  });
});

// @ts-ignore
window.triggerGlobalError = function() {
  throw ex;
}

