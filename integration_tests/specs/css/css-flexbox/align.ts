/*auto generated*/
describe('align', () => {
  it('content_center', async () => {
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
          'align-content': 'center',
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

    await snapshot();
  });
  it('content_stretch', async () => {
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
          'align-content': 'stretch',
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

    await snapshot();
  });
});
