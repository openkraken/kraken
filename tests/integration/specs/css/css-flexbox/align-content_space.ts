/*auto generated*/
describe('align-content_space', () => {
  it('around', async () => {
    let test01;
    let test02;
    let test03;
    let test;
    test = createElement(
      'div',
      {
        style: {
          'background-color': '#ff0000',
          height: '200px',
          width: '80px',
          display: 'flex',
          'flex-wrap': 'wrap',
          'align-content': 'space-around',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await matchViewportSnapshot();
  });
  it('between', async () => {
    let test01;
    let test02;
    let test03;
    let test;
    test = createElement(
      'div',
      {
        style: {
          'background-color': '#ff0000',
          height: '200px',
          width: '80px',
          display: 'flex',
          'flex-wrap': 'wrap',
          'align-content': 'space-between',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              'background-color': '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await matchViewportSnapshot();
  });

  it('between-ref', async () => {
    let p;
    let test01;
    let spacer;
    let spacer_1;
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
1. the rectangle 1, 2, 3 show up in a vertical column in a red rectangle.`),
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createText(`
2. No gap between the top of red rectangle and the top of  rectangle 1, no gap between the bottom of red rectangle and the bottom of rectangle 3 too, and rectangle 2 is distributed so that the empty space between rectangle 1 and rectangle 3 is the same.`),
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
        (spacer = createElement('div', {
          id: 'spacer',
          style: {
            width: '50px',
            height: '25px',
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
        (spacer_1 = createElement('div', {
          id: 'spacer',
          style: {
            width: '50px',
            height: '25px',
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
  it('around-ref', async () => {
    let p;
    let halfspacer;
    let test01;
    let spacer;
    let spacer_1;
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
1. the rectangle 1, 2, 3 show up in a vertical column in a red rectangle.`),
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
        createText(`
2. the rectangle 1, 2, 3 are distributed such that the empty space between any two adjacent rectangle is the same, and the empty space of the column before the first and after the last rectangle are half the size of the other empty spaces.`),
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
        (halfspacer = createElement('div', {
          id: 'halfspacer',
          style: {
            width: '50px',
            height: '10px',
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
        (spacer = createElement('div', {
          id: 'spacer',
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
        (spacer_1 = createElement('div', {
          id: 'spacer',
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
