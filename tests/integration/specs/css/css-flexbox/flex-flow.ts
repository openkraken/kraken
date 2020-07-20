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
    await matchScreenshot();
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
    await matchScreenshot();
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
    await matchScreenshot();
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
    await matchScreenshot();
  });
});
