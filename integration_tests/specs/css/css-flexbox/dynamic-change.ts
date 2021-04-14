/*auto generated*/
describe('dynamic-change', () => {
  xit('simplified-layout-002', async () => {
    let target;
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          width: '100px',
          height: '100px',
          'background-color': 'red',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              contain: 'layout size',
              height: '100px',
              flex: '1',
              'background-color': 'green',
            },
          },
          [
            (target = createElement('div', {
              id: 'target',
              style: {
                'box-sizing': 'border-box',
              },
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    // document.body.offsetTop;
    // document.getElementById('target').style.width = '1px';

    await snapshot();

    await snapshot();
  });
  it('simplified-layout', async () => {
    let child;
    let it1;
    let it2;
    let flex;
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'relative',
        },
      },
      [
        (flex = createElement(
          'div',
          {
            id: 'flex',
            style: {
              display: 'flex',
              'flex-direction': 'column',
              'flex-wrap': 'wrap',
              position: 'absolute',
              top: '20px',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (it1 = createElement(
              'div',
              {
                id: 'it1',
                style: {
                  'background-color': 'green',
                  flex: 'none',
                  height: '100px',
                  'min-height': '0',
                  position: 'relative',
                  'box-sizing': 'border-box',
                },
              },
              [
                (child = createElement('div', {
                  id: 'child',
                  style: {
                    position: 'absolute',
                    top: '0',
                    left: '0',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            )),
            (it2 = createElement('div', {
              id: 'it2',
              style: {
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(div);
    await snapshot();

    it2.style.width = '50px';
    flex.style.top = '0px';
    child.style.top = '1px';

    await snapshot();
  });
});
