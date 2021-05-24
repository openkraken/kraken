/*auto generated*/
describe('flex-basis', () => {
  it('001', async () => {
    let p;
    let test;
    let ref;
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
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'green',
            height: '100px',
            'flex-basis': '60px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '40px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let test;
    let ref;
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
        (test = createElement('div', {
          id: 'test',
          style: {
            height: '100px',
            'flex-basis': '60px',
            width: '80px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            height: '100px',
            'background-color': 'green',
            width: '40px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-top': '-100px',
        width: '60px',
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
    let test;
    let ref;
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
        (test = createElement('div', {
          id: 'test',
          style: {
            height: '100px',
            'flex-basis': '-50px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            height: '100px',
            'background-color': 'green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-left': '50px',
        'margin-top': '-100px',
        width: '50px',
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
    let test;
    let ref;
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
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'green',
            height: '100px',
            'flex-basis': '-50px',
            width: '30px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-left': '80px',
        'margin-top': '-100px',
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
    let test;
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
          'background-color': 'green',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'red',
            'flex-basis': '0',
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
    let test;
    let ref;
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
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'green',
            height: '100px',
            'flex-basis': 'auto',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  xit('item-margins-001', async () => {
    let p;
    let referenceOverlappedRed;
    let inlineBlock;
    let inlineBlock_1;
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
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        'background-color': 'red',
        width: '100px',
        height: '100px',
        'z-index': '-1',
        'box-sizing': 'border-box',
      },
    });
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          background: 'green',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'margin-right': '21px',
              flex: '0 0 auto',
              'line-height': '0px',
            },
          },
          [
            (inlineBlock = createElement('div', {
              class: 'inline-block',
              style: {
                display: 'inline-block',
                width: '40px',
                height: '50px',
                'box-sizing': 'border-box',
              },
            })),
            (inlineBlock_1 = createElement('div', {
              class: 'inline-block',
              style: {
                display: 'inline-block',
                width: '40px',
                height: '50px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(div);

    await snapshot();
  });


  it("works with flex-basis larger than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '100px',
              width: '200px',
              padding: '10px 0',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis smaller than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '0',
              width: '200px',
              padding: '10px 0',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis not exists and width smaller than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              width: '30px',
              padding: '10px 0',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis larger than content main size in flex column direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '100px',
              height: '200px',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis smaller than content size in flex column direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '0',
              height: '200px',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis not exists and height smaller than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '30px',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
