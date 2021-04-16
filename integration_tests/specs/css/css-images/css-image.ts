/*auto generated*/
describe('css-image', () => {
  it('fallbacks-and-annotations-ref', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'green',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await snapshot();
  });
  xit('fallbacks-and-annotations', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        background: 'image("green.png", green)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await snapshot();
  });
  xit('fallbacks-and-annotations002', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        color: 'white',
        'background-color': 'red',
        'background-image': 'image("assets/1x1-green.png")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await snapshot();
  });
  xit('fallbacks-and-annotations003', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        'background-image':
          'image("1x1-green.svg", "assets/1x1-green.png","assets/1x1-green.gif")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await snapshot();
  });
  xit('fallbacks-and-annotations004', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if background is green and no red.`)]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        'background-image':
          'image("1x1-green.svg", "1x1-green.png", "assets/1x1-green.gif")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await snapshot();
  });
  xit('fallbacks-and-annotations005', async () => {
    let p;
    let square;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if background is pale green and no green and no red.`
        ),
      ]
    );
    square = createElement('div', {
      class: 'square',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        'background-image':
          'image(rgba(0,0,255,0.5)), url("assets/1x1-green.png")',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(square);

    await snapshot();
  });

 it('size works width position absolute' , async (done) => {
    let n1, n2;
    n1 = createElementWithStyle(
       'div',
       {
         display: 'flex',
         position: 'relative',
         flexDirection: 'column',
         justifyContent: 'center',
         alignItems: 'center',
         width: '300px',
         height: '300px',
         backgroundColor: 'gray',
       },
       [
        (n2 = createElementWithStyle(
          'img',
           {
             position: 'absolute',
             top: '20px',
             left: '20px',
             width: '100px',
             height: '100px',
           },
        ))
       ]
     );
    BODY.appendChild(n1);
    n2.src = 'https://img.alicdn.com/tfs/TB14bXLHFT7gK0jSZFpXXaTkpXa-100-100.png';

    n2.onload = async () => {
      await snapshot();
      done();
    };
  });

  it('should work with image of no width in flex layout', async (done) => {
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
        image = createElement('img', {
            src: 'https://gw.alicdn.com/tfs/TB1Fejan7cx_u4jSZFlXXXnUFXa-200-200.png',
            style: {
                height: '100px'
            }
        }),
      ]
    );
    BODY.appendChild(div);
    image.src = 'https://gw.alicdn.com/tfs/TB1Fejan7cx_u4jSZFlXXXnUFXa-200-200.png';

    image.onload = async () => {
      await snapshot();
      done();
    };
  });

  it('should work with percentage of cached image', async (done) => {
    let div;
    let image1;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'red',
          position: 'relative',
        },
      },
      [
        (image1 = createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            height: '50%',
            width: '50%',
          }
        })),
      ]
    );

    BODY.appendChild(div);

    setTimeout(async () => {
      let image2 = createElement('img', {
        src: 'assets/100x100-green.png',
        style: {
          height: '50%',
          width: '50%',
        }
      });
      div.appendChild(image2);
      await snapshot(0.1);
      done();
    }, 1000);
  });
});
