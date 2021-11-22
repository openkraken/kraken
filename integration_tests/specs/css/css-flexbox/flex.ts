/*auto generated*/
describe('flex', () => {
  it('001', async () => {
    let p;
    let flexItem1;
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
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          'background-color': 'red',
          display: 'flex',
          width: '300px',
          flex: '1 0 auto',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem1 = createElement('div', {
          id: 'flexItem1',
          style: {
            'background-color': 'blue',
            flex: '1 0 auto',
            height: '100px',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            'background-color': 'orange',
            flex: '1 0 auto',
            height: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let flexItem1;
    let flexItem2;
    let flexbox;
    let ref1;
    let ref2;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          height: '50px',
          'background-color': 'red',
          display: 'flex',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem1 = createElement('div', {
          id: 'flexItem1',
          style: {
            height: '50px',
            flex: '0 2 auto',
            width: '300px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        })),
        (flexItem2 = createElement('div', {
          id: 'flexItem2',
          style: {
            height: '50px',
            width: '200px',
            'background-color': 'orange',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    ref1 = createElement('div', {
      id: 'ref1',
      style: {
        height: '50px',
        'background-color': 'blue',
        display: 'inline-block',
        width: '150px',
        'box-sizing': 'border-box',
      },
    });
    ref2 = createElement('div', {
      id: 'ref2',
      style: {
        height: '50px',
        'background-color': 'orange',
        display: 'inline-block',
        width: '150px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(flexbox);
    BODY.appendChild(ref1);
    BODY.appendChild(ref2);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let flexItem1;
    let flexItem2;
    let flexbox;
    let ref1;
    let ref2;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          height: '50px',
          'background-color': 'red',
          display: 'flex',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem1 = createElement('div', {
          id: 'flexItem1',
          style: {
            height: '50px',
            flex: '1 0 auto',
            width: '100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        })),
        (flexItem2 = createElement('div', {
          id: 'flexItem2',
          style: {
            height: '50px',
            flex: '2 0 auto',
            width: '50px',
            'background-color': 'orange',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    ref1 = createElement('div', {
      id: 'ref1',
      style: {
        height: '50px',
        'background-color': 'blue',
        display: 'inline-block',
        width: '150px',
        'box-sizing': 'border-box',
      },
    });
    ref2 = createElement('div', {
      id: 'ref2',
      style: {
        height: '50px',
        'background-color': 'orange',
        display: 'inline-block',
        width: '150px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(flexbox);
    BODY.appendChild(ref1);
    BODY.appendChild(ref2);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let flexItem1;
    let flexItem2;
    let flexbox;
    let ref1;
    let ref2;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          height: '50px',
          'background-color': 'red',
          display: 'flex',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem1 = createElement('div', {
          id: 'flexItem1',
          style: {
            height: '50px',
            flex: '0 2 auto',
            width: '300px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        })),
        (flexItem2 = createElement('div', {
          id: 'flexItem2',
          style: {
            height: '50px',
            flex: '0 3 auto',
            width: '600px',
            'background-color': 'orange',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    ref1 = createElement('div', {
      id: 'ref1',
      style: {
        height: '50px',
        'background-color': 'blue',
        display: 'inline-block',
        width: '150px',
        'box-sizing': 'border-box',
      },
    });
    ref2 = createElement('div', {
      id: 'ref2',
      style: {
        height: '50px',
        'background-color': 'orange',
        display: 'inline-block',
        width: '150px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(flexbox);
    BODY.appendChild(ref1);
    BODY.appendChild(ref2);

    await snapshot();
  });
  it('direction', async () => {
    let flexItem;
    let flexItem_1;
    let flexItem_2;
    let flexItem_3;
    let flexItem_4;
    let flexItem_5;
    let flexItem_6;
    let flexItem_7;
    let flexItem_8;
    let flexItem_9;
    let flexItem_10;
    let flexItem_11;
    let flexContainer;
    let flexContainer_1;
    let flexContainer_2;
    let flexContainer_3;
    flexContainer = createElement(
      'div',
      {
        class: 'flex-container flex-direction-row',
        style: {
          display: 'flex',
          margin: '20px',
          'background-color': '#333',
          'flex-direction': 'row',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (flexItem_1 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_2 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    flexContainer_1 = createElement(
      'div',
      {
        class: 'flex-container flex-direction-row-reverse',
        style: {
          display: 'flex',
          margin: '20px',
          'background-color': '#333',
          'flex-direction': 'row-reverse',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem_3 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (flexItem_4 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_5 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    flexContainer_2 = createElement(
      'div',
      {
        class: 'flex-container flex-direction-column',
        style: {
          display: 'flex',
          margin: '20px',
          'background-color': '#333',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem_6 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (flexItem_7 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_8 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    flexContainer_3 = createElement(
      'div',
      {
        class: 'flex-container flex-direction-column-reverse',
        style: {
          display: 'flex',
          margin: '20px',
          'background-color': '#333',
          'flex-direction': 'column-reverse',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem_9 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (flexItem_10 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_11 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              width: '50px',
              height: '50px',
              margin: '20px',
              'background-color': '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(flexContainer);
    BODY.appendChild(flexContainer_1);
    BODY.appendChild(flexContainer_2);
    BODY.appendChild(flexContainer_3);

    await snapshot();
  });
  it('direction_column', async () => {
    let test01;
    let test02;
    let test03;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': '#ff0000',
          height: '200px',
          width: '200px',
          display: 'flex',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            id: 'test01',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            id: 'test02',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            id: 'test03',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });
  it('direction_row', async () => {
    let test01;
    let test02;
    let test03;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': '#ff0000',
          height: '200px',
          width: '200px',
          display: 'flex',
          'flex-direction': 'row',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            id: 'test01',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            id: 'test02',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            id: 'test03',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });

  it('should work with initial', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '400px',
          marginBottom: '10px',
          backgroundColor: '#ddd',
        },
      },
      [
        (createElement('div', {
          id: 'child_1',
          style: {
            backgroundColor: 'red',
            width: '50px',
            height: '100px',
            flex: 'initial',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '80px',
            height: '100px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with auto', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '400px',
          marginBottom: '10px',
          backgroundColor: '#ddd',
        },
      },
      [
        (createElement('div', {
          id: 'child_1',
          style: {
            backgroundColor: 'red',
            width: '50px',
            height: '100px',
            flex: 'auto',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '80px',
            height: '100px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with none', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '400px',
          marginBottom: '10px',
          backgroundColor: '#ddd',
        },
      },
      [
        (createElement('div', {
          id: 'child_1',
          style: {
            backgroundColor: 'red',
            width: '150px',
            height: '100px',
            flex: 'none',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '80px',
            height: '100px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('flex items with inner padding and no specify width', async () => {
    let container;
    container = createViewElement({
      flexDirection: 'row'
    }, [
      createViewElement(
        {
          backgroundColor: 'blue',
          padding: '0 20px',
          height: '64px',
          justifyContent: 'center',
          alignItems: 'center',
          borderRadius: '32px'
        },
        [
          createElement('span', {
            style: {
              color: '#fff',
              fontSize: '34px'
            }
          }, [
            createText('12345')
          ])
        ]
      )
    ]);
    BODY.appendChild(container);
    await snapshot();
  });

  it("column flex child with overflow scroll", async () => {
    let log;
    let box;
    let box_1;
    let box2;
    let flexbox;
    let flexbox_1;
    let box4;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    flexbox = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        (box = createElement('div', {
          class: 'box',
          'data-expected-width': '100',
          'data-expected-height': '75',
          style: {
            'box-sizing': 'border-box',
            width: '100px',
            height: '75px',
            padding: '5px',
            border: '2px solid red',
          },
        })),
        (box2 = createElement('div', {
          class: 'box scroll',
          id: 'box2',
          'data-expected-width': '100',
          'data-expected-height': '75',
          style: {
            'box-sizing': 'border-box',
            overflow: 'scroll',
            width: '100px',
            height: '75px',
            padding: '5px',
            border: '2px solid red',
          },
        })),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column-reverse',
        style: {
          display: 'flex',
          '-webkit-flex-direction': 'column-reverse',
          'flex-direction': 'column-reverse',
          'box-sizing': 'border-box',
        },
      },
      [
        (box_1 = createElement('div', {
          class: 'box',
          'data-expected-width': '100',
          'data-expected-height': '75',
          style: {
            'box-sizing': 'border-box',
            width: '100px',
            height: '75px',
            padding: '5px',
            border: '2px solid red',
          },
        })),
        (box4 = createElement('div', {
          class: 'box scroll',
          id: 'box4',
          'data-expected-width': '100',
          'data-expected-height': '75',
          style: {
            'box-sizing': 'border-box',
            overflow: 'scroll',
            width: '100px',
            height: '75px',
            padding: '5px',
            border: '2px solid red',
          },
        })),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);

    await snapshot();
  });

  it('change from not none to none', async (done) => {
    let item;
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          minHeight: '100px',
          width: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
        }
      }, [
        (item = createElement('div',  {
          style: {
            display: 'flex',
            width: '50px',
            height: '50px',
            backgroundColor: 'red',
            flex: 1,
          }
        }))
      ]
    );
    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      item.style.flex = 'none';
      await snapshot();
      done();
    });
  });

 
  it('should work with percentage of child of flex item in flex column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '100px',
          display: 'flex',
          flexDirection: 'column',
          backgroundColor: 'green',
        },
      },
      [
        createElement('div', {
          style: {
            flex: 1,
            width: '200px',
            padding: '10px',
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              width: '100px',
              height: '100%',
              backgroundColor: 'red'
            }
          })
        ])
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage of child of flex item in flex row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '100px',
          display: 'flex',
          flexDirection: 'row',
          backgroundColor: 'green',
        },
      },
      [
        createElement('div', {
          style: {
            flex: 1,
            height: '100px',
            padding: '10px',
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              width: '100%',
              height: '50px',
              backgroundColor: 'red'
            }
          })
        ])
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });
});
