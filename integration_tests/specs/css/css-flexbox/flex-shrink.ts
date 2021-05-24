/*auto generated*/
describe('flex-shrink', () => {
  it('001', async () => {
    let p;
    let test1;
    let test2;
    let container;
    let cover;
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
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '100px',
            'flex-shrink': '2',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'green',
            'flex-shrink': '3',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        position: 'relative',
        'background-color': 'green',
        height: '100px',
        top: '-100px',
        width: '60px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let test1;
    let test2;
    let container;
    let cover;
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
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '100px',
            'flex-shrink': '-2',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'green',
            'flex-shrink': '-3',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        position: 'relative',
        'background-color': 'green',
        height: '100px',
        top: '-100px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let test1;
    let test2;
    let container;
    let cover;
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
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'green',
            'flex-shrink': '4',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        position: 'relative',
        'background-color': 'green',
        height: '100px',
        top: '-100px',
        width: '80px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let test1;
    let test2;
    let container;
    let cover;
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
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '40px',
            'flex-shrink': '2',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '40px',
            'flex-shrink': '3',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        position: 'relative',
        'background-color': 'green',
        height: '100px',
        'margin-left': '80px',
        top: '-100px',
        width: '20px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('005', async () => {
    let p;
    let test1;
    let test2;
    let container;
    let cover;
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
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '50px',
            'flex-shrink': '0',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '50px',
            'background-color': 'green',
            'flex-shrink': '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        position: 'relative',
        'background-color': 'green',
        height: '100px',
        top: '-100px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('006', async () => {
    let p;
    let test1;
    let test2;
    let test3;
    let test4;
    let container;
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
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'green',
            'flex-shrink': '0',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'black',
            'flex-shrink': '3',
            'box-sizing': 'border-box',
          },
        })),
        (test3 = createElement('div', {
          id: 'test3',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'blue',
            'flex-shrink': '2',
            'box-sizing': 'border-box',
          },
        })),
        (test4 = createElement('div', {
          id: 'test4',
          style: {
            height: '100px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('007', async () => {
    let p;
    let test1;
    let test2;
    let container;
    let cover;
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
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-shrink': '2',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        position: 'relative',
        'background-color': 'green',
        height: '100px',
        top: '-100px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('008', async () => {
    let p;
    let test1;
    let container;
    let container_1;
    let test2;
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
    container = createElement(
      'div',
      {
        class: 'container',
        style: {
          background: 'red',
          height: '50px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement(
          'div',
          {
            id: 'test1',
            style: {
              display: 'flex',
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                background: 'green',
                height: '50px',
                'flex-shrink': '0.9',
                width: '550px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    container_1 = createElement(
      'div',
      {
        class: 'container',
        style: {
          background: 'red',
          height: '50px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test2 = createElement(
          'div',
          {
            id: 'test2',
            style: {
              display: 'flex',
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                background: 'green',
                height: '50px',
                'flex-shrink': '0.25',
                width: '75px',
                'box-sizing': 'border-box',
              },
            }),
            createElement('div', {
              style: {
                background: 'green',
                height: '50px',
                'flex-shrink': '0.25',
                width: '75px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(container_1);

    await snapshot();
  });
});
