/*auto generated*/
describe('flexbox-position-absolute', () => {
  it('004', async () => {
    let item;
    let flex;
    flex = createElement(
      'div',
      {
        id: 'flex',
        style: {
          display: 'flex',
          position: 'relative',
          background: 'red',
          width: '500px',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (item = createElement('div', {
          id: 'item',
          'data-expected-width': '500',
          style: {
            position: 'absolute',
            background: 'green',
            left: '0',
            right: '0',
            top: '0',
            bottom: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(flex);

    await snapshot();
  });
  it('007', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
          display: 'flex',
          'align-items': 'center',
          background: 'red',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '100px',
            'box-sizing': 'border-box',
            position: 'absolute',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('010', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
          position: 'relative',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '100px',
              width: '100px',
              'box-sizing': 'border-box',
              display: 'flex',
              'align-items': 'center',
              background: 'red',
            },
          },
          [
            createElement('div', {
              style: {
                height: '100px',
                width: '100px',
                'box-sizing': 'border-box',
                position: 'absolute',
                background: 'green',
                display: 'grid',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('015', async () => {
    let abspos;
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          width: '200px',
          height: '100px',
          'justify-content': 'flex-end',
          border: '1px solid black',
          position: 'relative',
        },
      },
      [
        (abspos = createElement('div', {
          'data-offset-x': '150',
          id: 'abspos',
          style: {
            'box-sizing': 'border-box',
            background: 'cyan',
            margin: '20px',
            position: 'absolute',
            width: '30px',
            height: '40px',
          },
        })),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('should works with image of position absolute and self no height', async () => {
    const div = createElement('div', {
       style: {
           display: 'flex',
           backgroundColor: 'yellow',
           position: 'relative',
           overflow: 'hidden',
       }
    }, [
        createElement('img', {
            src: 'assets/100x100-green.png',
            style: {
                position: 'absolute',
                height: '200px'
             }
        }),
        createElement('div', {
            style: {
                display: 'flex',
                width: '50px',
                padding: '20px 0',
                position: 'relative'
            }
        })
    ]);
    document.body.appendChild(div);

    await snapshot(0.1);
  });

  it('should works with child of position absolute and self no height', async () => {
    const div = createElement('div', {
       style: {
           display: 'flex',
           alignItems: 'center',
           backgroundColor: 'yellow',
           position: 'relative',
           overflow: 'hidden',
       }
    }, [
        createElement('div', {
            style: {
                position: 'absolute',
                width: '200px',
                height: '200px',
                backgroundColor: 'green'
             }
        }),
        createElement('div', {
            style: {
                width: '200px',
                padding: '150px 0',
                position: 'relative'
            }
        })
    ]);
    document.body.appendChild(div);

    await snapshot();
  });
});
