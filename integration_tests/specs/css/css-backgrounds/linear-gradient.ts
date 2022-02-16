describe('Background linear-gradient', () => {
  it('linear-gradient', async () => {
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
      'linear-gradient(to left, #333, #333 50%, #eee 75%, #333 75%)',
    });

    append(BODY, div1);
    await snapshot(div1);
  });

  fit('linear-gradient with many right brackets', async () => {
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      width: '200px',
      height: '100px',
      backgroundImage: 'linear-gradient(to right, rgba(35, 35, 35, 0.8), rgba(35, 35, 35, 0.1))'
    });

    append(BODY, div1);
    await snapshot(div1);
  });


  fit('linear-gradient and remove', async (done) => {
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
      'linear-gradient(to left, #333, #333 50%, #eee 75%, #333 75%)',
    });

    append(BODY, div1);
    await snapshot(div1);
    requestAnimationFrame(async () => {
      div1.style.backgroundImage = '';
      await snapshot(div1);
      done();
    });
  });

  it('conic-gradient', async () => {
    var div2 = document.createElement('div');
    Object.assign(div2.style, {
      width: '200px',
      height: '200px',
      backgroundImage:
      'conic-gradient(from 0.25turn at 50% 30%,red 20deg, orange 130deg, yellow 90deg, green 180deg, blue 270deg)',
    });

    append(BODY, div2);
    await snapshot(div2);
  });

  it('radial-gradient', async () => {
    var div3 = document.createElement('div');
    Object.assign(div3.style, {
      width: '200px',
      height: '200px',
      backgroundImage: 'radial-gradient(circle at 50% 50%, red 0%, yellow 20%, blue 80%)',
    });

    append(BODY, div3);
    await snapshot(div3);
  });

  it('linear-gradient-rotate', async () => {
    var div4 = document.createElement('div');
    Object.assign(div4.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
      'linear-gradient(135deg, red, red 10%, blue 75%, yellow 75%)',
    });
    append(BODY, div4);
    await snapshot(div4);
  });

  it("linear-gradient to right with color stop of px", async () => {

    let flexbox;

    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to right, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          display: 'flex',
          'justify-content': 'center',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it("linear-gradient to right with color stop of px and width not set", async () => {

    let flexbox;

    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to right, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          display: 'flex',
          'justify-content': 'center',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it("linear-gradient to bottom with color stop of px", async () => {

    let flexbox;

    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to bottom, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          display: 'flex',
          'justify-content': 'center',
          height: '200px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it("linear-gradient to bottom with color stop of px and height not set", async () => {

    let flexbox;
    let container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '300px',
        }
      }
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to bottom, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );

    container.appendChild(flexbox);
    BODY.appendChild(container);

    await snapshot();
  });

  it("linear-gradient to right with color stop not set", async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to right, blue, blue, red, red, orange, orange)',
          display: 'flex',
          'justify-content': 'center',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it("linear-gradient to bottom with color stop not set", async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
            'linear-gradient(to bottom, blue, blue, red, red, orange, orange)',
          display: 'flex',
          'justify-content': 'center',
          height: '200px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
