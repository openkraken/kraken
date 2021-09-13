describe('Position absolute', () => {
  it('001', async () => {
    var container = document.createElement('div');
    var div1 = document.createElement('div');
    var div2 = document.createElement('span');

    container.style.width = '300px';
    container.style.height = '800px';
    container.style.backgroundColor = '#999';

    div1.style.position = 'absolute';
    div1.style.width = '100px';
    div1.style.height = '200px';
    div1.style.backgroundColor = 'red';

    div2.style.position = 'absolute';
    div2.style.width = '100px';
    div2.style.height = '100px';
    div2.style.top = '50px';
    div2.style.backgroundColor = 'green';

    container.style.marginLeft = '50px';
    container.style.position = 'relative';
    container.style.top = '100px';

    container.appendChild(div1);
    container.appendChild(div2);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should be a green square below', async done => {
    let parent = createElementWithStyle('div', {
      width: '150px',
      height: '150px',
      backgroundColor: 'green',
    });
    let child = createElementWithStyle('div', {
      width: '150px',
      height: '150px',
      backgroundColor: 'white',
      position: 'absolute',
    });
    append(parent, child);
    append(BODY, parent);
    await snapshot(parent);

    requestAnimationFrame(async () => {
      child.style.left = '150px';
      await snapshot(parent);
      done();
    });
  });

  it('with no left following inline element', async () => {
    let div1 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'relative',
    });
    let div2 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '50px',
      backgroundColor: 'green',
    });
    append(div2, createText('inline'));
    const span = createElementWithStyle('span', {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      top: '50px',
      position: 'absolute'
    });
    append(span, createText('absolute with no left'));
    append(div2, span);
    append(BODY, div1);
    append(div1, div2);
    await snapshot();
  });

  it('with no top following inline element', async () => {
    let div1 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'relative',
    });
    let div2 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '50px',
      backgroundColor: 'green',
    });
    append(div2, createText('inline'));
    const span = createElementWithStyle('span', {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      left: '50px',
      position: 'absolute'
    });
    append(span, createText('absolute with no top'));
    append(div2, span);
    append(BODY, div1);
    append(div1, div2);
    await snapshot();
  });

  it('with no left following block element', async () => {
    let div1 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'relative',
    });
    let div2 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '50px',
      backgroundColor: 'green',
    });
    let div3 = createElementWithStyle('div', {});
    append(div3, createText('block'));
    append(div2, div3);
    const span = createElementWithStyle('span', {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      top: '50px',
      position: 'absolute'
    });
    append(span, createText('absolute with no left'));
    append(div2, span);
    append(BODY, div1);
    append(div1, div2);
    await snapshot();
  });

  it('with no top following block element', async () => {
    let div1 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'relative',
    });
    let div2 = createElementWithStyle('div', {
      border: '1px solid black',
      padding: '50px',
      backgroundColor: 'green',
    });
    let div3 = createElementWithStyle('div', {});
    append(div3, createText('block'));
    append(div2, div3);
    const span = createElementWithStyle('span', {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      left: '50px',
      position: 'absolute'
    });
    append(span, createText('absolute with no top'));
    append(div2, span);
    append(BODY, div1);
    append(div1, div2);
    await snapshot();
  });

  it('with no left in flex layout', async () => {
    const div = createElementWithStyle('div', {
      width: '200px',
      display: 'flex',
      height: '200px',
      border: '1px solid #000',
      position: 'relative',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'space-around',
    }, [
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'red',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'yellow',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '50px',
        height: '50px',
        backgroundColor: 'green',
        position: 'absolute',
        border: '2px solid #000',
        top: 0,
      }),
      createElementWithStyle('div', {
        width: '40px',
        height: '40px',
        backgroundColor: 'brown',
        position: 'absolute',
        border: '2px solid #000',
        top: 0,
      })
    ]);

    append(BODY, div);
    await snapshot();
  });

  it('with no top in flex layout', async () => {
    const div = createElementWithStyle('div', {
      width: '200px',
      display: 'flex',
      height: '200px',
      border: '1px solid #000',
      position: 'relative',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'space-around',
    }, [
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'red',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'yellow',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '50px',
        height: '50px',
        backgroundColor: 'green',
        position: 'absolute',
        border: '2px solid #000',
        left: 0,
      }),
      createElementWithStyle('div', {
        width: '40px',
        height: '40px',
        backgroundColor: 'brown',
        position: 'absolute',
        border: '2px solid #000',
        left: 0,
      })
    ]);

    append(BODY, div);
    await snapshot();
  });

  it('with no left and top in flex layout', async () => {
    const div = createElementWithStyle('div', {
      width: '200px',
      display: 'flex',
      height: '200px',
      border: '1px solid #000',
      position: 'relative',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'space-around',
    }, [
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'red',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'yellow',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '50px',
        height: '50px',
        backgroundColor: 'green',
        position: 'absolute',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '40px',
        height: '40px',
        backgroundColor: 'brown',
        position: 'absolute',
        border: '2px solid #000',
      })
    ]);

    append(BODY, div);
    await snapshot();
  });

  it('works with dynamic change bottom property', async (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';

    setTimeout(async () => {
      div.style.bottom = '100px';
      await snapshot();
    }, 100);

    setTimeout(async () => {
      div.style.bottom = '-200px';
      await snapshot();
      done();
    }, 300);

    document.body.appendChild(div);
    await snapshot();
  });

  it('works with dynamic change width property', async (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';

    setTimeout(async () => {
      div.style.width = '100px';
      await snapshot();
    }, 100);

    setTimeout(async () => {
      div.style.width = '400px';
      await snapshot();
      done();
    }, 300);

    document.body.appendChild(div);
    await snapshot();
  });

  it('works with dynamic change height property', async (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';

    setTimeout(async () => {
      div.style.height = '100px';
      await snapshot();
    }, 100);

    setTimeout(async () => {
      div.style.height = '400px';
      await snapshot();
      done();
    }, 300);

    document.body.appendChild(div);
    await snapshot();
  });

  it('works with dynamic change top property', async (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';

    setTimeout(async () => {
      div.style.top = '100px';
      await snapshot();
    }, 100);

    setTimeout(async () => {
      div.style.top = '-50px';
      await snapshot();
      done();
    }, 300);

    document.body.appendChild(div);
    await snapshot();
  });

  it('works with dynamic change left property', async (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';

    setTimeout(async () => {
      div.style.left = '100px';
      await snapshot();
    }, 100);

    setTimeout(async () => {
      div.style.left = '-50px';
      await snapshot();
      done();
    }, 300);

    document.body.appendChild(div);
    await snapshot();
  });

  it('works with dynamic change right property', async (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';

    setTimeout(async () => {
      div.style.right = '100px';
      await snapshot();
    }, 100);

    setTimeout(async () => {
      div.style.right = '-50px';
      await snapshot();
      done();
    }, 300);

    document.body.appendChild(div);
    await snapshot();
  });

  it('with no width and height', async () => {
    let BODY = document.body;
    const div = createElementWithStyle('div', {
      width: '200px',
      display: 'flex',
      height: '200px',
      border: '1px solid #000',
      position: 'relative',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'space-around',
    }, [
      createElementWithStyle('div', {
        backgroundColor: 'brown',
        position: 'absolute',
        border: '1px solid #000',
        top: '30px',
        left: '30px',
        right: '30px',
        bottom: '30px',
      })
    ]);

    append(BODY, div);
    await snapshot();
  });

  it('works with nested children' , async () => {
    let n1;
    n1 = createElementWithStyle(
      'div',
      {
        display: 'flex',
        position: 'relative',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      },
      [
        (createElementWithStyle(
          'div',
          {
            backgroundColor: 'blue',
            width: '200px',
            height: '200px',
          },
        )),
        (createElementWithStyle(
          'div',
          {
            position: 'absolute',
            top: '20px',
            left: '20px',
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          },
        ))
      ]
    );
    BODY.appendChild(n1);

    await snapshot();
  });

  it('with no left and width in flex layout', async () => {
    const div = createElementWithStyle('div', {
      width: '200px',
      display: 'flex',
      height: '200px',
      border: '1px solid #000',
      position: 'relative',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'space-around',
    }, [
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'red',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'yellow',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        height: '50px',
        backgroundColor: 'green',
        position: 'absolute',
        border: '2px solid #000',
        top: 0,
      }, [
        createText('foo bar')
      ]),
    ]);

    append(BODY, div);
    await snapshot();
  });

  it('with no top and height in flex layout', async () => {
    const div = createElementWithStyle('div', {
      width: '200px',
      display: 'flex',
      height: '200px',
      border: '1px solid #000',
      position: 'relative',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'space-around',
    }, [
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'red',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'yellow',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '100px',
        backgroundColor: 'green',
        position: 'absolute',
        border: '2px solid #000',
        left: 0,
      }, [
        createText('foo bar')
      ]),
    ]);

    append(BODY, div);
    await snapshot();
  });

  it('with no top left width and height in flex layout', async () => {
    const div = createElementWithStyle('div', {
      width: '200px',
      display: 'flex',
      height: '200px',
      border: '1px solid #000',
      position: 'relative',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'space-around',
    }, [
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'red',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        width: '30px',
        height: '30px',
        backgroundColor: 'yellow',
        border: '2px solid #000',
      }),
      createElementWithStyle('div', {
        backgroundColor: 'green',
        position: 'absolute',
        border: '2px solid #000',
      }, [
        createText('foo bar')
      ]),
    ]);

    append(BODY, div);
    await snapshot();
  });

  it('should work with percentage size in flow layout', async () => {
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
            position: 'absolute',
            height: '50%',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '200px',
            width: '50%',
            backgroundColor: 'blue',
          }
        },
        )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage size in flex layout', async () => {
    let div;
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
            position: 'absolute',
            height: '50%',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '200px',
            width: '50%',
            backgroundColor: 'blue',
          }
        },
        )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage offset', async () => {
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
            height: '100%',
            width: '100%',
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              height: '50px',
              width: '50px',
              backgroundColor: 'red',
            }
          }),
          createElement('div', {
            style: {
              position: 'absolute',
              width: '40%',
              height: '40%',
              top: '10%',
              left: '10%',
              right: '10%',
              bottom: '20%',
              backgroundColor: 'green',
            }
          })
        ]),
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage after element is attached', async (done) => {
    let div2;
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
            height: '100%',
            width: '100%',
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              height: '50px',
              width: '50px',
              backgroundColor: 'red',
            }
          }),
          (div2 = createElement('div', {
            style: {
              position: 'absolute',
              width: '40%',
              height: '40%',
              backgroundColor: 'green',
            }
          }))
        ]),
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
       div2.style.top = '10%';
       div2.style.left = '10%';
       div2.style.right = '10%';
       div2.style.bottom = '20%';
       await snapshot();
       done();
    });
  });

  it('should work with top bottom set and no height set', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
            "display": "flex",
            "flexDirection": "column",
            position: 'relative',
            width: '300px',
            height: '300px',
            borderTop: '20px solid red',
            borderBottom: '20px solid red',
            "padding": "50px 0",
            backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            "display": "flex",
            "flexDirection": "column",
            "position": "absolute",
            margin: '50px 0',
            top: '0',
            bottom: 0,
            width: '300px',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with left right set and no width set', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
            "display": "flex",
            "flexDirection": "column",
            position: 'relative',
            width: '300px',
            height: '300px',
            borderLeft: '20px solid red',
            borderRight: '20px solid red',
            "padding": "0 50px",
            backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            "display": "flex",
            "flexDirection": "column",
            "position": "absolute",
            margin: '0 50px',
            left: '0',
            right: 0,
            height: '300px',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });
});
