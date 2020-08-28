describe('max-width', () => {
  it('should work with non positioned element', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': '#999',
          height: '200px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div',
          {
            style: {
              display: 'relative',
              'background-color': 'green',
              height: '100px',
              maxWidth: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createText('fooooo')
          ]
        )
      ]
    );
    BODY.appendChild(flexbox);

    await matchViewportSnapshot();
  });


  it('should not work with positioned element', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          position: 'relative',
          'background-color': '#999',
          height: '200px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div',
          {
            style: {
              position: 'absolute',
              'background-color': 'green',
              height: '100px',
              maxWidth: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createText('fooooo')
          ]
        )
      ]
    );
    BODY.appendChild(flexbox);

    await matchViewportSnapshot();
  });

  it('should not work with flex item', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          position: 'relative',
          'background-color': '#999',
          height: '200px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div',
          {
            style: {
              'background-color': 'green',
              height: '100px',
              maxWidth: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            createText('fooooo')
          ]
        )
      ]
    );
    BODY.appendChild(flexbox);

    await matchViewportSnapshot();
  });
});
