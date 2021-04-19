/*auto generated*/
describe('flexbox_flex-basis', () => {
  xit('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'white-space': 'nowrap',
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px 0',
              width: '80px',
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
              background: 'pink',
              margin: '10px 0',
              width: '80px',
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
              background: 'lightblue',
              margin: '10px 0',
              width: '80px',
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
              background: 'grey',
              margin: '10px 0',
              width: '80px',
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

    await snapshot();
  });
  it('shrink-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          width: '240px',
          height: '80px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px 0',
              width: '60px',
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
              background: 'pink',
              margin: '10px 0',
              width: '60px',
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
              background: 'lightblue',
              margin: '10px 0',
              width: '60px',
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
              background: 'grey',
              margin: '10px 0',
              width: '60px',
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

    await snapshot();
  });
  xit('shrink', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '240px',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px 0',
              width: '50px',
              display: 'inline-block',
              flex: '1 1 50%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              margin: '10px 0',
              width: '50px',
              display: 'inline-block',
              flex: '1 1 50%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '10px 0',
              width: '50px',
              display: 'inline-block',
              flex: '1 1 50%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'grey',
              margin: '10px 0',
              width: '50px',
              display: 'inline-block',
              flex: '1 1 50%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`four`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
