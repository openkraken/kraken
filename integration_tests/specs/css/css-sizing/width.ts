describe('Width', function() {
  it('basic example', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.width = '200px';
    await snapshot();
  });

  describe('element style has width', () => {
    it('element is inline', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await snapshot();
    });

    it('element is inline-block', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await snapshot();
    });

    it('element is inline-flex', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await snapshot();
    });

    it('element is block', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await snapshot();
    });

    it('element is flex', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await snapshot();
    });
  });

  describe('element style has no width', () => {
    it('parent is inline and grand parent is block', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'block',
        width: '100px',
        backgroundColor: '#333',
      }, [
        createElementWithStyle('div', {
          display: 'inline'
        }, [
          element,
        ]),
      ]);

      append(BODY, container);
      await snapshot();
    });

    it('parent is inline-block and has width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'inline-block',
        width: '100px',
      }, [
        element,
      ]);

      append(BODY, container);
      await snapshot();
    });

    it('parent is inline-block and has no width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'inline-block',
      }, [
        element,
      ]);

      append(BODY, container);
      await snapshot();
    });

    it('parent is block and has width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'block',
        width: '100px',
      }, [
        element,
      ]);

      append(BODY, container);
      await snapshot();
    });

    it('parent is block and has no width', async () => {
      let element = createElementWithStyle('div', {
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);

      let container = createElementWithStyle('div', {
        display: 'block',
      }, [
        element,
      ]);

      append(BODY, container);
      await snapshot();
    });

    it('set element\'s width to auto', async () => {
      let container = createElement('div', {
        style: {
          width: '200px',
          background: 'red'
        }
      }, [createText('1234')]);
      BODY.appendChild(container);

      await snapshot();

      container.style.width = 'auto';
      await snapshot();
    });
  });

  it('should work with percentage in flow layout', async () => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '100px',
            width: '100%',
            backgroundColor: 'blue',
          }
        }, [
          createElement('div', {
            style: {
              height: '100px',
              width: '50%',
              backgroundColor: 'red',
            }
          }),
        ]
        )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage with decimal point', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '50.00%',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage and multiple children in flow layout', async () => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '100px',
            width: '100px',
            backgroundColor: 'blue',
          }
        }
        )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage in flex layout in row direction', async () => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '100px',
            width: '100%',
            backgroundColor: 'blue',
          }
        }, [
          createElement('div', {
            style: {
              height: '100px',
              width: '50%',
              backgroundColor: 'red',
            }
          }),
        ]
        )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage in flex layout in column direction', async () => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '100px',
            width: '100%',
            backgroundColor: 'blue',
          }
        }, [
          createElement('div', {
            style: {
              height: '100px',
              width: '50%',
              backgroundColor: 'red',
            }
          }),
        ]
        )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage and multiple children in flex layout ', async () => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexWrap: 'wrap',
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '100px',
            width: '150px',
            backgroundColor: 'blue',
          }
        }
        )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage of positioned element', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          position: 'relative',
          background: 'blue',
          border: '10px solid green',
          padding: '10px',
          width: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'yellow',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'div',
          {
            style: {
              position: 'absolute',
              background: 'pink',
              width: '100%',
            },
          },
          [(text = createText(`two`))]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  
  it('should work with percentage after element is attached', async (done) => {
    let div2;
    let div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexWrap: 'wrap',
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            height: '100px',
            backgroundColor: 'yellow',
          }
        }))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
       div2.style.width = '50%';
       await snapshot();
       done();
    });
  });
});
