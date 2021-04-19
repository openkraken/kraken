/*auto generated*/
describe('flexbox_stf-inline', () => {
  it('block', async () => {
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: 'red',
          display: 'inline-block',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'white',
              width: '300px',
              display: 'flex',
              'flex-wrap': 'wrap',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'p',
              {
                style: {
                  color: 'white',
                  margin: '10px',
                  width: '200px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`filler`)]
            ),
            createElement(
              'p',
              {
                style: {
                  color: 'white',
                  margin: '10px',
                  width: '200px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`filler`)]
            ),
            createElement(
              'p',
              {
                style: {
                  color: 'white',
                  margin: '10px',
                  width: '200px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`filler`)]
            ),
            createElement(
              'p',
              {
                style: {
                  color: 'white',
                  margin: '10px',
                  width: '200px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`filler`)]
            ),
            createElement(
              'p',
              {
                style: {
                  color: 'white',
                  margin: '10px',
                  width: '200px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`filler`)]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });
});
