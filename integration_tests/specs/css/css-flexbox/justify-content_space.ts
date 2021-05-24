/*auto generated*/
describe('justify-content_space', () => {
  it('around', async () => {
    let p;
    let test01;
    let test02;
    let test03;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if:`),

        createText(`
    1. the rectangle 1, 2, 3 show up in a row in a red rectangle.`),

        createText(`
    2. the rectangle 1, 2, 3 are distributed such that the empty space between any two adjacent rectangle is the same, and the empty space of the row before the first and after the last rectangle are half the size of the other empty spaces.`),

        createText(`
    3. the height of the 1, 2, 3 is the same as the height of the red rectangle.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: '#ff0000',
          height: '200px',
          width: '200px',
          display: 'flex',
          'justify-content': 'space-around',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            id: 'test01',
            style: {
              'text-align': 'center',
              'font-size': '20px',
              width: '30px',
              background: '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            id: 'test02',
            style: {
              'text-align': 'center',
              'font-size': '20px',
              width: '30px',
              background: '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            id: 'test03',
            style: {
              'text-align': 'center',
              'font-size': '20px',
              width: '30px',
              background: '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await snapshot();
  });
  it('between-001', async () => {
    let p;
    let test01;
    let test02;
    let test03;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if:`),

        createText(`
    1. the rectangle 1, 2, 3 show up in a row in a red rectangle.`),

        createText(`
    2. No gap between the left edge of red rectangle and the left of rectangle 1, no gap between the right edge of red rectangle and the right of rectangle 3 too, and rectangle 2 is distributed so that the empty space between rectangle 1 and rectangle 3 is the same.`),

        createText(`
    3. the height of the 1, 2, 3 is the same as the height of the red rectangle.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: '#ff0000',
          height: '200px',
          width: '200px',
          display: 'flex',
          'justify-content': 'space-between',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            id: 'test01',
            style: {
              'text-align': 'center',
              'font-size': '20px',
              width: '30px',
              background: '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            id: 'test02',
            style: {
              'text-align': 'center',
              'font-size': '20px',
              width: '30px',
              background: '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            id: 'test03',
            style: {
              'text-align': 'center',
              'font-size': '20px',
              width: '30px',
              background: '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await snapshot();
  });
  it('between-002', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        'data-expected-height': '500',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'justify-content': 'space-between',
          'min-height': '500px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`First item`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Second item`)]
        ),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
