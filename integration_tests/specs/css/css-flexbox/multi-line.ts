/*auto generated*/
describe('multi-line', () => {
  it('wrap-reverse-column-reverse', async () => {
    let col3Row1;
    let col2Row2;
    let col2Row1;
    let col1Row3;
    let col1Row2;
    let col1Row1;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          margin: '0',
          padding: '0',
          'line-height': '1',
          display: 'flex',
          'flex-direction': 'column-reverse',
          'flex-wrap': 'wrap-reverse',
          height: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (col3Row1 = createElement(
          'p',
          {
            id: 'col3-row1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '290px',
              color: 'cyan',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3-1`)]
        )),
        (col2Row2 = createElement(
          'p',
          {
            id: 'col2-row2',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '140px',
              color: 'magenta',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-2`)]
        )),
        (col2Row1 = createElement(
          'p',
          {
            id: 'col2-row1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '140px',
              color: 'yellow',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-1`)]
        )),
        (col1Row3 = createElement(
          'p',
          {
            id: 'col1-row3',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '90px',
              color: 'blue',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-3`)]
        )),
        (col1Row2 = createElement(
          'p',
          {
            id: 'col1-row2',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '90px',
              color: 'green',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-2`)]
        )),
        (col1Row1 = createElement(
          'p',
          {
            id: 'col1-row1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '90px',
              color: 'orange',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-1`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });
  it('wrap-reverse-row-reverse', async () => {
    let row3Col1;
    let row2Col2;
    let row2Col1;
    let row1Col3;
    let row1Col2;
    let row1Col1;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          margin: '0',
          padding: '0',
          'line-height': '1',
          display: 'flex',
          'flex-direction': 'row-reverse',
          'flex-wrap': 'wrap-reverse',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (row3Col1 = createElement(
          'p',
          {
            id: 'row3-col1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              width: '290px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3-1`)]
        )),
        (row2Col2 = createElement(
          'p',
          {
            id: 'row2-col2',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              width: '140px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-2`)]
        )),
        (row2Col1 = createElement(
          'p',
          {
            id: 'row2-col1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              width: '140px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-1`)]
        )),
        (row1Col3 = createElement(
          'p',
          {
            id: 'row1-col3',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              width: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-3`)]
        )),
        (row1Col2 = createElement(
          'p',
          {
            id: 'row1-col2',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              width: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-2`)]
        )),
        (row1Col1 = createElement(
          'p',
          {
            id: 'row1-col1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              width: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-1`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });
  it('wrap-with-column-reverse', async () => {
    let col1Row3;
    let col1Row2;
    let col1Row1;
    let col2Row2;
    let col2Row1;
    let col3Row1;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          margin: '0',
          padding: '0',
          'line-height': '1',
          display: 'flex',
          'flex-direction': 'column-reverse',
          'flex-wrap': 'wrap',
          height: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (col1Row3 = createElement(
          'p',
          {
            id: 'col1-row3',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-3`)]
        )),
        (col1Row2 = createElement(
          'p',
          {
            id: 'col1-row2',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-2`)]
        )),
        (col1Row1 = createElement(
          'p',
          {
            id: 'col1-row1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-1`)]
        )),
        (col2Row2 = createElement(
          'p',
          {
            id: 'col2-row2',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '140px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-2`)]
        )),
        (col2Row1 = createElement(
          'p',
          {
            id: 'col2-row1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '140px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-1`)]
        )),
        (col3Row1 = createElement(
          'p',
          {
            id: 'col3-row1',
            style: {
              margin: '0',
              padding: '0',
              'line-height': '1',
              'margin-top': '10px',
              'margin-right': '10px',
              background: '#ccc',
              height: '290px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3-1`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });
  it('wrap-with-row-reverse', async () => {
    let row1Col3;
    let row1Col2;
    let row1Col1;
    let row2Col2;
    let row2Col1;
    let row3Col1;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          display: 'flex',
          'flex-direction': 'row-reverse',
          'flex-wrap': 'wrap',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (row1Col3 = createElement(
          'p',
          {
            id: 'row1-col3',
            style: {
              'margin-right': '10px',
              'margin-top': '10px',
              'margin-bottom': '10px',
              background: '#ccc',
              width: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-3`)]
        )),
        (row1Col2 = createElement(
          'p',
          {
            id: 'row1-col2',
            style: {
              'margin-right': '10px',
              'margin-top': '10px',
              'margin-bottom': '10px',
              background: '#ccc',
              width: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-2`)]
        )),
        (row1Col1 = createElement(
          'p',
          {
            id: 'row1-col1',
            style: {
              'margin-right': '10px',
              'margin-top': '10px',
              'margin-bottom': '10px',
              background: '#ccc',
              width: '90px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1-1`)]
        )),
        (row2Col2 = createElement(
          'p',
          {
            id: 'row2-col2',
            style: {
              'margin-right': '10px',
              'margin-top': '10px',
              'margin-bottom': '10px',
              background: '#ccc',
              width: '140px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-2`)]
        )),
        (row2Col1 = createElement(
          'p',
          {
            id: 'row2-col1',
            style: {
              'margin-right': '10px',
              'margin-top': '10px',
              'margin-bottom': '10px',
              background: '#ccc',
              width: '140px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2-1`)]
        )),
        (row3Col1 = createElement(
          'p',
          {
            id: 'row3-col1',
            style: {
              'margin-right': '10px',
              'margin-top': '10px',
              'margin-bottom': '10px',
              background: '#ccc',
              width: '290px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3-1`)]
        )),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });
});
