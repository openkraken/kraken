/*auto generated*/
describe('auto-margins', () => {
  it('002', async (done) => {
    let div;
    let div_1;
    let img;
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
        img = createElement('img', {
          style: {
            'box-sizing': 'border-box',
            margin: 'auto',
            width: '100px',
            height: '100px',
          },
        }),
      ]
    );
    document.body.appendChild(div);
    document.body.appendChild(div_1);

    await snapshot();
    img.src = 'assets/300x150-green.png';

    img.onload = async () => {
      await snapshot();
      done();
    };
  });

  it('align-items should not work when auto margin exists in flex column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-end',
          width: '300px',
          height: '300px',
          backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            margin: '0 auto',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('align-items should not work when auto margin exists in flex row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          alignItems: 'flex-end',
          width: '300px',
          height: '300px',
          backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            margin: 'auto 0',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('justify-content should not work when auto margin exists in flex column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'flex-end',
          width: '300px',
          height: '300px',
          backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            margin: 'auto 0',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('justify-content should not work when auto margin exists in flex row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'flex-end',
          width: '300px',
          height: '300px',
          backgroundColor: 'green'
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            margin: '0 auto',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });
});
