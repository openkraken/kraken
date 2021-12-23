/*auto generated*/
describe('align-items', () => {
  it('001', async () => {
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
          'align-items': 'center',
          display: 'flex',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '52px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '52px',
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
  it('002', async () => {
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
          'align-items': 'flex-start',
          display: 'flex',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '51px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '51px',
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
          'align-items': 'flex-end',
          display: 'flex',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '51px',
            width: '150px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '51px',
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
    let div1;
    let div2;
    let div3;
    let div4;
    let div5;
    let div6;
    let div7;
    let div8;
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': 'red',
          'align-items': 'baseline',
          display: 'flex',
          'flex-wrap': 'wrap',
          height: '100px',
          width: '300px',
          color: 'yellow',
          // @TODO: disable line-height cause line-height rule for inline level element differs from browser.
          font: '20px Ahem',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d1`)]
        )),
        (div2 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d2`)]
        )),
        (div3 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'font-size': '40px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d3`)]
        )),
        (div4 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d4`)]
        )),
        (div5 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d5`)]
        )),
        (div6 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d6`)]
        )),
        (div7 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'font-size': '40px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d7`)]
        )),
        (div8 = createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              color: 'yellow',
              font: '20px/1em Ahem',
              width: '75px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d8`)]
        )),
      ]
    );
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
          'align-items': 'stretch',
          display: 'flex',
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
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('006', async () => {
    let p;
    let block;
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
    block = createElement(
      'div',
      {
        style: {
          position: 'absolute',
          width: '300px',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            width: '200px',
            height: '50px',
            'background-color': 'yellow',
          },
        }),
      ]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          font: '50px/1 Ahem',
          'background-color': 'green',
          'flex-direction': 'column',
          'align-items': 'flex-start',
          display: 'flex',
          width: '300px',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'red',
              color: 'red',
            },
          },
          [createText(`XXXX`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(block);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('007', async () => {
    let div;
    let div_1;
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        position: 'absolute',
        width: '100px',
        height: '100px',
        'background-color': 'green',
      },
    });
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '100px',
          'line-height': '20px',
          'align-items': 'center',
          'background-color': 'green',
        },
      },
      [
        createElement('img', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('baseline-overflow-non-visible', async () => {
    let overflow;
    let flex;
    flex = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'align-items': 'baseline',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`XX`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            (overflow = createElement(
              'div',
              {
                style: {
                  overflow: 'hidden',
                  height: '20px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`YY`)]
            )),
          ]
        ),
      ]
    );
    BODY.appendChild(flex);

    await snapshot();
  });

  it("works with baseline in nested elements", async () => {
    let container;
    container = createElement(
      'div',
      {style: {
        display: 'flex',
        'box-sizing': 'border-box',
        height: '100px',
        width: '500px',
        alignItems: 'baseline'
      }},
      [
        (createElement('div', {
          style: {
            'box-sizing': 'border-box',
            margin: '20px 0 0',
            height: '200px',
            width: '100px',
            'background-color': 'red',
            display: 'inline-block',
          }})),
        (createElement(
          'div',
          {style: {
            'box-sizing': 'border-box',
            height: '200px',
            width: '300px',
            display: 'inline-block',
            backgroundColor: '#999'
          }},
          [
            (createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '150px',
                width: '100px',
                'background-color': 'yellow',
                display: 'inline-block',
              }})),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it("work with baseline in nested block elements", async () => {
    let container;
    container = createElement(
      'div',
      {style: {
        display: 'flex',
        'box-sizing': 'border-box',
        height: '100px',
        width: '500px',
        alignItems: 'baseline'
      }},
      [
        (createElement('div', {
          style: {
            'box-sizing': 'border-box',
            margin: '20px 0 0',
            height: '200px',
            width: '100px',
            'background-color': 'red',
            display: 'inline-block',
          }})),
        (createElement(
          'div',
          {style: {
            'box-sizing': 'border-box',
            height: '200px',
            width: '300px',
            display: 'inline-block',
            backgroundColor: '#999'
          }},
          [
            (createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '150px',
                width: '100px',
                'background-color': 'yellow',
              }})),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it("work with baseline in nested block elements and contain text", async () => {
    let container;
    container = createElement(
      'div',
      {style: {
        display: 'flex',
        'box-sizing': 'border-box',
        height: '100px',
        width: '500px',
        alignItems: 'baseline'
      }},
      [
        (createElement('div', {
          style: {
            'box-sizing': 'border-box',
            margin: '20px 0 0',
            height: '200px',
            width: '100px',
            'background-color': 'red',
            display: 'inline-block',
          }})),
        (createElement(
          'div',
          {style: {
            'box-sizing': 'border-box',
            height: '200px',
            width: '300px',
            display: 'inline-block',
            backgroundColor: '#999'
          }},
          [
            (createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '150px',
                width: '100px',
                'background-color': 'yellow',
              }},
              [
                  createText('foo bar')
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it("works with stretch in row flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'row',
        width: '300px',
        margin: '50px',
        padding: '40px 0',
        height: '100px',
        alignItems: 'stretch',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           height: '30px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            width: '100px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it("works with flex-start in row flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'row',
        width: '300px',
        margin: '50px',
        padding: '40px 0',
        height: '100px',
        alignItems: 'flex-start',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           height: '30px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            width: '100px',
            height: '150px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it("works with center in row flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'row',
        width: '300px',
        margin: '50px',
        padding: '40px 0',
        height: '100px',
        alignItems: 'center',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           height: '30px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            width: '100px',
            height: '150px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it("works with flex-end in row flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'row',
        width: '300px',
        margin: '50px',
        padding: '40px 0',
        height: '100px',
        alignItems: 'flex-end',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           height: '30px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            width: '100px',
            height: '100px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it("works with stretch in column flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'column',
        width: '300px',
        margin: '50px',
        padding: '0 40px',
        height: '100px',
        alignItems: 'stretch',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           width: '50px',
           height: '20px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            height: '30px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it("works with flex-start in column flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'column',
        width: '300px',
        margin: '50px',
        padding: '0 40px',
        height: '100px',
        alignItems: 'flex-start',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           width: '50px',
           height: '20px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            width: '350px',
            height: '30px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it("works with center in column flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'column',
        width: '300px',
        margin: '50px',
        padding: '0 40px',
        height: '100px',
        alignItems: 'center',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           width: '50px',
           height: '20px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            width: '350px',
            height: '30px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);
    await snapshot();
  });

  it("works with flex-end in column flex direction when flex-grow is set", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'column',
        width: '300px',
        margin: '50px',
        padding: '0 40px',
        height: '100px',
        alignItems: 'flex-end',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           flexGrow: 1,
           width: '50px',
           height: '20px',
           overflow: 'hidden',
           backgroundColor: 'red',
          }
        }),
        createElement('div', {
          style: {
            display: 'flex',
            position: 'relative',
            width: '350px',
            height: '30px',
            backgroundColor: 'yellow'
          }
        })
      ]
    );
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("works with stretch in row direction when flex-wrap is nowrap", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'row',
        width: '300px',
        height: '100px',
        alignItems: 'stretch',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           width: '100px',
           backgroundColor: 'red',
          }
        }),
      ]
    );
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("does not work with stretch in row direction when flex-wrap is wrap", async () => {
    let containingBlock = createViewElement(
      {
        position: 'relative',
        flexDirection: 'row',
        width: '300px',
        height: '100px',
        alignItems: 'stretch',
        flexWrap: 'wrap',
        backgroundColor: '#999',
      },
      [
        createElement('div', {
          style: {
           display: 'flex',
           flexDirection: 'row',
           width: '100px',
           backgroundColor: 'red',
          }
        }),
      ]
    );
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it('does work with stretch when min-height exists and height does not exist', async () => {
    let flexbox;

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
      ]
    );

    BODY.appendChild(flexbox);


    await snapshot();
  });

  it('does not work with stretch when height exists', async () => {
    let flexbox;

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
            'height': '50px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(flexbox);


    await snapshot();
  });

  it('does work with stretch when min-width exists and width does not exist', async () => {
    let flexbox;

    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          flexDirection: 'column',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'height': '50px',
            minWidth: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(flexbox);


    await snapshot();
  });

  it('does not work with stretch when width exists', async () => {
    let flexbox;

    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          flexDirection: 'column',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'height': '50px',
            width: '100px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(flexbox);


    await snapshot();
  });

  it('does not work with stretch when align-self of flex item changed from auto to flex-start', async (done) => {
    let flexbox;
    let flexitem;

    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          flexDirection: 'column',
          width: '200px',
          height: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexitem = createElement('div', {
          style: {
            'height': '50px',
            'background-color': 'lightblue',
            'box-sizing': 'border-box',
            // 'align-self': 'flex-start',
          },
        })),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();

    requestAnimationFrame(async () => {
      flexitem.style.alignSelf = 'flex-start';
      await snapshot();
      done();
    });
  });

  it('should works with img with no size set', async () => {
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
            "marginLeft": "20px",
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot(0.1);
  });
});

