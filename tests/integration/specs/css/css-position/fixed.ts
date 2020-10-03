describe('Position fixed', () => {
  it('001', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      width: '200px',
      height: '200px',
      backgroundColor: '#999',
      position: 'relative',
      top: '100px',
      left: '100px',
    });
    document.body.appendChild(container1);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'fixed',
      top: '50px',
      left: '50px',
    });
    div1.appendChild(document.createTextNode('fixed element'));
    container1.appendChild(div1);

    await expectAsync(container1.toBlob(1)).toMatchImageSnapshot();
  });

  it('works with scroller container', async (done) => {
    let container = createElement('div',
      {
        style: {
          width: '100px',
          height: '100px',
          overflow: 'scroll',
          backgroundColor: '#999',
        },
      },
      [
        createText('12345'),
        createElement('div', {
          style: {
            width: '50px',
            height: '550px',
            background: 'red',
            top: '50px',
          },
        }),
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            background: 'green',
            position: 'fixed',
            top: '50px',
          },
        }),
      ]
    );
    requestAnimationFrame(async () => {
      container.scroll(0, 200);
      await matchViewportSnapshot();
      done();
    });

    BODY.appendChild(container);
    await matchViewportSnapshot();
  });

  it('hitTest with position fixed elements', async () => {
    let box;
    let clickCount = 0;
    let container = createViewElement({
      width: '200px',
      height: '200px',
      border: '1px solid #000',
      overflow: 'scroll'
    }, [
      box = createElement('div', {
        style: {
          width: '50px',
          height: '50px',
          position: 'fixed',
          background: 'red',
          top: 0
        }
      }),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
      createElement('div', {}, [createText('1234')]),
    ]);

    BODY.appendChild(container);

    box.onclick = () => clickCount++;

    await simulateClick(10, 10);

    container.scrollTop = 20;

    await simulateClick(10, 10);

    expect(clickCount).toBe(2);
  });
});
