describe('flexbox flex-grow', () => {
  it('001', async () => {
    let child1;
    let child2;
    let child3;
    let container;
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'container',
        style: {
          width: '240px',
          height: '60px',
          border: '1px solid #000',
          display: 'flex',
        },
      },
      [
        (child1 = createElement('div', {
          id: 'child_1',
          style: {
            width: '30px',
            height: '60px',
            'flex-grow': '0',
            'background-color': 'green',
          },
        })),
        (child2 = createElement('div', {
          id: 'child_2',
          style: {
            width: '30px',
            height: '60px',
            'flex-grow': '1',
            'background-color': 'blue',
          },
        })),
        (child3 = createElement('div', {
          id: 'child_3',
          style: {
            width: '30px',
            height: '60px',
            'flex-grow': '2',
            'background-color': 'gray',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
  xit('002', async () => {
    let test1;
    let test2;
    let test3;
    let container;
    let cover;
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
            width: '20px',
            'background-color': 'green',
            'flex-grow': '1',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '20px',
            'background-color': 'green',
            'flex-grow': '0',
            'box-sizing': 'border-box',
          },
        })),
        (test3 = createElement('div', {
          id: 'test3',
          style: {
            height: '100px',
            width: '20px',
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
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('003', async () => {
    let test1;
    let test2;
    let container;
    let cover;
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
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            'background-color': 'red',
            height: '100px',
            'flex-grow': '-2',
            width: '25px',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            'background-color': 'red',
            height: '100px',
            'flex-grow': '-3',
            width: '25px',
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
        position: 'relative',
        top: '-100px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('004', async () => {
    let test1;
    let test2;
    let container;
    let cover;
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
            'flex-grow': '3',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            'background-color': 'green',
            'flex-grow': '2',
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
        position: 'relative',
        top: '-100px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('005', async () => {
    let container;
    let cover;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'green',
          display: 'flex',
          'flex-grow': '2',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'red',
            height: '100px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'red',
            height: '100px',
            width: '25px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        'background-color': 'green',
        height: '100px',
        position: 'relative',
        top: '-100px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  xit('006', async () => {
    let test1;
    let container;
    let container_1;
    let test2;
    container = createElement(
      'div',
      {
        class: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '50px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'flex-grow': '1.5',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    container_1 = createElement(
      'div',
      {
        class: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '50px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            'background-color': 'green',
            height: '50px',
            width: '25px',
            'flex-grow': '2',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);
    BODY.appendChild(container_1);

    await snapshot();
  });
  xit('007', async () => {
    let test1;
    let container;
    let container_1;
    let test2;
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
              width: '190px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                background: 'green',
                height: '50px',
                'flex-grow': '0.1',
                width: '90px',
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
              width: '190px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                background: 'green',
                height: '50px',
                'flex-grow': '0.05',
                width: '45px',
                'box-sizing': 'border-box',
              },
            }),
            createElement('div', {
              style: {
                background: 'green',
                height: '50px',
                'flex-grow': '0.05',
                width: '45px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
      ]
    );
    BODY.appendChild(container);
    BODY.appendChild(container_1);

    await snapshot();
  });
  it('010', async () => {
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-direction': 'column-reverse',
          'flex-wrap': 'nowrap',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`4`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
      ]
    );
    BODY.appendChild(test);
    await snapshot();
  });
  it('should work when flex-direction is row', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'row',
      width: '500px',
      height: '100px',
      marginBottom: '10px',
    });

    document.body.appendChild(container1);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: '#999',
    });
    child1.appendChild(document.createTextNode('flex-grow: 0'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      flexGrow: 2,
      backgroundColor: '#f40',
    });
    child2.appendChild(document.createTextNode('flex-grow: 2'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      flexGrow: 1,
      backgroundColor: 'green',
    });
    child3.appendChild(document.createTextNode('flex-grow: 1'));
    container1.appendChild(child3);

    await snapshot();
  });

  it('should work when flex-direction is column', async () => {
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      width: '500px',
      height: '200px',
      marginBottom: '10px',
    });

    document.body.appendChild(container2);

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      backgroundColor: '#999',
    });
    child4.appendChild(document.createTextNode('flex-grow: 0'));
    container2.appendChild(child4);

    const child5 = document.createElement('div');
    setElementStyle(child5, {
      flexGrow: 2,
      backgroundColor: '#f40',
    });
    child5.appendChild(document.createTextNode('flex-grow: 2'));
    container2.appendChild(child5);

    const child6 = document.createElement('div');
    setElementStyle(child6, {
      flexGrow: 1,
      backgroundColor: 'green',
    });
    child6.appendChild(document.createTextNode('flex-grow: 1'));
    container2.appendChild(child6);

    await snapshot();
  });
  it('should work with multiple flex container', async () => {
    let container;
    container = createViewElement(

      {
        width: '200px',
        height: '500px',
        flexShrink: 1,
        border: '2px solid #000',
      },
      [
        createViewElement(
          {
            height: '20px',
          },
          []
        ),
        createViewElement(
          {
            flex: 1,
            width: '200px',
            background: 'red'
          },
          []
        ),
      ]
    );

    BODY.appendChild(container);
    await snapshot();
  });

  it('should work with flex item of margin and not width when flex-direction is row', async () => {
    let containingBlock = createElement('div', {
      style: {
        position: 'relative',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        display: 'flex',
        'flex-direction': 'row',
      },
    },
      [
        createElement('div', {
          style: {
            'flex-grow': '1',
            display: 'flex',
            'justify-content': 'center',
            backgroundColor: 'yellow',
            margin: '10px',
          },
        }),
        createElement('div', {
          style: {
            'flex-grow': '1',
            height: '100px',
            'background-color': 'blue',
          }
        }),
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it('should work with flex item of margin and not width when flex-direction is row-reverse', async () => {
    let containingBlock = createElement('div', {
      style: {
        position: 'relative',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        display: 'flex',
        'flex-direction': 'row-reverse',
      },
    },
      [
        createElement('div', {
          style: {
            'flex-grow': '1',
            display: 'flex',
            'justify-content': 'center',
            backgroundColor: 'yellow',
            margin: '10px',
          },
        }),
        createElement('div', {
          style: {
            'flex-grow': '1',
            height: '100px',
            'background-color': 'blue',
          }
        }),
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it('should work with flex item of margin and not width when flex-direction is column', async () => {
    let containingBlock = createElement('div', {
      style: {
        position: 'relative',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        display: 'flex',
        'flex-direction': 'column',
      },
    },
      [
        createElement('div', {
          style: {
            'flex-grow': '1',
            display: 'flex',
            'justify-content': 'center',
            backgroundColor: 'yellow',
            margin: '10px',
          },
        }),
        createElement('div', {
          style: {
            'flex-grow': '1',
            'background-color': 'blue',
          }
        }),
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it('should work with flex item of margin and not width when flex-direction is column-reverse', async () => {
    let containingBlock = createElement('div', {
      style: {
        position: 'relative',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        display: 'flex',
        'flex-direction': 'column-reverse',
      },
    },
      [
        createElement('div', {
          style: {
            'flex-grow': '1',
            display: 'flex',
            'justify-content': 'center',
            backgroundColor: 'yellow',
            margin: '10px',
          },
        }),
        createElement('div', {
          style: {
            'flex-grow': '1',
            'background-color': 'blue',
          }
        }),
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it('works with max violation', async () => {
    let test1;
    let test2;
    let test3;
    let test4;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '50px',
            'background-color': 'green',
            'flex-grow': '1',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '50px',
            maxWidth: '50px',
            'background-color': 'black',
            'flex-grow': '1',
            'box-sizing': 'border-box',
          },
        })),
        (test3 = createElement('div', {
          id: 'test3',
          style: {
            height: '100px',
            width: '50px',
            maxWidth: '70px',
            'background-color': 'blue',
            'flex-grow': '1',
            'box-sizing': 'border-box',
          },
        })),
        (test4 = createElement('div', {
          id: 'test4',
          style: {
            height: '100px',
            width: '50px',
            'background-color': 'yellow',
            'flex-grow': '1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);


    await snapshot();
  });

  it('works with flex factor sum less than 1', async () => {
    let test1;
    let test2;
    let test3;
    let test4;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '50px',
            'background-color': 'green',
            'flex-grow': '0.1',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '50px',
            'background-color': 'black',
            'flex-grow': '0.2',
            'box-sizing': 'border-box',
          },
        })),
        (test3 = createElement('div', {
          id: 'test3',
          style: {
            height: '100px',
            width: '50px',
            'background-color': 'blue',
            'flex-grow': '0.2',
            'box-sizing': 'border-box',
          },
        })),
        (test4 = createElement('div', {
          id: 'test4',
          style: {
            height: '100px',
            width: '50px',
            'background-color': 'yellow',
            'flex-grow': '0.1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);


    await snapshot();
  });

  it('should work flex item of display block and child of no width in row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '200px',
          height: '200px',
          backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            flex: 1,
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              height: '200px',
              backgroundColor: 'red'
            }
          })
        ])
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should work child of no width in row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '200px',
          height: '200px',
          backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            display: 'flex',
            flexDirection: 'column',
            flex: 1,
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              display: 'flex',
              flex: 1,
              backgroundColor: 'red'
            }
          })
        ])
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should work child of no height in column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '200px',
          height: '200px',
          backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            display: 'flex',
            flexDirection: 'row',
            flex: 1,
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              display: 'flex',
              flex: 1,
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
