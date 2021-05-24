/*auto generated*/
describe('flexbox_flex-natural', () => {
  it('mixed-basis-auto-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'font-family': 'NaNpx',
          background: 'blue',
          height: '80px',
          width: '350px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              height: '80px',
              display: 'inline-block',
              background: 'yellow',
              width: '30px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`a`)]
        ),
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              height: '80px',
              display: 'inline-block',
              background: 'pink',
              width: '60px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaa`)]
        ),
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              height: '80px',
              display: 'inline-block',
              background: 'lightblue',
              width: '80px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaaaa`)]
        ),
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              height: '80px',
              display: 'inline-block',
              background: 'grey',
              width: '180px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaaaaaaaaaaaaaa`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  xit('mixed-basis-auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'font-family': 'NaNpx',
          background: 'blue',
          height: '80px',
          width: '350px',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              background: 'yellow',
              flex: '1 1 0%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`a`)]
        ),
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              background: 'pink',
              flex: '1 1 auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaa`)]
        ),
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              background: 'lightblue',
              flex: '1 1 auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaaaa`)]
        ),
        createElement(
          'span',
          {
            style: {
              'font-family': 'NaNpx',
              background: 'grey',
              flex: '1 1 auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`aaaaaaaaaaaaaaa`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('mixed-basis-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          height: '80px',
          width: '350px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '50px',
              height: '80px',
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
              width: '100px',
              height: '80px',
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
              width: '100px',
              height: '80px',
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
              width: '100px',
              height: '80px',
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
  xit('mixed-basis', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          height: '80px',
          width: '350px',
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
              width: '50px',
              flex: '1 1 0%',
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
              width: '50px',
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
              background: 'lightblue',
              width: '50px',
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
              background: 'grey',
              width: '50px',
              flex: '1 1 auto',
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
  xit('ref', async () => {
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
          width: '800px',
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
              width: '25%',
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
              width: '25%',
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
              width: '25%',
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
              width: '25%',
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
          width: '800px',
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
              width: '25%',
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
              width: '25%',
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
              width: '25%',
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
              width: '25%',
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
  it('variable-auto-basis', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
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
              width: '50px',
              display: 'inline-block',
              flex: '1 1 auto',
              background: 'yellow',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              width: '50px',
              display: 'inline-block',
              flex: '3 1 auto',
              background: 'pink',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              width: '50px',
              display: 'inline-block',
              flex: '1 1 auto',
              background: 'lightblue',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
        createElement(
          'span',
          {
            style: {
              width: '50px',
              display: 'inline-block',
              flex: '1 1 auto',
              background: 'grey',
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
  xit('variable-zero-basis', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          border: '1px solid black',
          height: '80px',
          width: '360px',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              width: '60px',
              display: 'block',
              flex: '1 1 0%',
              background: 'yellow',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              width: '60px',
              display: 'block',
              flex: '3 1 0%',
              background: 'pink',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              width: '60px',
              display: 'block',
              flex: '1 1 0%',
              background: 'lightblue',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
        createElement(
          'span',
          {
            style: {
              width: '60px',
              display: 'block',
              flex: '1 1 0%',
              background: 'grey',
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
