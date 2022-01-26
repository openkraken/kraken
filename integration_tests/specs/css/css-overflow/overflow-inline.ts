/*auto generated*/
describe('overflow-inline', () => {
  it('transform-relative', async () => {
    let target;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          border: '1px solid black',
          width: '200px',
          overflow: 'auto',
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
          [
            createText(`
    scroll
    `),
            (target = createElement('div', {
              id: 'target',
              style: {
                display: 'inline-block',
                width: '20px',
                height: '20px',
                background: 'green',
                position: 'relative',
                top: '100px',
                transform: 'translateY(80px)',
                'box-sizing': 'border-box',
              },
            })),
            createText(`
    down
  `),
          ]
        ),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('box size is correct with position absolute child', async () => {
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          border: '1px solid black',
          width: '200px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
          scroll
        `),
        createElement('div', {
          id: 'target',
          style: {
            display: 'inline-block',
            width: '20px',
            height: '20px',
            background: 'green',
            position: 'absolute',
            top: '100px',
            transform: 'translateY(80px)',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);
    
    await snapshot();
  });

  it('scrollable size is correct with child of position relative', async (done) => {
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          border: '1px solid black',
          width: '200px',
          position: 'relative',
          overflow: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
          scroll
        `),
        createElement('div', {
          id: 'target',
          style: {
            display: 'inline-block',
            width: '20px',
            height: '20px',
            background: 'green',
            position: 'relative',
            top: '100px',
            // transform: 'translateY(80px)',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    requestAnimationFrame(async () => {
      container.scrollTo(0, 200);
      await snapshot();
      done();
    });
  });

  it('scrollable size is correct with child of transform', async (done) => {
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          border: '1px solid black',
          width: '200px',
          position: 'relative',
          overflow: 'auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
          scroll
        `),
        createElement('div', {
          id: 'target',
          style: {
            display: 'inline-block',
            width: '20px',
            height: '20px',
            background: 'green',
            transform: 'translateY(80px)',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(container);

    requestAnimationFrame(async () => {
      container.scrollTo(0, 200);
      await snapshot();
      done();
    });
  });
});
