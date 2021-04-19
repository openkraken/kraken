/*auto generated*/
describe('flexbox_order-box', () => {
  it('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px',
          border: '1px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'yellow',
              margin: '10px',
              border: '1px solid black',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  background: 'white',
                  margin: '10px',
                  width: '80px',
                  height: '12px',
                  display: 'inline-block',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`three`)]
            ),
            createElement(
              'span',
              {
                style: {
                  background: 'white',
                  margin: '10px',
                  width: '80px',
                  height: '12px',
                  display: 'inline-block',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`four`)]
            ),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              background: 'yellow',
              margin: '10px',
              border: '1px solid black',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  background: 'white',
                  margin: '10px',
                  width: '80px',
                  height: '12px',
                  display: 'inline-block',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`one`)]
            ),
            createElement(
              'span',
              {
                style: {
                  background: 'white',
                  margin: '10px',
                  width: '80px',
                  height: '12px',
                  display: 'inline-block',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`two`)]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
