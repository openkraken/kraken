/*auto generated*/
describe('justify-content', () => {
  it('001', async () => {
    let p;
    let blue;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
            'linear-gradient(to right, blue 0, blue 75px, red 75px, red 225px, orange 225px, orange 300px)',
          display: 'flex',
          'justify-content': 'center',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (blue = createElement('div', {
          class: 'blue',
          style: {
            'background-color': 'blue',
            width: '76px',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            'background-color': 'orange',
            width: '76px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
            'linear-gradient(to right, red 0, red 150px, orange 150px, orange 300px)',
          display: 'flex',
          'justify-content': 'flex-start',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '75px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '75px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
            'linear-gradient(to right, blue 0, blue 150px, red 150px, red 300px)',
          display: 'flex',
          'justify-content': 'flex-end',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'orange',
            width: '75px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'orange',
            width: '75px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let blue;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
            'linear-gradient(to right, red 0, red 75px, blue 75px, blue 150px, orange 150px, orange 225px, red 225px, red 300px)',
          display: 'flex',
          'justify-content': 'space-between',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (blue = createElement('div', {
          id: 'blue',
          style: {
            'background-color': 'blue',
            width: '76px',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            'background-color': 'orange',
            width: '76px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('005', async () => {
    let p;
    let blue;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a single blue rectangle on the left, a single orange rectangle directly to its right, and there is no red visible on the page.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
            'linear-gradient(to right, blue 0, blue 38px, red 38px, red 112px, blue 112px, blue 150px, orange 150px, orange 188px, red 188px, red 262px, orange 262px, orange 300px)',
          display: 'flex',
          'justify-content': 'space-around',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (blue = createElement('div', {
          id: 'blue',
          style: {
            'background-color': 'blue',
            width: '76px',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            'background-color': 'orange',
            width: '76px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
