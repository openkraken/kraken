// https://drafts.csswg.org/css-env-1/#env-function
describe('CSS Environment', () => {
  it('work with safe-area-inset', async () => {
      const container = document.createElement('div');
      const paddings = [
        'env(safe-area-inset-top)',
        'env(safe-area-inset-right)',
        'env(safe-area-inset-bottom)',
        'env(safe-area-inset-left)',
      ];
      container.style.padding = paddings.join(' ');
      container.style.background = 'red';
      document.body.appendChild(document.createTextNode('PASS if no red appears.'));
      document.body.appendChild(container);
      await snapshot();
  });

  it('work with safe-area-inset fallback', async () => {
      const container = document.createElement('div');
      // Env has value, so not fallback to other.
      const paddings = [
        'env(safe-area-inset-top, 50px)',
        'env(safe-area-inset-right, 40px)',
        'env(safe-area-inset-bottom, 30px)',
        'env(safe-area-inset-left, 20px)',
      ];
      container.style.padding = paddings.join(' ');
      container.style.background = 'red';
      document.body.appendChild(document.createTextNode('PASS if no red appears.'));
      document.body.appendChild(container);
      await snapshot();
  });
});
