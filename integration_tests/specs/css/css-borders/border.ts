/*auto generated*/
describe('border', () => {
  it('001', async () => {
    let div;
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '25px',
        'border-style': 'solid',
        'border-color': '#000',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await matchViewportSnapshot(0.1);
  });
  it('003', async () => {
    let div;
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-color': 'blue',
        'border-style': 'solid',
        'border-width': '5px',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await matchViewportSnapshot(0.1);
  });
  xit('005', async () => {
    let reference;
    let test;
    let wrapper;
    wrapper = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'wrapper',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (reference = createElement('div', {
          id: 'reference',
          style: {
            position: 'absolute',
            background: 'red',
            height: '200px',
            left: '0',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (test = createElement('div', {
          id: 'test',
          style: {
            position: 'relative',
            border: '100px solid blue',
            height: '0',
            width: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(wrapper);

    await matchViewportSnapshot(0.1);
  });
  xit('006', async () => {
    let reference;
    let test;
    let wrapper;
    wrapper = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'wrapper',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (reference = createElement('div', {
          id: 'reference',
          style: {
            position: 'absolute',
            background: 'red',
            height: '200px',
            left: '0',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (test = createElement('div', {
          id: 'test',
          style: {
            position: 'relative',
            border: '100px solid #000',
            height: '0',
            width: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(wrapper);

    await matchViewportSnapshot(0.1);
  });
  it('008', async () => {
    let reference;
    let test;
    let wrapper;
    wrapper = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'wrapper',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (reference = createElement('div', {
          id: 'reference',
          style: {
            position: 'absolute',
            background: 'red',
            height: '200px',
            left: '0',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (test = createElement('div', {
          id: 'test',
          style: {
            position: 'relative',
            border: '100px solid blue',
            height: '0',
            width: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(wrapper);

    await matchViewportSnapshot(0.1);
  });
  it('010', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a box below with a dashed blue border.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '5px solid blue',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await matchViewportSnapshot(0.1);
  });

  it('border will not appear if border width is 0.0', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are no solid border.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderWidth: 0,
        borderStyle: 'solid',
        borderColor: '#000',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await matchViewportSnapshot(0.1);
  });

  it('borderSide should handle hitTest', async () => {
    let clickCount = 0;
    let container = createElement('div', {
      style: {
        width: '20px',
        height: '20px',
        border: '5px solid #000'
      }
    }, [
    ]);

    BODY.appendChild(container);
    container.onclick = () => clickCount++;
    await simulateClick(1.0, 1.0);
    expect(clickCount).toBe(1);
  });

  it('marginSide should not handle hitTest', async () => {
    let clickCount = 0;
    let container = createElement('div', {
      style: {
        width: '20px',
        height: '20px',
        margin: '10px',
        border: '2px solid #000'
      }
    });

    BODY.appendChild(container);
    container.onclick = () => clickCount++;

    await simulateClick(1.0, 1.0);
    await simulateClick(11.0, 11.0);
    expect(clickCount).toBe(1);
  });

  it('should work with border-width change', async (done) => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'red',
          position: 'relative',
          border: '2px solid black'
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '100px',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();

    requestAnimationFrame(async () => {
       div.style.borderWidth = '10px';
      await matchViewportSnapshot(0.1);
      done();
    });
  });
});
