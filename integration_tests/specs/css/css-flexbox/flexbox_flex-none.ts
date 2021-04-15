/*auto generated*/
describe('flexbox_flex-none', () => {
  it('ref', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '320px',
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
              width: '50px',
              height: '60px',
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
              width: '50px',
              height: '60px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '50px',
              height: '60px',
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
              width: '50px',
              height: '60px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`four`)]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '320px',
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
              width: '50px',
              height: '60px',
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
              width: '50px',
              height: '60px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '50px',
              height: '60px',
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
              width: '50px',
              height: '60px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`four`)]
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('wrappable-content-ref', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              color: 'green',
              'box-sizing': 'border-box',
            },
          },
          [createText(`XXX XXX XXX`)]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'margin-top': '10px',
        },
      },
      [
        createText(
          `You should see three green rectangles above, all on the same line.`
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('wrappable-content', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          width: '5px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              flex: 'none',
            },
          },
          [
            createElement(
              'span',
              {
                style: {
                  'font-family': 'NaNpx',
                  color: 'green',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`XXX XXX XXX`)]
            ),
          ]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'margin-top': '10px',
        },
      },
      [
        createText(
          `You should see three green rectangles above, all on the same line.`
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
});
