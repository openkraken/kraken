describe('Width', function() {
  it('basic example', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.width = '200px';
    await matchScreenshot();
  });

  describe('element style has width', () => {
    it('element is inline', async () => {
      let element = createElement('div', {
        display: 'inline',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is inline-block', async () => {
      let element = createElement('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is inline-flex', async () => {
      let element = createElement('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is block', async () => {
      let element = createElement('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is flex', async () => {
      let element = createElement('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });
  });

  describe('element style has no width', () => {
    it('parent is inline and grand parent is block', async () => {
      let element = createElement('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElement('div', {
        display: 'block',
        width: '100px',
        backgroundColor: '#333',
      }, [
        createElement('div', {
          display: 'inline'
        }, [
          element,
        ]),
      ]);

      append(BODY, container);
      await matchScreenshot();
    });

    it('parent is inline-block and has width', async () => {
      let element = createElement('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElement('div', {
        display: 'inline-block',
        width: '100px',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchScreenshot();
    });

    it('parent is inline-block and has no width', async () => {
      let element = createElement('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElement('div', {
        display: 'inline-block',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchScreenshot();
    });

    it('parent is block and has width', async () => {
      let element = createElement('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElement('div', {
        display: 'block',
        width: '100px',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchScreenshot();
    });

    it('parent is block and has no width', async () => {
      let element = createElement('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElement('div', {
        display: 'block',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchScreenshot();
    });
  });
});
