describe('Background-origin', () => {
  it('works with default value as padding-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundImage:
              'url(assets/cat.png)',
            backgroundRepeat: 'no-repeat',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot(0.2);
  });

  it('works with border-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundImage:
              'url(assets/cat.png)',
            backgroundRepeat: 'no-repeat',
            backgroundOrigin: 'border-box',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('works with padding-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundImage:
              'url(assets/cat.png)',
            backgroundRepeat: 'no-repeat',
            backgroundOrigin: 'padding-box',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('works with content-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundImage:
              'url(assets/cat.png)',
            backgroundRepeat: 'no-repeat',
            backgroundOrigin: 'content-box',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });
});
