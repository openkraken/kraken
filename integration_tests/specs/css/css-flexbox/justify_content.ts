describe('flexbox justify-content', () => {
  it('should work with flex-start when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'flex-start',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with flex-end when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'flex-end',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with center when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'center',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with space-around when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'space-around',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with space-between when flex-direction is row', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '100px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      justifyContent: 'space-between',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with flex-start when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      justifyContent: 'flex-start',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with flex-end when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      justifyContent: 'flex-end',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with center when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      justifyContent: 'center',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with space-around when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      justifyContent: 'space-around',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with space-between when flex-direction is column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      height: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'column',
      justifyContent: 'space-between',
    });

    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      height: '50px',
      backgroundColor: 'blue',
    });
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      width: '50px',
      height: '50px',
      backgroundColor: 'green',
    });
    container.appendChild(child3);

    await snapshot();
  });

  it('should work with center when flex-grow exists', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'flex-end',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: '1 0 auto',
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: '2 0 auto',
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '30px',
            height: '40px',
            backgroundColor: 'blue',
            'text-align': 'center',
            flex: '1 0 auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should work with center when flex-shrink exists', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'flex-end',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'blue',
            'text-align': 'center',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should work with flex-start when children width is larger than container', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'flex-start',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'blue',
            flexShrink: 0,
            'text-align': 'center',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should work with flex-end when children width is larger than container', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'flex-end',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'blue',
            flexShrink: 0,
            'text-align': 'center',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
  it('should work with center when children width is larger than container', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'center',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'blue',
            flexShrink: 0,
            'text-align': 'center',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should work with space-between when children width is larger than container', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'space-between',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'blue',
            flexShrink: 0,
            'text-align': 'center',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should work with space-around when children width is larger than container', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'space-around',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'blue',
            flexShrink: 0,
            'text-align': 'center',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should work with space-evenly when children width is larger than container', async () => {
    let failFlag;
    let flex;
    let container;

    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'space-evenly',
          'align-items': 'center',
          border: '5px solid green',
          margin: '25px',
          width: '250px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            backgroundColor: 'yellow',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            'text-align': 'center',
            flexShrink: 0,
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'blue',
            flexShrink: 0,
            'text-align': 'center',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
});
