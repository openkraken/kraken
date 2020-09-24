/*auto generated*/
describe('multiline-reverse', () => {
  xit('wrap-baseline', async () => {
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '200px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'baseline',
          'margin-bottom': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightblue',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightgreen',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightgreen',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`second`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'pink',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
              'margin-top': '5px',
            },
          },
          [createText(`third`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'yellow',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`fourth`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`fourth`),
          ]
        ),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '200px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'baseline',
          'margin-bottom': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightblue',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
            createElement('br', {
              style: {
                'background-color': 'lightgreen',
                'box-sizing': 'border-box',
              },
            }),
            createText(`first`),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightgreen',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`second`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'pink',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`third`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'yellow',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
              'margin-bottom': '5px',
            },
          },
          [
            createText(`fourth`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`fourth`),
          ]
        ),
      ]
    );
    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          width: '300px',
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'baseline',
          'margin-bottom': '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightblue',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
              'align-self': 'flex-start',
              height: '100px',
            },
          },
          [createText(`first`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'lightgreen',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [createText(`second`)]
        ),
        createElement(
          'div',
          {
            style: {
              border: '0',
              'background-color': 'pink',
              'box-sizing': 'border-box',
              flex: '1 0 100px',
            },
          },
          [
            createText(`third`),
            createElement('br', {
              style: {
                'background-color': 'lightblue',
                'box-sizing': 'border-box',
              },
            }),
            createText(`third`),
          ]
        ),
      ]
    );
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);

    await matchViewportSnapshot();
  });
});
