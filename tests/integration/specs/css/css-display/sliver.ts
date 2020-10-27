describe('display sliver', () => {
  function createSliverBasicCase() {
    var d = document.createElement('div');

    for (var i = 0; i < 100; i ++) {
      var e = document.createElement('div');
      e.style.background = 'red';
      e.style.width = e.style.height = '99px';
      e.appendChild(document.createTextNode(i + ''));
      d.appendChild(e);
    }

    d.style.display = 'sliver';
    d.style.width = '100px';
    d.style.height = '150px';

    document.body.appendChild(d);

    return d;
  }

  it('basic', async () => {
    createSliverBasicCase();
    await matchViewportSnapshot();
  });

  it('sliver-direction', async () => {
    const container = createSliverBasicCase();
    (container.style as any).sliverDirection = 'column';

    await matchViewportSnapshot();
  });

  it('scroll works', async (done) => {
    const container = createSliverBasicCase();

    await simulateSwipe(1, 60, 1, 0, 0.1);
    await matchViewportSnapshot();
  });
});