describe('border_radius', () => {
  it('all_direction', async () => {
    let container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: '#252423',
      height: '500px',
    });

    for (let i = 0; i < 5; i++) {
      let dotEl = document.createElement('div');
      setElementStyle(dotEl, {
        display: 'inline-block',
        marginLeft: '5px',
        width: '40px',
        height: '40px',
        borderRadius: '20px',
        backgroundColor: '#FF4B4B',
      });
      container.appendChild(dotEl);
    }

    document.body.appendChild(container);

    await matchViewportSnapshot();
  });

  it('works with image', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/100x100-green.png',
        style: {
          'border-radius': '20px',
        },
      },
    );
    BODY.appendChild(image);

    await matchViewportSnapshot(0.1);
  });

  it('should work with percentage of one value', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            borderRadius: '100%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage of two values', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage border-radius and percentage sizing in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100%',
            height: '100%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage border-radius and percentage sizing of multiple children in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50%',
            height: '50%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        }),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage border-radius and percentage sizing in flex layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100%',
            height: '100%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage border-radius and percentage sizing of multiple children in flex layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50%',
            height: '50%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        }),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with border and percentage border-radius', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            border: '1px solid black',
            width: '100%',
            height: '100%',
            borderRadius: '100%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });
});
