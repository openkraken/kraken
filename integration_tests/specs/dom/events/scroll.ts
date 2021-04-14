describe('Event scroll', () => {
  it('should work basic', async (done) => {
    const container = document.createElement('div');
    Object.assign(container.style, {
      height: '100px',
      overflow: 'auto',
    });

    for (var i = 0; i < 9; i ++) {
      const item = document.createElement('div');
      Object.assign(item.style, {
        height: '45px',
        background: 'red',
        marginBottom: '10px',
      });
      container.appendChild(item);
    }
    document.body.appendChild(container);

    function scrollListener(event) {
      if (event.currentTarget.scrollTop === 50) {
        container.removeEventListener('scroll', scrollListener);
        snapshot().then(() => done());
      }
    }

    container.addEventListener('scroll', scrollListener);
    container.scrollTo(0, 50);
  });
});