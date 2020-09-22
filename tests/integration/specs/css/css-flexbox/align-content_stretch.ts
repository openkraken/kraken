/*auto generated*/
describe('align-content_stretch', () => {
  it('ref', async () => {
    let p;
    let test01;
    let spacerone;
    let test02;
    let spacertwo;
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
1. the rectangle 1, 2, 3 show up in a vertical column in a red rectangle.`),
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createText(`
2. No gap between the top of red rectangle and the top of rectangle 1, and rectangle 1 , 2, 3 are distributed so that the empty space in the column between 1 , 2 , 3 is the same.
`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          height: '210px',
          width: '80px',
          background: '#ff0000',
          'box-sizing': 'border-box',
        },
      },
      [
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
        (spacerone = createElement('div', {
          id: 'spacerone',
          style: {
            width: '50px',
            height: '20px',
            'box-sizing': 'border-box',
          },
        })),
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
        (spacertwo = createElement('div', {
          id: 'spacertwo',
          style: {
            width: '50px',
            height: '20px',
            'box-sizing': 'border-box',
          },
        })),
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
