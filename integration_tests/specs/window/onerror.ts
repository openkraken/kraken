const ex = new Error('CustomErrorTest');
let onerrorTestSuccess = false;

window.onerror = function(event, sourceURL, line, column, error) {
  try {
    onerrorTestSuccess = window.onerror === arguments.callee || error === ex || sourceURL === location.href || event instanceof Event;
  } catch (e) {
    onerrorTestSuccess = false;
  }
};

window.addEventListener('error', (e) => {
  onerrorTestSuccess = e.error === ex;
});

describe('window onerror', () => {
  it('window onerror works', () => {
    expect(onerrorTestSuccess).toBe(true);
  });
});

setTimeout(() => {
  throw ex;
});

