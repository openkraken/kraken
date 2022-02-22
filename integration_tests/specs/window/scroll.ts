describe('window scroll API', () => {
  it('scrollTo', async (doneFn) => {
    let div = document.createElement('div');
    div.style.border = '2px solid #000';
    div.style.height = '1000px';
    div.style.width = '50px';
    let text = document.createTextNode('This text should half visible');
    div.appendChild(text);
    document.body.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      window.scrollTo(0, 55);
      await snapshot();
      expect(window.scrollX).toBe(0);
      expect(window.scrollY).toBe(55);
      doneFn();
    });
  });

  it('scroll', async (doneFn) => {
    let div = document.createElement('div');
    div.style.border = '2px solid #000';
    div.style.height = '1000px';
    div.style.width = '50px';
    let text = document.createTextNode('This text should half visible');
    div.appendChild(text);
    document.body.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      window.scroll(0, 40);
      await snapshot();

      expect(window.scrollX).toBe(0);
      expect(window.scrollY).toBe(40);
      doneFn();
    });
  });

  it('scrollBy', async (doneFn) => {
    let div = document.createElement('div');
    div.style.border = '2px solid #000';
    div.style.height = '1000px';
    div.style.width = '50px';
    let text = document.createTextNode('This text should half visible');
    div.appendChild(text);
    document.body.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      window.scroll(0, 5);
      window.scrollBy(0, 20);
      await snapshot();

      expect(window.scrollX).toBe(0);
      expect(window.scrollY).toBe(25);
      doneFn();
    });
  });

  it('document scroll should bubble to window', async (done) => {
    const container = document.createElement('div');

    for (let i = 0; i < 100; i++) {
      const item = document.createElement('div');
      Object.assign(item.style, {
        height: '145px',
        background: 'red',
        marginBottom: '10px',
      });
      container.appendChild(item);
    }
    document.body.appendChild(container);

    function scrollListener() {
      done();
    }

    window.addEventListener('scroll', scrollListener);

    requestAnimationFrame(async () => window.scrollTo(0, 100));
  });
});
