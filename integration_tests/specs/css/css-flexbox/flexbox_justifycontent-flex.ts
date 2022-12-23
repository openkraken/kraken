/*auto generated*/
describe('flexbox_justifycontent-flex', () => {
  it('end-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '300px',
          position: 'relative',
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
              'max-width': '60px',
              height: '60px',
              position: 'absolute',
              left: '70px',
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
              'max-width': '60px',
              height: '60px',
              position: 'absolute',
              left: '150px',
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
              'max-width': '60px',
              height: '60px',
              position: 'absolute',
              left: '230px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  // @TODO: Percentage of flex-basis not working.
  xit('end', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '300px',
          display: 'flex',
          'justify-content': 'flex-end',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flex: '1 0 0%',
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
              margin: '10px',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flex: '1 0 0%',
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
              margin: '10px',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flex: '1 0 0%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('start-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '300px',
          position: 'relative',
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
              'max-width': '60px',
              height: '60px',
              position: 'absolute',
              left: '20px',
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
              'max-width': '60px',
              height: '60px',
              position: 'absolute',
              left: '120px',
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
              'max-width': '60px',
              height: '60px',
              position: 'absolute',
              left: '220px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  // @TODO: Percentage of flex-basis not working.
  xit('start', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '300px',
          display: 'flex',
          'justify-content': 'flex-start',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px auto',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flex: '1 0 0%',
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
              margin: '10px auto',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flex: '1 0 0%',
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
              margin: '10px auto',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flex: '1 0 0%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
