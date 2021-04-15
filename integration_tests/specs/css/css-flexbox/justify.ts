/*auto generated*/
describe('justify', () => {
  it('content_center', async () => {
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
    1. the rectangle 1, 2, 3 show up in a row in a red rectangle and no gap between them.`),

        createText(`
    2. the rectangle 1, 2, 3 appear in middle of red rectangle.`),

        createText(`
    3. equal amounts of empty space between the left edge of the red rectangle and ractangle 1 and between the right edge of the red rectangle and rectangle 3.`),

        createText(`
    4. the height of the 1, 2, 3 is the same as the height of the red rectangle.`),
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
          'justify-content': 'center',
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
});
