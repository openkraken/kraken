/*auto generated*/
describe('align-content', () => {
  it('001', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          'align-content': 'center',
          display: 'flex',
          'flex-direction': 'row',
          'flex-wrap': 'wrap',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('002', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          'align-content': 'flex-start',
          display: 'flex',
          'flex-wrap': 'wrap',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is no red visible on the page.`)]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          'align-content': 'flex-end',
          display: 'flex',
          'flex-wrap': 'wrap',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '26px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is no red visible on the page.`)]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          'align-content': 'space-between',
          display: 'flex',
          'flex-wrap': 'wrap',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '21px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '21px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '21px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '21px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('005', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is no red visible on the page.`)]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          'align-content': 'space-around',
          display: 'flex',
          'flex-wrap': 'wrap',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '22px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '22px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '22px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '22px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('006', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is no red visible on the page.`)]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          'align-content': 'stretch',
          display: 'flex',
          'flex-wrap': 'wrap',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('wrap-001', async () => {
    let log;
    let box;
    let box_1;
    let box_2;
    let box_3;
    let box_4;
    let box_5;
    let box_6;
    log = createElement('div', {
      style: {
        'box-sizing': 'border-box',
      },
    });
    box = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          height: '70px',
          border: '1px solid red',
          margin: '5px',
          'box-sizing': 'border-box',
          'align-content': 'flex-start',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`This text should be at the top of its container`)]
        ),
      ]
    );
    box_1 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          height: '70px',
          border: '1px solid red',
          margin: '5px',
          'box-sizing': 'border-box',
          'align-content': 'flex-end',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`This text should be at the bottom of its container`)]
        ),
      ]
    );
    box_2 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          height: '70px',
          border: '1px solid red',
          margin: '5px',
          'box-sizing': 'border-box',
          'align-content': 'center',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`This text should be centered in its container`)]
        ),
      ]
    );
    box_3 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          height: '70px',
          border: '1px solid red',
          margin: '5px',
          'box-sizing': 'border-box',
          'align-content': 'space-between',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`This text should be at the top of its container`)]
        ),
      ]
    );
    box_4 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          height: '70px',
          border: '1px solid red',
          margin: '5px',
          'box-sizing': 'border-box',
          'align-content': 'space-around',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`This text should be centered in its container`)]
        ),
      ]
    );
    box_5 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          height: '70px',
          border: '1px solid red',
          margin: '5px',
          'box-sizing': 'border-box',
          'align-content': 'space-evenly',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`This text should be centered in its container`)]
        ),
      ]
    );
    box_6 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          height: '70px',
          border: '1px solid red',
          margin: '5px',
          'box-sizing': 'border-box',
          'align-content': 'stretch',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '20px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`This text should be at the top of its container`)]
        ),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(box);
    BODY.appendChild(box_1);
    BODY.appendChild(box_2);
    BODY.appendChild(box_3);
    BODY.appendChild(box_4);
    BODY.appendChild(box_5);
    BODY.appendChild(box_6);

    await snapshot();
  });
  it('wrap-002', async () => {
    let content1Horizontal;
    let content1Horizontal_1;
    let content1Horizontal_2;
    let content1Horizontal_3;
    let itemHorizontal;
    let itemHorizontal_1;
    let itemHorizontal_2;
    let itemHorizontal_3;
    let itemHorizontal_4;
    let itemHorizontal_5;
    let itemHorizontal_6;
    let itemHorizontal_7;
    let itemHorizontal_8;
    let itemHorizontal_9;
    let itemHorizontal_10;
    let content2Horizontal;
    let content2Horizontal_1;
    let content2Horizontal_2;
    let content2Horizontal_3;
    let content3Horizontal;
    let content3Horizontal_1;
    let content3Horizontal_2;
    let flexHorizontal;
    let flexHorizontal_1;
    let flexHorizontal_2;
    let content1Vertical;
    let itemVertical;
    let itemVertical_1;
    let itemVertical_2;
    let content2Vertical;
    let content3Vertical;
    let flexVertical;
    flexHorizontal = createElement(
      'div',
      {
        style: {
          width: '400px',
          display: 'flex',
          height: '100px',
          'background-color': 'gray',
          'margin-bottom': '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (itemHorizontal = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content1Horizontal = createElement('div', {
              style: {
                width: '70px',
                height: '150px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_1 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content2Horizontal = createElement('div', {
              style: {
                width: '70px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_2 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content3Horizontal = createElement('div', {
              style: {
                width: '70px',
                height: '50px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    flexHorizontal_1 = createElement(
      'div',
      {
        style: {
          width: '400px',
          display: 'flex',
          height: '100px',
          'background-color': 'gray',
          'margin-bottom': '100px',
          'box-sizing': 'border-box',
          'flex-wrap': 'wrap',
        },
      },
      [
        (itemHorizontal_3 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content1Horizontal_1 = createElement('div', {
              style: {
                width: '70px',
                height: '150px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_4 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content2Horizontal_1 = createElement('div', {
              style: {
                width: '70px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_5 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content3Horizontal_1 = createElement('div', {
              style: {
                width: '70px',
                height: '50px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    flexHorizontal_2 = createElement(
      'div',
      {
        style: {
          width: '400px',
          display: 'flex',
          height: '100px',
          'background-color': 'gray',
          'margin-bottom': '100px',
          'box-sizing': 'border-box',
          'flex-wrap': 'wrap',
        },
      },
      [
        (itemHorizontal_6 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content1Horizontal_2 = createElement('div', {
              style: {
                width: '70px',
                height: '150px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_7 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content2Horizontal_2 = createElement('div', {
              style: {
                width: '70px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_8 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content3Horizontal_2 = createElement('div', {
              style: {
                width: '70px',
                height: '50px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_9 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content1Horizontal_3 = createElement('div', {
              style: {
                width: '70px',
                height: '150px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemHorizontal_10 = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content2Horizontal_3 = createElement('div', {
              style: {
                width: '70px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    flexVertical = createElement(
      'div',
      {
        style: {
          width: '100px',
          display: 'flex',
          'flex-direction': 'column',
          height: '600px',
          'background-color': 'gray',
          'margin-top': '200px',
          'margin-bottom': '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (itemVertical = createElement(
          'div',
          {
            style: {
              height: '150px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content1Vertical = createElement('div', {
              style: {
                width: '150px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemVertical_1 = createElement(
          'div',
          {
            style: {
              height: '150px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content2Vertical = createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (itemVertical_2 = createElement(
          'div',
          {
            style: {
              height: '150px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content3Vertical = createElement('div', {
              style: {
                width: '50px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(flexHorizontal);
    BODY.appendChild(flexHorizontal_1);
    BODY.appendChild(flexHorizontal_2);
    BODY.appendChild(flexVertical);

    await snapshot();
  });
  it('wrap-003', async () => {
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
    let flexbox_4;
    let flexbox_5;
    let flexbox_6;
    let flexbox_7;
    let flexbox_8;
    let flexbox_9;
    let flexbox_10;
    let flexbox_11;
    let flexbox_12;
    let flexbox_13;
    let flexbox_14;
    let flexbox_15;
    let flexbox_16;
    let flexbox_17;
    let flexbox_18;
    let flexbox_19;
    let flexbox_20;
    let flexbox_21;
    let flexbox_22;
    let flexbox_23;
    let flexbox_24;
    let flexbox_25;
    let flexbox_26;
    let flexbox_27;
    let flexbox_28;
    let flexbox_29;
    let flexbox_30;
    let flexbox_31;
    let flexbox_32;
    let flexbox_33;
    let flexbox_34;
    let flexbox_35;
    let flexbox_36;
    let flexbox_37;
    let flexbox_38;
    let flexbox_39;
    let flexbox_40;
    let flexbox_41;
    let flexbox_42;
    let flexbox_43;
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
          'align-content': 'flex-start',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
          'align-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_3 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
          'align-content': 'center',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_4 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
          'align-content': 'space-between',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_5 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
          'align-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_6 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
          'align-content': 'space-around',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_7 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
          'align-content': 'stretch',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_8 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_9 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'center',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_10 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'space-between',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_11 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'space-around',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_12 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_13 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'stretch',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '100px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '200px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-height': '20px',
            width: '50px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_14 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '200px',
        height: '30px',
        'box-sizing': 'border-box',
        'align-content': 'space-between',
      },
    });
    flexbox_15 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '200px',
        height: '30px',
        'box-sizing': 'border-box',
        'align-content': 'space-around',
      },
    });
    flexbox_16 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '200px',
        height: '30px',
        'box-sizing': 'border-box',
        'align-content': 'space-evenly',
      },
    });
    flexbox_17 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '200px',
        height: '30px',
        'box-sizing': 'border-box',
        'align-content': 'stretch',
      },
    });
    flexbox_18 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'space-between',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_19 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'space-around',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_20 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_21 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '30px',
          'box-sizing': 'border-box',
          'align-content': 'stretch',
        },
      },
      [
        createElement('div', {
          style: {
            'min-height': '10px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_22 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_23 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'flex-start',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_24 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_25 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'center',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_26 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-between',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_27 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-around',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_28 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_29 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '120px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'stretch',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_30 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'flex-end',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_31 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'center',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_32 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-between',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_33 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-around',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_34 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_35 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'stretch',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '10px',
            'background-color': 'lightgreen',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '20px',
            'background-color': 'pink',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'min-width': '20px',
            height: '5px',
            'background-color': 'yellow',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_36 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '30px',
        height: '20px',
        'box-sizing': 'border-box',
        'align-content': 'space-between',
      },
    });
    flexbox_37 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '30px',
        height: '20px',
        'box-sizing': 'border-box',
        'align-content': 'space-around',
      },
    });
    flexbox_38 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '30px',
        height: '20px',
        'box-sizing': 'border-box',
        'align-content': 'space-evenly',
      },
    });
    flexbox_39 = createElement('div', {
      style: {
        display: 'flex',
        'background-color': '#aaa',
        position: 'relative',
        'flex-wrap': 'wrap',
        width: '30px',
        height: '20px',
        'box-sizing': 'border-box',
        'align-content': 'stretch',
      },
    });
    flexbox_40 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-between',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_41 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-around',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_42 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'space-evenly',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox_43 = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap',
          width: '30px',
          height: '20px',
          'box-sizing': 'border-box',
          'align-content': 'stretch',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '10px',
            height: '10px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);
    BODY.appendChild(flexbox_3);
    BODY.appendChild(flexbox_4);
    BODY.appendChild(flexbox_5);
    BODY.appendChild(flexbox_6);
    BODY.appendChild(flexbox_7);
    BODY.appendChild(flexbox_8);
    BODY.appendChild(flexbox_9);
    BODY.appendChild(flexbox_10);
    BODY.appendChild(flexbox_11);
    BODY.appendChild(flexbox_12);
    BODY.appendChild(flexbox_13);
    BODY.appendChild(flexbox_14);
    BODY.appendChild(flexbox_15);
    BODY.appendChild(flexbox_16);
    BODY.appendChild(flexbox_17);
    BODY.appendChild(flexbox_18);
    BODY.appendChild(flexbox_19);
    BODY.appendChild(flexbox_20);
    BODY.appendChild(flexbox_21);
    BODY.appendChild(flexbox_22);
    BODY.appendChild(flexbox_23);
    BODY.appendChild(flexbox_24);
    BODY.appendChild(flexbox_25);
    BODY.appendChild(flexbox_26);
    BODY.appendChild(flexbox_27);
    BODY.appendChild(flexbox_28);
    BODY.appendChild(flexbox_29);
    BODY.appendChild(flexbox_30);
    BODY.appendChild(flexbox_31);
    BODY.appendChild(flexbox_32);
    BODY.appendChild(flexbox_33);
    BODY.appendChild(flexbox_34);
    BODY.appendChild(flexbox_35);
    BODY.appendChild(flexbox_36);
    BODY.appendChild(flexbox_37);
    BODY.appendChild(flexbox_38);
    BODY.appendChild(flexbox_39);
    BODY.appendChild(flexbox_40);
    BODY.appendChild(flexbox_41);
    BODY.appendChild(flexbox_42);
    BODY.appendChild(flexbox_43);

    await snapshot();
  });
  it('wrap-004', async () => {
    let flex;
    flex = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          'align-content': 'center',
          'flex-direction': 'column',
          'align-items': 'flex-start',
          width: '100px',
          'line-height': '1',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'min-height': '0',
              'background-color': 'green',
              'vertical-align': 'top',
              'box-sizing': 'border-box',
              height: '60px',
            },
          },
          [
            createElement('div', {
              style: {
                'vertical-align': 'top',
                'box-sizing': 'border-box',
                display: 'inline-block',
                height: '15px',
                width: '20px',
              },
            }),
            createElement('div', {
              style: {
                'vertical-align': 'top',
                'box-sizing': 'border-box',
                display: 'inline-block',
                height: '15px',
                width: '100px',
              },
            }),
            createElement('div', {
              style: {
                'vertical-align': 'top',
                'box-sizing': 'border-box',
                display: 'inline-block',
                height: '15px',
                width: '100px',
              },
            }),
            createElement('div', {
              style: {
                'vertical-align': 'top',
                'box-sizing': 'border-box',
                display: 'inline-block',
                height: '15px',
                width: '100px',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(flex);

    await snapshot();
  });

  it('stretch unbound flex-item 001', async () => {
    let content1Horizontal;
    let itemHorizontal;
    let flexHorizontal;
    flexHorizontal = createElement(
      'div',
      {
        style: {
          width: '400px',
          display: 'flex',
          height: '100px',
          'background-color': 'gray',
          'margin-bottom': '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (itemHorizontal = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content1Horizontal = createElement('div', {
              style: {
                width: '70px',
                height: '150px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(flexHorizontal);
    await snapshot();
  });

  it('stretch unbound flex-item 002', async () => {
    let content3Horizontal;
    let itemHorizontal;
    let flexHorizontal;
    flexHorizontal = createElement(
      'div',
      {
        style: {
          width: '400px',
          display: 'flex',
          height: '100px',
          'background-color': 'gray',
          'margin-bottom': '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (itemHorizontal = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content3Horizontal = createElement('div', {
              style: {
                width: '70px',
                height: '50px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(flexHorizontal);
    await snapshot();
  });

  it('stretch unbound flex-item 003', async () => {
    let content2Horizontal;
    let itemHorizontal;
    let flexHorizontal;
    flexHorizontal = createElement(
      'div',
      {
        style: {
          width: '400px',
          display: 'flex',
          height: '100px',
          'background-color': 'gray',
          'margin-bottom': '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (itemHorizontal = createElement(
          'div',
          {
            style: {
              width: '100px',
              'background-color': 'yellow',
              margin: '10px',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [
            (content2Horizontal = createElement('div', {
              style: {
                width: '70px',
                height: '100px',
                'background-color': 'red',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(flexHorizontal);
    await snapshot();
  });
});
