/*auto generated*/
describe('flexbox_direction-column', () => {
  it("default", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          display: 'flex',
          'flex-direction': 'column',
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
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '80px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '80px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '80px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
      ]
    );
    BODY.appendChild(div);


    await snapshot();
  })
  it('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
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
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '20px 10px 10px',
              width: '80px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '20px 10px 10px',
              width: '80px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '20px 10px 10px',
              width: '80px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('reverse-ref', async () => {
    let test;
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
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
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '20px 10px 10px',
              width: '80px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '20px 10px 10px',
              width: '80px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              background: '#ffcc00',
              margin: '20px 10px 10px',
              width: '80px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        )),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('reverse', async () => {
    let test;
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          display: 'flex',
          'flex-direction': 'column-reverse',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              background: '#ffcc00',
              margin: '10px',
              width: '80px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        )),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '80px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '80px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              width: '80px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
