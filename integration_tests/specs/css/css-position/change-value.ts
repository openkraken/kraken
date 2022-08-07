describe('CSS Position', () => {
  it('change from non-null to null', async () => {
    var el = document.createElement('div');
    document.body.appendChild(el);
    el.style.width = '100px';
    el.style.height = '100px';
    el.style.background = 'red';
    el.style.position = 'relative';
    el.style.left = '50px';

    await snapshot();

    el.style.position = null;
    await snapshot();
  });
});
