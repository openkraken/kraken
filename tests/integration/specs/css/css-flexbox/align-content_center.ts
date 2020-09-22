/*auto generated*/
describe('align-content_center', () => {
  it('ref', async () => {
    let p;
    let spacer;
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
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createText(`
1. the rectangle 1, 2, 3 show up in a vertical column in a red rectangle and no gap between them.`),
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createText(`
2. the rectangle 1, 2, 3 appear in middle left of red rectangle.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          height: '200px',
          width: '80px',
          background: '#ff0000',
          'box-sizing': 'border-box',
        },
      },
      [
        (spacer = createElement('div', {
          id: 'spacer',
          style: {
            width: '50px',
            height: '25px',
            'box-sizing': 'border-box',
          },
        })),
        (test01 = createElement(
          'div',
          {
            id: 'test01',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
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
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
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
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
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

    await matchViewportSnapshot();
  });
});
