/*auto generated*/
describe('fit-content', () => {
  xit('item-001', async () => {
    let widthSetter;
    let mainSizeDependsOnCrossSize;
    let flexItem;
    let flexbox;
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'block',
              'background-color': 'red',
              'align-self': 'start',
              'box-sizing': 'border-box',
            },
          },
          [
            (widthSetter = createElement('div', {
              id: 'widthSetter',
              style: {
                width: '100px',
                height: '50px',
                'background-color': 'green',
                'box-sizing': 'border-box',
              },
            })),
            (mainSizeDependsOnCrossSize = createElement('div', {
              id: 'mainSizeDependsOnCrossSize',
              style: {
                'padding-bottom': '50%',
                'background-color': 'green',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });
  it('item-002', async () => {
    let p;
    let fitContentItem;
    let heightSettingItem;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          display: 'flex',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (fitContentItem = createElement('div', {
          class: 'fit-content-item',
          style: {
            'background-color': 'green',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (heightSettingItem = createElement('div', {
          class: 'height-setting-item',
          style: {
            height: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
