describe('Height', () => {
  it('basic example', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.height = '200px';

    await snapshot(div);
  });

  describe('element style has height', () => {
    it('element is inline', async () => {
      let element = createElementWithStyle('div', {
        display: 'inline',
        height: '100px',
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
        height: '100px',
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
        height: '100px',
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
        height: '100px',
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
        height: '100px',
        backgroundColor: '#999',
      }, [
        createText('foobar'),
      ]);
      append(BODY, element);
      await snapshot();
    });
  });

  describe('element style has no height', () => {
    it('when parent is flex with height and align-items stretch', async () => {

      const container = document.createElement('div');
      setElementStyle(container, {
        width: '200px',
        height: '200px',
        display: 'flex',
        backgroundColor: '#666',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      document.body.appendChild(container);

      const child1 = document.createElement('div');
      setElementStyle(child1, {
        width: '50px',
        backgroundColor: 'blue',
      });
      container.appendChild(child1);
      child1.appendChild(document.createTextNode('block with no height'));

      const child2 = document.createElement('div');
      setElementStyle(child2, {
        width: '50px',
        height: '100px',
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

    it('when parent is flex with no height and align-items stretch', async () => {
      const container = document.createElement('div');
      setElementStyle(container, {
        width: '200px',
        display: 'flex',
        backgroundColor: '#666',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      document.body.appendChild(container);

      const child1 = document.createElement('div');
      setElementStyle(child1, {
        width: '50px',
        backgroundColor: 'blue',
      });
      container.appendChild(child1);
      child1.appendChild(document.createTextNode('block with no height'));

      const child2 = document.createElement('div');
      setElementStyle(child2, {
        width: '50px',
        height: '100px',
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

    it('when nested in flex parents with align-items stretch', async () => {
      const container0 = document.createElement('div');
      setElementStyle(container0, {
        width: '300px',
        height: '300px',
        display: 'flex',
        backgroundColor: '#aaa',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      document.body.appendChild(container0);

      const container = document.createElement('div');
      setElementStyle(container, {
        width: '200px',
        display: 'flex',
        backgroundColor: '#666',
        flexDirection: 'row',
        alignItems: 'stretch',
      });

      container0.appendChild(container);

      const child1 = document.createElement('div');
      setElementStyle(child1, {
        width: '50px',
        backgroundColor: 'blue',
      });
      container.appendChild(child1);
      child1.appendChild(document.createTextNode('block with no height'));

      const child2 = document.createElement('div');
      setElementStyle(child2, {
        width: '50px',
        height: '100px',
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

    it('set element\'s height to auto', async () => {
      let container = createElement('div', {
        style: {
          height: '200px',
          background: 'red'
        }
      }, [createText('1234')]);
      BODY.appendChild(container);

      await snapshot();

      container.style.height = 'auto';
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
            height: '50%',
            width: '100px',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '50%',
            width: '100%',
            backgroundColor: 'blue',
          }
        }, [
          createElement('div', {
            style: {
              height: '100%',
              width: '100px',
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
            height: '50%',
            width: '100px',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '50%',
            width: '100%',
            backgroundColor: 'blue',
          }
        }, [
          createElement('div', {
            style: {
              height: '100%',
              width: '100px',
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
            height: '50%',
            width: '100px',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '50%',
            width: '100%',
            backgroundColor: 'blue',
          }
        }, [
          createElement('div', {
            style: {
              height: '100%',
              width: '100px',
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

  it('should work with percentage and flow layout of no height', async (done) => {
    let div;
    let text;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          border: '1px solid black',
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
              background: 'pink',
              height: '100%',
            },
          },
          [(text = createText(`two`))]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      text.data = 'three';
      await snapshot(0.1);
      done();
    });
  });

  it('should work with percentage and flow layout of height', async (done) => {
    let div;
    let text;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          border: '1px solid black',
          width: '120px',
          height: '100px',
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
              background: 'pink',
              height: '100%',
            },
          },
          [(text = createText(`two`))]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      text.data = 'three';
      await snapshot(0.1);
      done();
    });
  });

  it('should work with percentage and flex layout of no height', async (done) => {
    let div;
    let text;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          background: 'blue',
          border: '1px solid black',
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
              background: 'pink',
              height: '100%',
            },
          },
          [(text = createText(`two`))]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      text.data = 'three';
      await snapshot(0.1);
      done();
    });
  });

  it('should work with percentage and flex layout of height', async (done) => {
    let div;
    let text;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          background: 'blue',
          border: '1px solid black',
          width: '120px',
          height: '100px',
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
              background: 'pink',
              height: '100%',
            },
          },
          [(text = createText(`two`))]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      text.data = 'three';
      await snapshot(0.1);
      done();
    });
  });
});
