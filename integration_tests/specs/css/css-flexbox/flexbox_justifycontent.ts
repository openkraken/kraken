/*auto generated*/
describe('flexbox_justifycontent', () => {
  xit('center', async () => {
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
          'justify-content': 'center',
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
  xit('spacearound', async () => {
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
          'justify-content': 'space-around',
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
  xit('spacebetween', async () => {
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
          'justify-content': 'space-between',
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
});
