/*auto generated*/
describe('auto-margins', () => {
  it('002', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'absolute',
          height: '100px',
          width: '100px',
          'z-index': '1',
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            height: '25px',
            'background-color': 'green',
          },
        }),
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            height: '50px',
            background: 'transparent',
          },
        }),
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            height: '25px',
            'background-color': 'green',
          },
        }),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          width: '100px',
          height: '100px',
          'background-color': 'red',
          display: 'flex',
        },
      },
      [
        createElement('img', {
          src:
            'https://kraken.oss-cn-hangzhou.aliyuncs.com/images/300x150-green.png',
          style: {
            'box-sizing': 'border-box',
            margin: 'auto',
            width: '100px',
            height: '100px',
          },
        }),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await matchScreenshot();
  });
});
