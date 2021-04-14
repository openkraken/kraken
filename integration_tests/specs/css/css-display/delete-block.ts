/*auto generated*/
describe('delete-block', () => {
  it('in-inlines-beginning-001-ref', async () => {
    let p;
    let container;
    let container_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the 2 colorized rectangles are `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`identical`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          'background-color': 'fuchsia',
          color: 'black',
          font: '20px/1 Ahem',
          margin: '10px',
        },
      },
      [createText(`Several inline elements are in this sentence.`)]
    );
    container_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          'background-color': 'fuchsia',
          color: 'black',
          font: '20px/1 Ahem',
          margin: '10px',
        },
      },
      [createText(`Several inline elements are in this sentence.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(container_1);

    await snapshot();
  });
  it('in-inlines-beginning-001', async () => {
    let p;
    let container;
    let container_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if the 2 colorized rectangles are `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`identical`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          'background-color': 'fuchsia',
          color: 'black',
          font: '20px/1 Ahem',
          margin: '10px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {},
          },
          [createText(`Several`)]
        ),
        createElement(
          'span',
          {
            style: {},
          },
          [createText(`inline elements`)]
        ),
        createText(` are `),
        createElement(
          'span',
          {
            style: {},
          },
          [createText(`in this`)]
        ),
        createText(` sentence.`),
      ]
    );
    container_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          'background-color': 'fuchsia',
          color: 'black',
          font: '20px/1 Ahem',
          margin: '10px',
        },
      },
      [createText(`Several inline elements are in this sentence.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(container_1);

    await snapshot();
  });
});
