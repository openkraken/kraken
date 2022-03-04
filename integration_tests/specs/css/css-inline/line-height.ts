describe('line-height', () => {
  it('with unit of px', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createText(`line height 100px`),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with unit of number', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '3',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createText(`line height 3`),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with block element', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              lineHeight: '2',
              'box-sizing': 'border-box',
              'backgroundColor': 'blue',
              fontSize: '16px',
              width: '200px',
              height: '50px',
            },
          }, [
            createText(`line height 2`),
          ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with inline element', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              lineHeight: '2',
              'box-sizing': 'border-box',
              'backgroundColor': 'blue',
              fontSize: '16px',
              width: '200px',
              height: '50px',
            },
          }, [
            createText(`line height 2`),
          ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with line-height smaller than height of inline-block element', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '20px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'backgroundColor': 'yellow',
              width: '200px',
              height: '50px',
            },
          })
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with flex item', async () => {
    const div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              lineHeight: '2',
              'box-sizing': 'border-box',
              'backgroundColor': 'blue',
              fontSize: '16px',
              width: '200px',
              height: '50px',
            },
          }, [
            createText(`line height 2`),
          ]),
        createElement(
          'div',
          {
            style: {
              lineHeight: '2',
              'box-sizing': 'border-box',
              'backgroundColor': 'red',
              fontSize: '16px',
              width: '200px',
              height: '50px',
            },
          }, [
            createText(`line height 2`),
          ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with multiple lines', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'line-height': '100px',
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              lineHeight: '2',
              'box-sizing': 'border-box',
              'backgroundColor': 'blue',
              fontSize: '16px',
              width: '200px',
              height: '50px',
            },
          }, [
            createText(`line height 2`),
          ]),
        createElement(
          'div',
          {
            style: {
              lineHeight: '2',
              'box-sizing': 'border-box',
              'backgroundColor': 'red',
              fontSize: '16px',
              width: '200px',
              height: '50px',
            },
          }, [
            createText(`line height 2`),
          ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('works with text of multiple lines', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          fontFamily: 'Songti SC',
          fontSize: '16px',
          backgroundColor: 'green',
          lineHeight: '30px',
        },
      },
      [
        createText('The line-height CSS property sets the height of a line box. Its commonly used to set the distance between lines of text. On block-level elements, it specifies the minimum height of line boxes within the element. On non-replaced inline elements, it specifies the height that is used to calculate line box height.')
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
            fontSize: '20px',
            lineHeight: '500%',
          }
        }, [
          createText('Kraken')
        ])
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage after element is attached', async (done) => {
    let div2;

    div2 = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        backgroundColor: 'green',
        fontSize: '16px',
      }
    }, [
      createText('percentage line height works. ')
    ]);

    BODY.appendChild(div2);

    await snapshot();

    requestAnimationFrame(async () => {
      div2.style.lineHeight = '200%';
      await snapshot();
      done();
    });
  });

  it('works with inheritance', async (done) => {
    let div1;
    let div2;
    let div = createElement('div', {
      style: {
        position: 'relative',
        width: '300px',
        height: '200px',
        backgroundColor: 'grey',
      }
    }, [
      (div1 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightgreen',
        }
      }, [
        createText('inherited line-height')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          lineHeight: 1,
        }
      }, [
        createText('not inherited line-height')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        lineHeight: '40px'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.lineHeight = '80px';
      await snapshot();
      done();
    });
  });
});
