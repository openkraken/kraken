describe('flexbox flex-flow', () => {
  it('should work with row wrap', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexFlow: 'row wrap',
          justifyContent: 'center',
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
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with wrap column', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexFlow: 'wrap column',
          justifyContent: 'center',
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
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with row', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexFlow: 'row',
          justifyContent: 'center',
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
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with column', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexFlow: 'column',
          justifyContent: 'center',
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
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it("001", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green rectangle whose width is greater than height
  and the number within rectangle is '1 2 3 4' from left to right.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'row nowrap',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`4`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("002", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'row wrap',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`4`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("003", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'row wrap-reverse',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("004", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green rectangle whose width is greater than height
  and the number within rectangle is '1 2 3 4' from left to right.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'row-reverse nowrap',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("005", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'row-reverse wrap',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("006", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'row-reverse wrap-reverse',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("007-ref", async () => {
    let p;
    let div;
    let div_1;
    let div_2;
    let div_3;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square and no red, the number within square is '1 2 3 4' from top to bottom.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          'background-color': 'green',
          height: '25px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`1`)]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'background-color': 'green',
          height: '25px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`2`)]
    );
    div_2 = createElement(
      'div',
      {
        style: {
          'background-color': 'green',
          height: '25px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`3`)]
    );
    div_3 = createElement(
      'div',
      {
        style: {
          'background-color': 'green',
          height: '25px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`4`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(div_2);
    BODY.appendChild(div_3);


    await snapshot();
  })
  it("007", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square and no red, the number within square is '1 2 3 4' from top to bottom.`
        ),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'column nowrap',
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
          [createText(`1`)]
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
          [createText(`4`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("008", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'column wrap',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`4`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("009", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'column wrap-reverse',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("010", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled green square and no red, the number within square is '1 2 3 4' from top to bottom.`
        ),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'column-reverse nowrap',
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
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("011", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'column-reverse wrap',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
        createElement(
          'div',
          {
            style: {
              'background-color': 'green',
              height: '50px',
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
  it("012", async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`, the number within square is '1 2 3 4'
  from left to right, top to bottom.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          'background-color': 'red',
          display: 'flex',
          'flex-flow': 'column-reverse wrap-reverse',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
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
              width: '50px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  })
});
