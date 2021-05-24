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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
  });
  it('006', async () => {
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
  });
  it('010', async () => {
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
                  'font-size': '20px',
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
                  'font-size': '10px',
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
                  'font-size': '30px',
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
                  'font-size': '15px',
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
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

    await snapshot();
  });

  xit("015-ref", async () => {
    let p;
    let item1;
    let item2;
    let item2_1;
    let item2_2;
    let item2_3;
    let item2_4;
    let item2_5;
    let item2_6;
    let item2_7;
    let item2_8;
    let item2_9;
    let item2_10;
    let item2_11;
    let item2_12;
    let item2_13;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `The test passes if the flex items are properly centered in each column`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        class: 'flexbox column wrap',
        style: {
          border: '1px solid black',
          width: '400px',
          height: '200px',
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          '-webkit-flex-wrap': 'wrap',
          'flex-wrap': 'wrap',
          'box-sizing': 'border-box',
        },
      },
      [
        (item1 = createElement(
          'div',
          {
            class: 'item1 align-self-center',
            style: {
              background: 'lightblue',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithMargins`)]
        )),
        (item2 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_1 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_2 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_3 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_4 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_5 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_6 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_7 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_8 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_9 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_10 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_11 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_12 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
        (item2_13 = createElement(
          'div',
          {
            class: 'item2 align-self-center',
            style: {
              background: 'lime',
              '-webkit-align-self': 'center',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`centeredWithAlignSelf`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);


    await snapshot();
  })

  it("should work with center when flex-direction is column and flex-wrap is wrap", async () => {
    let p;
    let div;
    let div_1;
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
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        position: 'absolute',
        width: '100px',
        height: '100px',
        background: 'green',
      },
    });
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '100px',
          'line-height': '20px',
          'align-content': 'flex-start',
          background: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'red',
              height: '50px',
              'max-width': '100px',
              'align-self': 'center',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'green',
              height: '50px',
              'width': '50px',
              'align-self': 'center',
            },
          },
        ),
      ]
    );

    BODY.appendChild(div_1);


    await snapshot();
  })

  it("should work with center when flex-direction is column and flex-wrap is nowrap", async () => {
    let p;
    let div;
    let div_1;
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
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        position: 'absolute',
        width: '100px',
        height: '100px',
        background: 'green',
      },
    });
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'nowrap',
          width: '200px',
          height: '100px',
          'line-height': '20px',
          'align-content': 'flex-start',
          background: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'red',
              height: '50px',
              'max-width': '100px',
              'align-self': 'center',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'green',
              height: '50px',
              'width': '50px',
              'align-self': 'center',
            },
          },
        ),
      ]
    );

    BODY.appendChild(div_1);


    await snapshot();
  })
  it("should work with center when flex-direction is row and flex-wrap is wrap", async () => {
    let p;
    let div;
    let div_1;
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
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        position: 'absolute',
        width: '100px',
        height: '100px',
        background: 'green',
      },
    });
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'row',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '100px',
          'line-height': '20px',
          'align-content': 'flex-start',
          background: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'red',
              height: '50px',
              'max-width': '100px',
              'align-self': 'center',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'green',
              height: '80px',
              'width': '50px',
              'align-self': 'center',
            },
          },
        ),
      ]
    );

    BODY.appendChild(div_1);


    await snapshot();
  })

  it("should work with center when flex-direction is row and flex-wrap is nowrap", async () => {
    let p;
    let div;
    let div_1;
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
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        position: 'absolute',
        width: '100px',
        height: '100px',
        background: 'green',
      },
    });
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'row',
          'flex-wrap': 'nowrap',
          width: '200px',
          height: '100px',
          'line-height': '20px',
          'align-content': 'flex-start',
          background: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'red',
              height: '50px',
              'max-width': '100px',
              'align-self': 'center',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '50px',
                display: 'inline-block',
              },
            }),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'green',
              height: '80px',
              'width': '50px',
              'align-self': 'center',
            },
          },
        ),
      ]
    );

    BODY.appendChild(div_1);


    await snapshot();
  });

  it('change from center to flex-end', async (done) => {
    let foo;
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          height: '100px',
          width: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
        }
      }, [
          (foo = createElement('div', {
            style: {
              alignSelf: 'center',
              height: '50px',
              width: '50px',
              backgroundColor: 'red'
            }
          }))
      ]
    );
    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      foo.style.alignSelf = 'flex-end';
      await snapshot(0.1);
      done();
    });
  });
});
