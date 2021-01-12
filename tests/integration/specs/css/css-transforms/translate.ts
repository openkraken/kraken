describe('Transform translate', () => {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'translate(10px, 6px )',
      })
    );

    await matchViewportSnapshot();
  });

  it('should work with percentage with one value', async () => {
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
                transform: 'translate(40%)',
                backgroundColor: 'green',
            }
        })
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage with two values', async () => {
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
                transform: 'translate(40%, 20%)',
                backgroundColor: 'green',
            }
        })
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });
});
