describe('Box margin', () => {
  it('should work with radial-gradient', async () => {
    const div = document.createElement('div');
    div.style.margin = '10px 20px 20px 20px';
    div.style.backgroundColor = 'blue';

    document.body.appendChild(div);

    const div2 = document.createElement('div');
    div2.style.width = '10px';
    div2.style.height = '10px';

    div.appendChild(div2);

    const div3 = document.createElement('div');
    div3.style.width = '200px';
    div3.style.height = '200px';
    div3.style.backgroundImage =
      'radial-gradient(black 50%, red 0%, yellow 20%, blue 80%)';

    document.body.appendChild(div3);

    await snapshot();
  });

  it('should work with basic samples', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      margin: 0,
    });

    document.body.appendChild(div);
    div.style.margin = '20px';
    await snapshot();
  });

  it('should work with basic samples', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      margin: 0,
    });

    document.body.appendChild(div);
    div.style.margin = '20px';
    await snapshot();
  });

  it('should work with shorthand', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      marginTop: '10px',
      margin: '30px',
    });

    document.body.appendChild(div);
    await snapshot();
  });

  it('should can be removed', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      margin: '50px',
    });

    document.body.appendChild(container1);
    await snapshot();

    container1.style.margin = '';
    await snapshot();
  });

  it('should work with percentage', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100%',
            width: '100%',
            backgroundColor: 'yellow',
          }
        }, [
          createElement('div', {
            style: {
              height: '50px',
              width: '50px',
              backgroundColor: 'red',
            }
          }),
          createElement('div', {
            style: {
              height: '50px',
              width: '50px',
              margin: '20%',
              backgroundColor: 'green',
            }
          })
        ]),
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage of parents width and height not equal', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '200px',
          padding: '20px',
          backgroundColor: 'green',
        },
      },
      [
        createElement('div', {
          style: {
            height: '50px',
            width: '50px',
            margin: '100%',
            backgroundColor: 'yellow',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage of positioned element', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          position: 'relative',
          background: 'blue',
          border: '10px solid green',
          padding: '10px',
          width: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'yellow',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'div',
          {
            style: {
              position: 'absolute',
              background: 'pink',
              marginLeft: '100%',
            },
          },
          [(text = createText(`two`))]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with percentage after element is attached', async (done) => {
    let div2;
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '200px',
          padding: '20px',
          backgroundColor: 'green',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            height: '50px',
            width: '50px',
            backgroundColor: 'yellow',
          }
        }))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
       div2.style.marginTop = '100%';
       await snapshot();
       done();
    });
  });
});
