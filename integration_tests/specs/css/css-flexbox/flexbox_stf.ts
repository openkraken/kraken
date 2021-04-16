/*auto generated*/
describe('flexbox_stf', () => {
  it('abspos', async () => {
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: 'red',
          position: 'absolute',
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
  it('fixpos', async () => {
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: 'red',
          position: 'fixed',
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
