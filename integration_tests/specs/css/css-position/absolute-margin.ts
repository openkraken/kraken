describe('Position absolute with margin', () => {
  it('top and bottom auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('top and bottom not auto, margin-top and margin-bottom auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            top: '10px',
            bottom: '10px',
            marginTop: 'auto',
            marginBottom: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('top and bottom not auto, margin-top and margin-bottom auto, free space is negative', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            top: '150px',
            bottom: '150px',
            marginTop: 'auto',
            marginBottom: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('top bottom and margin-bottom not auto, margin-top auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            top: '20px',
            bottom: '20px',
            marginTop: 'auto',
            marginBottom: '50px',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('top bottom and margin-top not auto, margin-bottom auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            top: '20px',
            bottom: '20px',
            marginTop: '50px',
            marginBottom: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('top auto and bottom not auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            top: 'auto',
            bottom: '20px',
            marginTop: 'auto',
            marginBottom: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('top not auto and bottom auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            top: '20px',
            bottom: 'auto',
            marginTop: 'auto',
            marginBottom: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('left and right auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('left and right not auto, margin-left and margin-right auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            left: '10px',
            right: '10px',
            marginLeft: 'auto',
            marginRight: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('left and right not auto, margin-left and margin-right auto, free space is negative', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            left: '150px',
            right: '150px',
            marginLeft: 'auto',
            marginRight: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('left right and margin-right not auto, margin-left auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            left: '20px',
            right: '20px',
            marginLeft: 'auto',
            marginRight: '50px',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('left right and margin-left not auto, margin-right auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            left: '20px',
            right: '20px',
            marginLeft: '50px',
            marginRight: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('left auto and right not auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            left: 'auto',
            right: '20px',
            marginLeft: 'auto',
            marginRight: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('left not auto and right auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          width: '300px',
          height: '300px',
          position: 'relative',
          margin: '10px',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            background: 'blue',
            width: '100px',
            height: '100px',
            left: '20px',
            right: 'auto',
            marginLeft: 'auto',
            marginRight: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('relative to scroll container', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          border: '40px solid',
          background: 'yellow',
          height: '300px',
          position: 'relative',
          overflow: 'scroll',
          width: '300px',
          paddingTop: '40px'
        },
      },
      [
        createElement('div', {
          style: {
            background: 'blue',
            width: '100px',
            height: '100px',
            position: 'absolute',
            top: '20px',
            bottom: '20px',
            left: '20px',
            right: '20px',
            margin: 'auto',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
