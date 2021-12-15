describe('flexbox flex-shrink', () => {
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
      width: '300px',
    });
    child1.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      flexShrink: 2,
      backgroundColor: '#f40',
      width: '200px',
    });
    child2.appendChild(document.createTextNode('flex-shrink: 2'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      flexShrink: 1,
      backgroundColor: 'green',
      width: '200px',
    });
    child3.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child3);

    await snapshot();
  });

  it('should work when flex-direction is column', async () => {
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      width: '500px',
      height: '400px',
      marginBottom: '10px',
    });

    document.body.appendChild(container2);

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      backgroundColor: '#999',
      height: '300px',
    });
    child4.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child4);

    const child5 = document.createElement('div');
    setElementStyle(child5, {
      flexShrink: 2,
      backgroundColor: '#f40',
      height: '200px',
    });
    child5.appendChild(document.createTextNode('flex-shrink: 2'));
    container2.appendChild(child5);

    const child6 = document.createElement('div');
    setElementStyle(child6, {
      flexShrink: 1,
      backgroundColor: 'green',
      height: '200px',
    });
    child6.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child6);

    await snapshot();
  });
  it('not shrink no defined size elements', async () => {
    let element = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'display': 'flex',
        'position': 'relative',
        'flex-direction': 'column',
        'flex-shrink': 0,
        'align-content': 'flex-start',
        'margin': '0vw',
        padding: '0vw',
        'min-width': '0vw',
        height: '640px'
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'display': 'flex',
          'position': 'relative',
          'flex-direction': 'column',
          'flex-shrink': 0,
          'align-content': 'flex-start',
          'margin': '0vw',
          padding: '0vw',
          'min-width': '0vw',
          height: '20px',
          'aligm-items': 'center',
          background: 'blue'
        }
      })
    ]);
    BODY.appendChild(element);
    await snapshot();
  });

  it('scrollable height auto computed by flex container', async (done) => {
    let container;
    let list = new Array(100).fill(0);
    let scroller;
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
        scroller = createViewElement(
          {
            flex: 1,
            width: '200px',
            overflow: 'scroll',
          },
          list.map((_, index) => {
            return createElement('div', {}, [createText(`${index}`)]);
          })
        ),
      ]
    );

    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      scroller.scrollTop = 400;
      await snapshot();
      done();
    });
  });

  it('should work with intrinsic element with no min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
        }),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot(0.1);
  });

  it('should work with intrinsic element with min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            minHeight: '30px'
          }
        }),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot(0.2);
  });

  it('should work with intrinsic element with width and no height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            width: '30px'
          }
        }),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot(0.1);
  });

  it('should work with flex layout in the column direction with children and height is not larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              flexDirection: 'column',
              height: '100px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flex layout in the column direction with children and height is larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              flexDirection: 'column',
              height: '300px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flex layout in the column direction with children and min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              flexDirection: 'column',
              height: '300px',
              minHeight: '30px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flex layout in the row direction with children and height is not larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              height: '50px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flex layout in the row direction with children and height is larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              height: '250px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flex layout in the row direction with children and min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              display: 'flex',
              height: '250px',
              minHeight: '30px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flow layout with children and height is not larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '100px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '200px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flow layout with children and height is larger than children height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '300px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '200px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('should work with flow layout with children and min-height', async () => {
    let constrainedFlex;
    constrainedFlex = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '10px',
          backgroundColor: 'red',
        },
      },
      [
        (createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '300px',
              minHeight: '30px',
            },
          },
          [
            (createElement('div', {
              style: {
                width: '100px',
                height: '100px',
                opacity: 0.5,
                flexShrink: 0,
              },
            })),
            createText('foooo'),
          ]
        )),
      ]
    );
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });

  it('works with min violation', async () => {
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
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'green',
            'flex-shrink': '4',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'black',
            'flex-shrink': '3',
            'box-sizing': 'border-box',
          },
        })),
        (test3 = createElement('div', {
          id: 'test3',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'blue',
            'flex-shrink': '2',
            'box-sizing': 'border-box',
          },
        })),
        (test4 = createElement('div', {
          id: 'test4',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'yellow',
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
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test1 = createElement('div', {
          id: 'test1',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'green',
            'flex-shrink': '0.2',
            'box-sizing': 'border-box',
          },
        })),
        (test2 = createElement('div', {
          id: 'test2',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'black',
            'flex-shrink': '10',
            'box-sizing': 'border-box',
          },
        })),
        (test3 = createElement('div', {
          id: 'test3',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'blue',
            'flex-shrink': '0.2',
            'box-sizing': 'border-box',
          },
        })),
        (test4 = createElement('div', {
          id: 'test4',
          style: {
            height: '100px',
            width: '100px',
            'background-color': 'yellow',
            'flex-shrink': '0.1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);


    await snapshot();
  });

  it('should work with image with no size set', async () => {
    const container = createElement(
      'div',
      {
        style: {
          "display": "flex",
          "width": "100px",
          "height": "100px",
        },
      },
      [
        (createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            "marginLeft": "20px"
          },
        })),
        (createElement('img', {
          src: 'assets/100x100-blue-and-orange.png',
          style: {
            "width": "100px",
            "height": "100px",
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot(0.1);
  });

  it('should work with flex item with overflow hidden', async () => {
    const container = createElement(
      'div',
      {
        style: {
          "boxSizing": "border-box",
          "display": "flex",
          "flexDirection": "column",
          "flexShrink": "0",
          "alignContent": "flex-start",
          "border": "0 solid black",
          "margin": "0",
          "padding": "0",
          "minWidth": "0",
          "width": "100px",
          "height": "100px",
        },
      },
      [
        (createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            "display": "flex",
            "position": "relative",
            "alignItems": "center",
            "flexDirection": "row",
            "justifyContent": "center",
            "marginTop": "10px",
          },
        })),
        (createElement('div', {
          style: {
            "width": "100px",
            "height": "100px",
            "overflow": "hidden",
            "background": "yellow"
        },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot(0.1);
  });

  it('should work with child has margin when flex direction is row', async () => {
    let div = createElement(
        'div',
        {
          style: {
              display: 'flex',
              overflow: 'visible',
              width: '100vw',
          },
      }, [
          createElement(
          'div',
          {
              style: {
                  display: 'flex',
                  flexDirection: 'row',
                  boxSizing: 'border-box',
                  overflow: 'visible'
              },
          }, [
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
          ])
      ]);
    
    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with child has margin when flex direction is column', async () => {
    let div = createElement(
        'div',
        {
          style: {
              display: 'flex',
              flexDirection: 'column',
              overflow: 'visible',
              height: '300px',
          },
      }, [
          createElement(
          'div',
          {
              style: {
                  display: 'flex',
                  flexDirection: 'column',
                  boxSizing: 'border-box',
                  overflow: 'visible'
              },
          }, [
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
              createElement(
              'div',
              {
                  style: {
                      width: '100px',
                      border: '2px gray solid',
                      height: '100px',
                      margin: '20px',
                      boxSizing: 'border-box',
                  },
              }, [
                  
              ]),
          ])
      ]);
    
    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with flex item containing only text not overflow flex container', async () => {
    const div = createElement('div',{
      style: {
        display: 'flex',
        alignContent: 'flex-start',
        alignItems: 'flex-start',
        width: '300px'
      }
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '100px',
          background: 'red',
          flexShrink: 0
        }
      }),
      createElement('div', {
        style: {
          height: '100px',
          background: 'green',
        }
      }, [
        createText('Flex item should not overflow container.')
      ]),
    ]);
    document.body.appendChild(div);
    await snapshot();
  });


});
