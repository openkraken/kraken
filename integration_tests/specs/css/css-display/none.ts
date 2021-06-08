describe('Display', () => {
  it('should work with none', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '100px',
      height: '100px',
      display: 'none',
      backgroundColor: '#666',
    });

    document.body.appendChild(container);
    document.body.appendChild(
      document.createTextNode('The box should not display.')
    );

    await snapshot();
  });


  it('should works when changed from none to block', async (done) => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'none',
          width: '200px',
          height: '100px',
          backgroundColor: 'green',
        },
      },
      [
        createElement('span', {
          style: {
            backgroundColor: 'yellow',
          }
        }, [
          createText('changed to block'),
        ])
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
       div.style.display = 'block';
       await snapshot();
       done();
    })
  });

  it('should works when changed from block to none', async (done) => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '100px',
          backgroundColor: 'green',
        },
      },
      [
        createElement('span', {
          style: {
            backgroundColor: 'yellow',
          }
        }, [
          createText('changed to block'),
        ])
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
       div.style.display = 'none';
       await snapshot();
       done();
    })
  });
});
