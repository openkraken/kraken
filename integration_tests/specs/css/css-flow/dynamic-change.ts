describe('dynamic-change', () => {
  it('change inner box width in nested flow layout', async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-block',
          padding: '10px',
          backgroundColor: 'green',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            backgroundColor: 'yellow',
            padding: '10px',
          }
        }, [
          (div3 = createElement('div', {
            style: {
              backgroundColor: 'lightblue',
              width: '200px',
            }
          }, [
            createText('The quick brown fox jumps over the lazy dog.')
          ]))
        ]))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div3.style.width = '300px';
      await snapshot();
      done();
    });
  });

  it('change outer box width in nested flow layout', async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-block',
          width: '200px',
          padding: '10px',
          backgroundColor: 'green',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            backgroundColor: 'yellow',
            padding: '10px',
          }
        }, [
          (div3 = createElement('div', {
            style: {
              backgroundColor: 'lightblue',
            }
          }, [
            createText('The quick brown fox jumps over the lazy dog.')
          ]))
        ]))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div.style.width = '300px';
      await snapshot();
      done();
    });
  });
});
