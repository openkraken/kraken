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
              position: 'relative',
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

  it('should work with positioned replaced element', async () => {
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
        createElement('img', {
            src: 'assets/100x100-green.png',
            style: {
              position: 'absolute',
              'background-color': 'green',
              height: '100px',
              maxWidth: '100px',
              'box-sizing': 'border-box',
            },
          },
        )
      ]
    );
    BODY.appendChild(flexbox);

    await matchViewportSnapshot(0.1);
  });

  it('should work with flex-item of replaced element', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'background-color': '#999',
          height: '200px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
            src: 'assets/100x100-green.png',
            style: {
              'background-color': 'green',
              height: '100px',
              maxWidth: '100px',
              'box-sizing': 'border-box',
            },
          },
        )
      ]
    );
    BODY.appendChild(flexbox);

    await matchViewportSnapshot(0.1);
  });
});
