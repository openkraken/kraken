/*auto generated*/
describe('align-self', () => {
  xit('001', async () => {
    let test;
    let cover;
    test = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'flex-start',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'flex-start',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'flex-start',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'flex-start',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    cover = createElement('div', {
      style: {
        'background-color': 'green',
        height: '50px',
        'margin-top': '-50px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(test);
    BODY.appendChild(cover);

    await matchViewportSnapshot();
  });
  xit('002', async () => {
    let test;
    let cover;
    test = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'flex-end',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'flex-end',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'flex-end',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'flex-end',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    cover = createElement('div', {
      style: {
        'background-color': 'green',
        height: '50px',
        'margin-top': '-100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(test);
    BODY.appendChild(cover);

    await matchViewportSnapshot();
  });
  it('004', async () => {
    let test;
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'center',
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'green',
            width: '25px',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'green',
            width: '25px',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'green',
            width: '25px',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'green',
            width: '25px',
          },
        }),
      ]
    );
    BODY.appendChild(test);

    await matchViewportSnapshot();
  });
  it('005', async () => {
    let p;
    let test;
    let cover;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and`),

        createText(`.`),
      ]
    );
    test = createElement(
      'div',
      {
        style: {
          'background-color': 'green',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'red',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'red',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'red',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'stretch',
            'background-color': 'red',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    cover = createElement('div', {
      style: {
        'background-color': 'green',
        height: '50px',
        position: 'relative',
        top: '-100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(cover);

    await matchViewportSnapshot();
  });
  xit('006', async () => {
    let p;
    let div1;
    let div2;
    let div3;
    let div4;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if the underline of all 'a' characters within black border box is horizontal and no breaking.`
        ),
      ]
    );
    test = createElement(
      'div',
      {
        style: {
          border: '1px solid black',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            style: {
              'align-self': 'baseline',
              height: '90px',
              'font-size': '20px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaa`)]
        )),
        (div2 = createElement(
          'div',
          {
            style: {
              'align-self': 'baseline',
              height: '50px',
              'font-size': '10px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaaaa`)]
        )),
        (div3 = createElement(
          'div',
          {
            style: {
              'align-self': 'baseline',
              height: '100px',
              'font-size': '30px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aa`)]
        )),
        (div4 = createElement(
          'div',
          {
            style: {
              'align-self': 'baseline',
              height: '80px',
              'font-size': '15px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaa`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await matchViewportSnapshot();
  });
  xit('007', async () => {
    let test;
    let cover;
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'flex-start',
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    cover = createElement('div', {
      style: {
        'background-color': 'green',
        height: '50px',
        'margin-top': '-50px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(test);
    BODY.appendChild(cover);

    await matchViewportSnapshot();
  });
  xit('008', async () => {
    let p;
    let test;
    let cover;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and`),
        createText(`.`),
      ]
    );
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'flex-end',
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    cover = createElement('div', {
      style: {
        'background-color': 'green',
        height: '50px',
        'margin-top': '-100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(cover);

    await matchViewportSnapshot();
  });
  xit('009', async () => {
    let p;
    let test;
    let top;
    let bottom;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and`),
        createText(`.`),
      ]
    );
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'center',
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    top = createElement('div', {
      style: {
        'background-color': 'green',
        'margin-top': '-100px',
        height: '25px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    bottom = createElement('div', {
      style: {
        'background-color': 'green',
        height: '25px',
        'margin-top': '50px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(top);
    BODY.appendChild(bottom);

    await matchViewportSnapshot();
  });
  xit('010', async () => {
    let p;
    let div1;
    let div2;
    let div3;
    let div4;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if the underline of all 'a' characters within black border box is horizontal and no breaking.`
        ),
      ]
    );
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'baseline',
          border: '1px solid black',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            style: {
              'align-self': 'auto',
              height: '90px',
              'font-size': '20px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'a',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`aaa`)]
            ),
          ]
        )),
        (div2 = createElement(
          'div',
          {
            style: {
              'align-self': 'auto',
              height: '50px',
              'font-size': '10px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'a',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`aaaaa`)]
            ),
          ]
        )),
        (div3 = createElement(
          'div',
          {
            style: {
              'align-self': 'auto',
              height: '100px',
              'font-size': '30px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'a',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`aa`)]
            ),
          ]
        )),
        (div4 = createElement(
          'div',
          {
            style: {
              'align-self': 'auto',
              height: '80px',
              'font-size': '15px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'a',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`aaa`)]
            ),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await matchViewportSnapshot();
  });
  it('011', async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and`),
        createText(`.`),
      ]
    );
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'stretch',
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'align-self': 'auto',
            'background-color': 'green',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await matchViewportSnapshot();
  });
  it('012', async () => {
    let p;
    let auto;
    let auto_1;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and`),
        createText(`.`),
      ]
    );
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'stretch',
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (auto = createElement('div', {
          style: {
            'background-color': 'green',
            width: '25px',
            'align-self': 'auto',
            'box-sizing': 'border-box',
          },
        })),
        (auto_1 = createElement('div', {
          style: {
            'background-color': 'green',
            width: '25px',
            'align-self': 'auto',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await matchViewportSnapshot();
  });
  xit('013', async () => {
    let test;
    let cover;
    test = createElement(
      'div',
      {
        style: {
          'align-items': 'flex-start',
          'align-self': 'flex-end',
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    cover = createElement('div', {
      style: {
        'background-color': 'green',
        height: '50px',
        'margin-top': '-50px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(test);
    BODY.appendChild(cover);

    await matchViewportSnapshot();
  });
});
