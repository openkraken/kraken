/*auto generated*/
describe('flexbox_flex-initial', () => {
  it('2-ref', async () => {
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
          width: '400px',
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
          width: '400px',
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
  it('2', async () => {
    let div;
    let flex;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '400px',
          display: 'flex',
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
              display: 'inline-block',
              flex: 'initial',
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
              display: 'inline-block',
              flex: 'initial',
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
              display: 'inline-block',
              flex: 'initial',
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
              display: 'inline-block',
              flex: 'initial',
              'box-sizing': 'border-box',
            },
          },
          [createText(`four`)]
        ),
      ]
    );
    flex = createElement(
      'div',
      {
        id: 'flex',
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '400px',
          display: 'flex',
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
              display: 'inline-block',
              flex: '0 1 auto',
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
              display: 'inline-block',
              flex: '0 1 auto',
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
              display: 'inline-block',
              flex: '0 1 auto',
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
              display: 'inline-block',
              flex: '0 1 auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`four`)]
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(flex);

    await snapshot();
  });
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
          width: '220px',
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
              width: '35px',
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
              width: '35px',
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
              width: '35px',
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
              width: '35px',
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
          width: '220px',
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
              width: '35px',
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
              width: '35px',
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
              width: '35px',
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
              width: '35px',
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
});
