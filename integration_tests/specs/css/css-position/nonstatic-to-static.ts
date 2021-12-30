describe('Position non-static', () => {
  it('to static', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '400px',
      height: '400px',
      marginBottom: '20px',
      backgroundColor: '#999',
      position: 'relative',
    });
    document.body.appendChild(container);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'absolute',
      top: '100px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('absolute to static'));
    container.appendChild(div1);

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      position: 'relative',
      top: '50px',
      left: '100px',
    });
    div2.appendChild(document.createTextNode('relative to static'));
    container.appendChild(div2);

    const div3 = document.createElement('div');
    setElementStyle(div3, {
      width: '100px',
      height: '100px',
      backgroundColor: 'green',
      position: 'fixed',
      top: '200px',
      left: '200px',
    });
    div3.appendChild(document.createTextNode('fixed to static'));
    container.appendChild(div3);

    const div4 = document.createElement('div');
    setElementStyle(div4, {
      width: '100px',
      height: '100px',
      backgroundColor: 'yellow',
      position: 'sticky',
      top: '50px',
    });
    div4.appendChild(document.createTextNode('sticky to static'));
    container.appendChild(div4);

    await snapshot();

    div1.style.position = 'static';
    div2.style.position = 'static';
    div3.style.position = 'static';
    div4.style.position = 'static';

    await snapshot();
  });

  it('children should reposition when parent position changed from relative to static', async (done) => {
    let div;
    let item1;
    let item2;
    div = createElement(
      'div',
      {
        style: {
          position: 'relative',
          width: '200px',
          height: '100px',
          display: 'flex',
          flexDirection: 'row',
          backgroundColor: 'green',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            position: 'relative',
            margin: '30px',
            width: '100px',
            height: '50px',
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
              style: {} 
          }, [
            (item2 = createElement('div', {
              style: {
                  position: 'absolute',
                  top: 0, 
                  left: 0,
                  width: '30px',
                  height: '30px',
                  backgroundColor: 'red'
              }
            })),
          ])
        ])),
      ]
    );

    BODY.appendChild(div);

    requestAnimationFrame(async () => {
      item1.style.position = 'static';
      await snapshot();
      done();
    });
  });
});
