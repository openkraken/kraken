describe('flexbox flex-wrap', () => {
  it('should work with wrap', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          flexWrap: 'wrap',
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

  it('should work with nowrap', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          flexWrap: 'nowrap',
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

  it('should work with wrap-reverse', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          flexWrap: 'wrap-reverse',
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
