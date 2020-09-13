describe('Width', function() {
  it('basic example', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.width = '200px';
    await matchViewportSnapshot();
  });

  describe('element style has width', () => {
    it('element is inline', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchViewportSnapshot();
    });

    it('element is inline-block', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchViewportSnapshot();
    });

    it('element is inline-flex', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchViewportSnapshot();
    });

    it('element is block', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchViewportSnapshot();
    });

    it('element is flex', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchViewportSnapshot();
    });
  });

  describe('element style has no width', () => {
    it('parent is inline and grand parent is block', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'block',
        width: '100px',
        backgroundColor: '#333',
      }, [
        createElementWithStyle('div', {
          display: 'inline'
        }, [
          element,
        ]),
      ]);

      append(BODY, container);
      await matchViewportSnapshot();
    });

    it('parent is inline-block and has width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchViewportSnapshot();
    });

    it('parent is inline-block and has no width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'inline-block',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchViewportSnapshot();
    });

    it('parent is block and has width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'block',
        width: '100px',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchViewportSnapshot();
    });

    it('parent is block and has no width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'block',
      }, [
        element,
      ]);

      append(BODY, container);
      await matchViewportSnapshot();
    });

    it('set element\'s width to auto', async () => {
      let container = createElement('div', {
        style: {
          width: '200px',
          background: 'red'
        }
      }, [createText('1234')]);
      BODY.appendChild(container);

      await matchViewportSnapshot();

      container.style.width = 'auto';
      await matchViewportSnapshot();
    });
  });
});
