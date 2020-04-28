/*auto generated*/
describe('dynamic-bsize', () => {
  it('change-ref', async () => {
    let myHeightChanges;
    let div;
    div = createElement(
      'div',
      {
        style: {
          border: '1px solid #000',
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '1px solid #000',
              'box-sizing': 'border-box',
              height: 'auto',
            },
          },
          [
            (myHeightChanges = createElement('div', {
              id: 'myHeightChanges',
              style: {
                border: '1px solid #000',
                width: '100px',
                height: '200px',
                'background-color': 'green',
                'box-sizing': 'border-box',
              },
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();
  });
  it('change', async () => {
    let myHeightChanges;
    let div;
    div = createElement(
      'div',
      {
        style: {
          border: '1px solid #000',
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '1px solid #000',
              'box-sizing': 'border-box',
              height: 'auto',
            },
          },
          [
            (myHeightChanges = createElement('div', {
              id: 'myHeightChanges',
              style: {
                border: '1px solid #000',
                width: '100px',
                height: '100px',
                'background-color': 'green',
                'box-sizing': 'border-box',
              },
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await matchScreenshot();

    myHeightChanges.style.height = '200px';

    await matchScreenshot();
  });
});
