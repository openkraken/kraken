/*auto generated*/
describe('flexbox_flex', () => {
  it('auto', async () => {
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
          width: '320px',
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
              flex: 'auto',
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
              flex: 'auto',
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
              flex: 'auto',
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
              flex: 'auto',
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
          width: '320px',
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
              flex: '1 1 auto',
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
              flex: '1 1 auto',
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
              flex: '1 1 auto',
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
              flex: '1 1 auto',
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
  xit('basis', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '80px',
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
              'flex-grow': '1',
              'flex-shrink': '0',
              'flex-basis': '100%',
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
              'flex-grow': '1',
              'flex-shrink': '0',
              'flex-basis': '100%',
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
              'flex-grow': '1',
              'flex-shrink': '0',
              'flex-basis': '100%',
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
              'flex-grow': '1',
              'flex-shrink': '0',
              'flex-basis': '100%',
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

  // @TODO: Impl setting longest words width as the minimum size of text.
  // https://github.com/openkraken/kraken/issues/401
  xit('initial', async () => {
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
          width: '220px',
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
          width: '220px',
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
  xit('natural', async () => {
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
          width: '800px',
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
              flex: '2',
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
              flex: '2',
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
              flex: '2',
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
              flex: '2',
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
          width: '800px',
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
              flex: '666 1 0%',
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
              flex: '666 1 0%',
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
              flex: '666 1 0%',
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
              flex: '666 1 0%',
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
  it('none', async () => {
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
          width: '320px',
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
              flex: 'none',
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
              flex: 'none',
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
              flex: 'none',
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
              flex: 'none',
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
          width: '320px',
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
              flex: '0 0 auto',
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
              flex: '0 0 auto',
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
              flex: '0 0 auto',
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
              flex: '0 0 auto',
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
});
