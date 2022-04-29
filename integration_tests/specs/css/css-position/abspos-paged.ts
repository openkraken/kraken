/*auto generated*/
describe('abspos-paged', () => {
  it('001', async () => {
    let p;
    let div;
    let div_1;
    let div_2;
    let div_3;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Display this in a paged media. The word PASS should display below
  (followed by three mostly-blank pages).`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'page-break-after': 'always',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '20px',
              left: '10px',
              font: '60px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`P`)]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'page-break-after': 'always',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '20px',
              left: '10px',
              font: '60px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(` A`)]
        ),
        createText(`Blank Page 1`),
      ]
    );
    div_2 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'page-break-after': 'always',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '20px',
              left: '10px',
              font: '60px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`  S`)]
        ),
        createText(`Blank Page 2`),
      ]
    );
    div_3 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'page-break-after': 'always',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '20px',
              left: '10px',
              font: '60px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`   S`)]
        ),
        createText(`Blank Page 3`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(div_2);
    BODY.appendChild(div_3);

    await snapshot();
  });
  it('002', async () => {
    let div;
    let div_1;
    let div_2;
    let div_3;
    let div_4;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          height: '100%',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'p',
          {
            style: {
              margin: '0',
              padding: '10px',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`Test passes if each of its five pages has the page number printed
    in the middle of the page, with no overlap.`),
          ]
        ),
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '50%',
              'margin-top': '-5px',
              left: '0',
              right: '0',
              'text-align': 'center',
              font: '20px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Page one`)]
        ),
      ]
    );
    div_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          height: '100%',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '50%',
              'margin-top': '-5px',
              left: '0',
              right: '0',
              'text-align': 'center',
              font: '20px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Page two`)]
        ),
      ]
    );
    div_2 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          height: '100%',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '50%',
              'margin-top': '-5px',
              left: '0',
              right: '0',
              'text-align': 'center',
              font: '20px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Page three`)]
        ),
      ]
    );
    div_3 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          height: '100%',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '50%',
              'margin-top': '-5px',
              left: '0',
              right: '0',
              'text-align': 'center',
              font: '20px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Page four`)]
        ),
      ]
    );
    div_4 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          height: '100%',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'h1',
          {
            style: {
              position: 'absolute',
              top: '50%',
              'margin-top': '-5px',
              left: '0',
              right: '0',
              'text-align': 'center',
              font: '20px monospace',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Page five`)]
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(div_2);
    BODY.appendChild(div_3);
    BODY.appendChild(div_4);

    await snapshot();
  });
});
