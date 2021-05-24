describe('Box margin negative', () => {
  it('should work with top in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginTop: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with bottom in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
            marginBottom: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with left in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginLeft: '-20px',
          },
        }),
        createElement('div', {
          style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with right in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
            marginRight: '-20px',
          },
        }),
        createElement('div', {
          style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
          },
        }),
        createElement('div', {
          style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with top in flex layout and row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
            marginTop: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with bottom in flex layout and row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
            marginBottom: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with left in flex layout and row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginLeft: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with right in flex layout and row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginRight: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with top in flex layout and column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginTop: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with bottom in flex layout and column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginBottom: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with left in flex layout and column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginLeft: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with right in flex layout and column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '150px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginRight: '-20px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with flex-wrap wrap in flex layout and row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          flexWrap: 'wrap',
          width: '200px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            fontSize: '24px',
            background: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '120px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
            marginTop: '-30px',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
            marginLeft: '-20px',
            marginTop: '-20px',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with flex-wrap wrap in flex layout and column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          flexWrap: 'wrap',
          height: '100px',
          background: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            fontSize: '24px',
            background: 'red',
            marginRight: '-50px',
          },
        }),
        createElement('div', {
          style: {
            width: '120px',
            height: '50px',
            fontSize: '24px',
            background: 'blue',
          },
        }),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            fontSize: '24px',
            background: 'green',
            marginLeft: '-20px',
            marginTop: '-20px',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });
});
