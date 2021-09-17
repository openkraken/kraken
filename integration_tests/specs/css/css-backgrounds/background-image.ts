describe('background image', function() {
  it('should work with image of png', async () => {
    let div;
    let image;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
        },
      },
      [
        image = createElement('div', {
          style: {
            width: '200px',
            height: '200px',
            backgroundRepeat: 'no-repeat',
            backgroundImage: 'url(assets/100x100-green.png)'
          }
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with image of base64', async () => {
    let div;
    let image;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
        },
      },
      [
        image = createElement('div', {
          style: {
            width: '200px',
            height: '200px',
            backgroundRepeat: 'no-repeat',
            backgroundImage: 'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQMAAABKLAcXAAAAA1BMVEUAgACc+aWRAAAAE0lEQVR4AWOgKxgFo2AUjIJRAAAFeAABHs0ozQAAAABJRU5ErkJggg==)'
          }
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
