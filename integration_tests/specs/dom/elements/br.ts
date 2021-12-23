describe('br-element', () => {
  it('basic', async () => {
    const p = <p> Hello World! <br /> 你好，世界！</p>;
    document.body.appendChild(p);
    await snapshot();
  });

  it('should work with one BR element follows a display block element', async () => {
    const div = createElement('div',{
      style: {
        fontSize: '24px'
      }
    }, [
      createElement('div', {
        style: {}
      }, [
        createText('Hello'),
      ]),
      createElement('br', {
        style: {}
      }),
      createText('world'),
    ]);
    document.body.appendChild(div);
    await snapshot();
  });

  it('should work with one BR element follows a text node in flow layout', async () => {
    const div = createElement('div',{
      style: {
        fontSize: '24px'
      }
    }, [
      createText('Hello'),
      createElement('br', {
        style: {}
      }),
      createText('world'),
    ]);
    document.body.appendChild(div);
    await snapshot();
  });

  it('should work with one BR element in flex layout', async () => {
    const div = createElement('div',{
      style: {
        fontSize: '24px',
        display: 'flex',
        flexDirection: 'column'
      }
    }, [
      createElement('span', {
        style: {}
      }, [
        createText('Hello'),
      ]),
      createElement('br', {
        style: {}
      }),
      createText('world'),
    ]);
    document.body.appendChild(div);
    await snapshot();
  });

  it('should work with multiple BR elements follows a text node', async () => {
    const div = createElement('div',{
      style: {
        fontSize: '24px'
      }
    }, [
      createText('Hello'),
      createElement('br', {
        style: {}
      }),
      createElement('br', {
        style: {}
      }),
      createElement('br', {
        style: {}
      }),
      createElement('br', {
        style: {}
      }),
      createText('world'),
    ]);
    document.body.appendChild(div);
    await snapshot();
  });

  it('should not work with styles on BR', async () => {
    const div = createElement('div',{
      style: {
        fontSize: '24px'
      }
    }, [
      createElement('br', {
        style: {
          width: '100px',
          height: '100px',
          margin: '100px',
          backgroundColor: 'green'
        }
      }),
      createText('Hello '),
      createText('world'),
    ]);
    document.body.appendChild(div);
    await snapshot();
  });
});
