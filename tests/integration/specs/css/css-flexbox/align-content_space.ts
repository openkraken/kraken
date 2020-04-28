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

    await matchScreenshot();
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

    await matchScreenshot();
  });
});
