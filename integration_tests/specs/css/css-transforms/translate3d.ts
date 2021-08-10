describe('Transform translate3d', () => {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'translate3d(100px, 100px, 100px)',
      })
    );

    await snapshot();
  });

  it('should work with percentage with x', async () => {
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
            transform: 'translate3d(50%, 0, 0)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage with y', async () => {
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
            transform: 'translate3d(0, 50%, 0)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage with x and y', async () => {
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
            transform: 'translate3d(50%, 50%, 0)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });
});
