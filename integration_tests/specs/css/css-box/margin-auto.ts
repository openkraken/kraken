describe('Box margin auto', () => {
  it('should align center horizontally with block element in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginLeft: 'auto',
            marginRight: 'auto',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should not align center vertical with margin-top and margin-bottom of block element in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginTop: 'auto',
            marignBottom: 'auto',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should not work with inline and inline-block element in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            display: 'inline-block',
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginLeft: 'auto',
            marginRight: 'auto',
            background: 'red',
          },
        }),
        createElement('span', {
          style: {
            marginLeft: 'auto',
            marginRight: 'auto',
            background: 'green',
            fontSize: '24px',
          },
        }, [
            createText('fooooo')
        ]),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with margin-left of block element in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginLeft: 'auto',
            marginRight: '20px',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with positioned element in horizontal direction with left, right and width not auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            width: '30px',
            height: '30px',
            right: 0,
            left: 0,
            marginLeft: 'auto',
            marginRight: 'auto',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with positioned element in horizontal direction with top, bottom and height not auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            width: '30px',
            height: '30px',
            top: 0,
            bottom: 0,
            marginTop: 'auto',
            marginBottom: 'auto',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with positioned element in both direction in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            width: '30px',
            height: '30px',
            top: 0,
            bottom: 0,
            left: '10px',
            right: '10px',
            margin: 'auto',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with positioned element in both direction in flex layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            width: '30px',
            height: '30px',
            top: 0,
            bottom: 0,
            left: '10px',
            right: '10px',
            margin: 'auto',
            background: 'red',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with flex item in row direction', async () => {
     let div;
     div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'center',
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            margin: 'auto',
            background: 'red',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            margin: 'auto',
            background: 'green',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            margin: 'auto',
            background: 'blue',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();

  });


  it('should work with flex item of margin-left auto in row direction', async () => {
     let div;
     div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'center',
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginLeft: 'auto',
            background: 'red',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            background: 'green',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginLeft: 'auto',
            marginRight: '20px',
            background: 'blue',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();

  });

  it('should work with flex item in column direction', async () => {
     let div;
     div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            margin: 'auto',
            background: 'red',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            margin: 'auto',
            background: 'green',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            margin: 'auto',
            background: 'blue',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();

  });

  it('should work with flex item of margin-top auto in row direction', async () => {
     let div;
     div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          width: '150px',
          height: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginTop: 'auto',
            background: 'red',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            background: 'green',
          },
        }),
        createElement('span', {
          style: {
            width: '30px',
            height: '30px',
            fontSize: '24px',
            marginTop: 'auto',
            marginBottom: '20px',
            background: 'blue',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();

  });

  it('should work with flex item of margin-top auto with no height in row direction', async () => {
    let container;
    container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '300px',
          height: '100px',
          backgroundColor: '#999',
        },
      }, [
        createElement('span', {
          style: {
              position: 'relative',
              alignItems: 'center',
              marginTop: 'auto',
              backgroundImage: 'linear-gradient(to right, #FF6647, #FF401A)',
              borderRadius: '6px',
              color: '#fff',
              fontSize: '20px',
              lineHeight: '34px',
              padding: '0 10px',
          }
        }, [
            createText('12345')
        ])
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('should work with flex item of margin-bottom auto with no height in row direction', async () => {
    let container;
    container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '300px',
          height: '100px',
          backgroundColor: '#999',
        },
      }, [
        createElement('span', {
          style: {
              position: 'relative',
              alignItems: 'center',
              marginBottom: 'auto',
              backgroundImage: 'linear-gradient(to right, #FF6647, #FF401A)',
              borderRadius: '6px',
              color: '#fff',
              fontSize: '20px',
              lineHeight: '34px',
              padding: '0 10px',
          }
        }, [
            createText('12345')
        ])
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('should work with flex item of margin-top auto with no height in column direction', async () => {
    let container;
    container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '300px',
          height: '100px',
          backgroundColor: '#999',
        },
      }, [
        createElement('span', {
          style: {
              position: 'relative',
              alignItems: 'center',
              marginTop: 'auto',
              backgroundImage: 'linear-gradient(to right, #FF6647, #FF401A)',
              borderRadius: '6px',
              color: '#fff',
              fontSize: '20px',
              lineHeight: '34px',
              padding: '0 10px',
          }
        }, [
            createText('12345')
        ])
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('should work with flex item of margin-bottom auto with no height in column direction', async () => {
    let container;
    container = createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '300px',
          height: '100px',
          backgroundColor: '#999',
        },
      }, [
        createElement('span', {
          style: {
              position: 'relative',
              alignItems: 'center',
              marginBottom: 'auto',
              backgroundImage: 'linear-gradient(to right, #FF6647, #FF401A)',
              borderRadius: '6px',
              color: '#fff',
              fontSize: '20px',
              lineHeight: '34px',
              padding: '0 10px',
          }
        }, [
            createText('12345')
        ])
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });
});
