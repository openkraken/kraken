describe('Height', () => {
  it('basic example', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.height = '200px';
    await expectAsync(div.toBlob(1)).toMatchImageSnapshot('');
  });

  describe('element style has height', () => {
    it('element is inline', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline',
        height: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is inline-block', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        height: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is inline-flex', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        height: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is block', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        height: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });

    it('element is flex', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        height: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await matchScreenshot();
    });
  });

  describe('element style has no height', () => {
    it('when parent is flex with height and align-items stretch', async () => {

      const container = document.createElement('div');
      setElementStyle(container, {
        width: '200px',
        height: '200px',
        display: 'flex',
        backgroundColor: '#666',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      document.body.appendChild(container);

      const child1 = document.createElement('div');
      setElementStyle(child1, {
        width: '50px',
        backgroundColor: 'blue',
      });
      container.appendChild(child1);
      child1.appendChild(document.createTextNode('block with no height'));

      const child2 = document.createElement('div');
      setElementStyle(child2, {
        width: '50px',
        height: '100px',
        backgroundColor: 'red',
      });
      container.appendChild(child2);

      const child3 = document.createElement('div');
      setElementStyle(child3, {
        width: '50px',
        height: '50px',
        backgroundColor: 'green',
      });
      container.appendChild(child3);

      await matchScreenshot();
    });

    it('when parent is flex with no height and align-items stretch', async () => {
      const container = document.createElement('div');
      setElementStyle(container, {
        width: '200px',
        display: 'flex',
        backgroundColor: '#666',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      document.body.appendChild(container);

      const child1 = document.createElement('div');
      setElementStyle(child1, {
        width: '50px',
        backgroundColor: 'blue',
      });
      container.appendChild(child1);
      child1.appendChild(document.createTextNode('block with no height'));

      const child2 = document.createElement('div');
      setElementStyle(child2, {
        width: '50px',
        height: '100px',
        backgroundColor: 'red',
      });
      container.appendChild(child2);

      const child3 = document.createElement('div');
      setElementStyle(child3, {
        width: '50px',
        height: '50px',
        backgroundColor: 'green',
      });
      container.appendChild(child3);

      await matchScreenshot();
    });

    it('when nested in flex parents with align-items stretch', async () => {
      const container0 = document.createElement('div');
      setElementStyle(container0, {
        width: '300px',
        height: '300px',
        display: 'flex',
        backgroundColor: '#aaa',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      document.body.appendChild(container0);

      const container = document.createElement('div');
      setElementStyle(container, {
        width: '200px',
        display: 'flex',
        backgroundColor: '#666',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      container0.appendChild(container);

      const child1 = document.createElement('div');
      setElementStyle(child1, {
        width: '50px',
        backgroundColor: 'blue',
      });
      container.appendChild(child1);
      child1.appendChild(document.createTextNode('block with no height'));

      const child2 = document.createElement('div');
      setElementStyle(child2, {
        width: '50px',
        height: '100px',
        backgroundColor: 'red',
      });
      container.appendChild(child2);

      const child3 = document.createElement('div');
      setElementStyle(child3, {
        width: '50px',
        height: '50px',
        backgroundColor: 'green',
      });
      container.appendChild(child3);

      await matchScreenshot();
    });
  });
});
