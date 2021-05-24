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
});
