/*auto generated*/
describe('anonymous-flex', () => {
  it('item-001', async () => {
    let p;
    let spanRemove;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a space between "two" and "words" below.`)]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
        },
      },
      [
        createText(`two `),
        (spanRemove = createElement('span', {
          style: {
            'box-sizing': 'border-box',
          },
        })),
        createText(`words`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    document.body.offsetTop;

    spanRemove.remove();

    await snapshot();
  });
  it('item-002', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a space between "two" and "words" below.`)]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
        },
      },
      [
        createText(`two `),
        createElement('span', {
          style: {
            'box-sizing': 'border-box',
            display: 'none',
          },
        }),
        createText(`words`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('item-003', async () => {
    let p;
    let noneSpan;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a space between "two" and "words" below.`)]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
        },
      },
      [
        createText(`two `),
        (noneSpan = createElement('span', {
          style: {
            'box-sizing': 'border-box',
          },
        })),
        createText(`words`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    document.body.offsetTop;

    await snapshot();
  });
  it('item-004', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `The words "Two" and "lines" should not be on the same line.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
        },
      },
      [
        createText(`Two `),
        createElement('span', {
          style: {
            'box-sizing': 'border-box',
            position: 'absolute',
          },
        }),
        createText(`lines`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('item-005', async () => {
    let p;
    let absSpan;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `The words "Two" and "lines" should not be on the same line.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
        },
      },
      [
        createText(`Two `),
        (absSpan = createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
              display: 'none',
            },
          },
          [createText(`1`)]
        )),
        createText(`lines`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    absSpan.style.display = 'none';
    // document.body.offsetTop;
    // absSpan.style.position = "absolute";
    // absSpan.style.display = "inline";

    await snapshot();
  });
  it('item-006', async () => {
    let p;
    let abs;
    let abs_1;
    let spanRemove;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `The words "Two" and "lines" should not be on the same line.`
        ),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
        },
      },
      [
        createText(`Two `),
        (abs = createElement('span', {
          style: {
            position: 'absolute',
            'box-sizing': 'border-box',
          },
        })),
        (spanRemove = createElement('span', {
          style: {
            'box-sizing': 'border-box',
          },
        })),
        (abs_1 = createElement('span', {
          style: {
            position: 'absolute',
            'box-sizing': 'border-box',
          },
        })),
        createText(`lines`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    spanRemove.parentNode.removeChild(spanRemove);

    await snapshot();
  });
});
