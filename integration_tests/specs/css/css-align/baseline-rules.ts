describe('Baseline-rules flexbox', () => {
  const wrapperStyle = {
    border: '5px solid black',
    position: 'relative',
    width: '200px',
    height: '150px',
    margin: '10px',
  };

  const inlineBoxStyle = {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
    display: 'inline-block',
  };

  const boxStyle = {
    border: '10px solid cyan',
    padding: '15px',
    margin: '20px 0px',
    backgroundColor: 'yellow',
  };

  const magentaDottedBorder = {
    border: '5px solid magenta',
  };

  it('synthesized-baseline-flexbox-001', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'inline-flex',
    });
    append(wrapper, box);
    append(BODY, wrapper);

    await snapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-002', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-block',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'inline-flex',
    });
    append(magenta, box);
    append(BODY, wrapper);
    await snapshot();
  });

  it('synthesized-baseline-flexbox-003', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-block',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'flex',
    });
    append(magenta, box);
    append(BODY, wrapper);
    await snapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-004', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-flex',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await snapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-005', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-block',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'flex',
    });
    append(magenta, box);
    append(BODY, wrapper);
    await snapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-006', async () => {
    let wrapper = createElementWithStyle('div', {
      ...wrapperStyle,
      display: 'flex',
      alignItems: 'baseline',
    });
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-flex',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await snapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-007', async () => {
    let wrapper = createElementWithStyle('div', {
      ...wrapperStyle,
      display: 'flex',
      alignItems: 'baseline',
    });
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'flex',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await snapshot(wrapper);
  });

  it('flex layout nest flow layout', async () => {
    let p;
    let div1;
    let div2;
    let div3;
    let div4;
    let test;

    test = createElement(
      'div',
      {
        style: {
          border: '1px solid black',
          height: '200px',
          display: 'flex',
          flexWrap: 'wrap',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '20px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aa a`)]
        )),
        (div2 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '10px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`bbbb b`)]
        )),
        (div3 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '30px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`c c c c  `)]
        )),
        (div4 = createElement(
          'img',
          {
            src: 'assets/100x100-green.png',
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              width: '50px',
            },
          },
        )),
        createElement('div', {
          style: {
            display: 'inline-block',
            alignSelf: 'baseline',
            flexWrap: 'wrap',
            width: '170px',
            fontSize: '30px',
            backgroundColor: 'red'
          }
        }, [
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'baseline',
              width: '60px',
              height: '40px',
              fontSize: '20px',
              backgroundColor: 'yellow'
            }
          }, [
            createText('ee')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '80px',
              fontSize: '25px',
              backgroundColor: 'blue'
            }
          }, [
            createText('ff gggg')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '60px',
              height: '60px',
              fontSize: '30px',
              backgroundColor: 'purple'
            }
          }, [
            createText('hh')
          ]),

        ])
      ]
    );
    BODY.appendChild(test);

    await snapshot(0.1);
  });

  it('flex layout nest flex layout', async () => {
    let p;
    let div1;
    let div2;
    let div3;
    let div4;
    let test;

    test = createElement(
      'div',
      {
        style: {
          border: '1px solid black',
          height: '200px',
          display: 'flex',
          flexWrap: 'wrap',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '20px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aa a`)]
        )),
        (div2 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '10px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`bbbb b`)]
        )),
        (div3 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '30px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`c c c c  `)]
        )),
        (div4 = createElement(
          'img',
          {
            src: 'assets/100x100-green.png',
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              width: '50px',
            },
          },
        )),
        createElement('div', {
          style: {
            display: 'inline-flex',
            alignSelf: 'baseline',
            flexWrap: 'wrap',
            width: '170px',
            fontSize: '30px',
            backgroundColor: 'red'
          }
        }, [
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'baseline',
              width: '60px',
              height: '40px',
              fontSize: '20px',
              backgroundColor: 'yellow'
            }
          }, [
            createText('ee')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '80px',
              fontSize: '25px',
              backgroundColor: 'blue'
            }
          }, [
            createText('ff gggg')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '60px',
              height: '60px',
              fontSize: '30px',
              backgroundColor: 'purple'
            }
          }, [
            createText('hh')
          ]),

        ])
      ]
    );
    BODY.appendChild(test);

    await snapshot(0.1);
  });

  it('flow layout nest flex layout', async () => {
    let p;
    let div1;
    let div2;
    let div3;
    let div4;
    let test;

    test = createElement(
      'div',
      {
        style: {
          border: '1px solid black',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '20px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aa a`)]
        )),
        (div2 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '10px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`bbbb b`)]
        )),
        (div3 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '30px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`c c c c  `)]
        )),
        (div4 = createElement(
          'img',
          {
            src: 'assets/100x100-green.png',
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              width: '50px',
            },
          },
        )),
        createElement('div', {
          style: {
            display: 'inline-flex',
            alignSelf: 'baseline',
            flexWrap: 'wrap',
            width: '170px',
            fontSize: '30px',
            backgroundColor: 'red'
          }
        }, [
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'baseline',
              width: '60px',
              height: '40px',
              fontSize: '20px',
              backgroundColor: 'yellow'
            }
          }, [
            createText('ee')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '80px',
              fontSize: '25px',
              backgroundColor: 'blue'
            }
          }, [
            createText('ff gggg')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '60px',
              height: '60px',
              fontSize: '30px',
              backgroundColor: 'purple'
            }
          }, [
            createText('hh')
          ]),

        ])
      ]
    );
    BODY.appendChild(test);

    await snapshot(0.1);
  });

  it('flow layout nest flow layout', async () => {
    let p;
    let div1;
    let div2;
    let div3;
    let div4;
    let test;

    test = createElement(
      'div',
      {
        style: {
          border: '1px solid black',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (div1 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '20px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aa a`)]
        )),
        (div2 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '10px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`bbbb b`)]
        )),
        (div3 = createElement(
          'div',
          {
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              backgroundColor: 'green',
              'font-size': '30px',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`c c c c  `)]
        )),
        (div4 = createElement(
          'img',
          {
            src: 'assets/100x100-green.png',
            style: {
              display: 'inline-block',
              'align-self': 'baseline',
              width: '50px',
            },
          },
        )),
        createElement('div', {
          style: {
            display: 'inline-block',
            alignSelf: 'baseline',
            flexWrap: 'wrap',
            width: '170px',
            fontSize: '30px',
            backgroundColor: 'red'
          }
        }, [
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'baseline',
              width: '60px',
              height: '40px',
              fontSize: '20px',
              backgroundColor: 'yellow'
            }
          }, [
            createText('ee')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '80px',
              fontSize: '25px',
              backgroundColor: 'blue'
            }
          }, [
            createText('ff gggg')
          ]),
          createElement('div', {
            style: {
              display: 'inline-block',
              alignSelf: 'bottom',
              width: '60px',
              height: '60px',
              fontSize: '30px',
              backgroundColor: 'purple'
            }
          }, [
            createText('hh')
          ]),

        ])
      ]
    );
    BODY.appendChild(test);

    await snapshot(0.1);
  });
});

describe('Baseline-rules inline-block', () => {
  const wrapperStyle = {
    border: '1px solid block',
    position: 'relative',
    width: '200px',
    height: '150px',
    margin: '10px'
  };

  const canvasStyle = {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue'
  };

  const magentaBorderStyle = {
    border: '5px solid magenta'
  };

  const borderPaddingMargin = {
    border: '10px solid cyan',
    padding: '15px',
    margin: '20px 0px',
    backgroundColor: 'yellow'
  };

  it('synthesized-baseline-inline-block-001', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let left = createElementWithStyle('canvas', canvasStyle);
    let box = createElementWithStyle('div', {
      borderPaddingMargin,
      display: 'inline-flex'
    });
    append(wrapper, left);
    append(wrapper, box);
    append(BODY, wrapper);
    await snapshot();
  });
});
