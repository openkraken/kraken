/*auto generated*/
describe('text-overflow', () => {
  it('ellipsis-001', async () => {
    let p;
    let div;
    let div_1;
    let div_2;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The test passes if it matches the reference.`)]
    );
    div = createElement(
      'div',
      {
        style: {
          'font-size': '100px',
          width: '400px',
          'white-space': 'pre',
          overflow: 'hidden',
          'text-overflow': 'ellipsis',
          'box-sizing': 'border-box',
        },
      },
      [createText(`ppp`)]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'font-size': '100px',
          width: '400px',
          'white-space': 'pre',
          overflow: 'hidden',
          'text-overflow': 'ellipsis',
          'box-sizing': 'border-box',
        },
      },
      [createText(`pppp`)]
    );
    div_2 = createElement(
      'div',
      {
        style: {
          'font-size': '100px',
          width: '400px',
          'white-space': 'pre',
          overflow: 'hidden',
          'text-overflow': 'ellipsis',
          'box-sizing': 'border-box',
        },
      },
      [createText(`ppppp`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(div_2);

    await snapshot();
  });
  it('ellipsis-002', async () => {
    let element;
    let parent;
    parent = createElement(
      'div',
      {
        id: 'parent',
        style: {
          'background-color': 'green',
          display: 'inline-block',
          'vertical-align': 'top',
          'box-sizing': 'border-box',
        },
      },
      [
        (element = createElement(
          'div',
          {
            id: 'element',
            style: {
              'text-overflow': 'ellipsis',
              'white-space': 'nowrap',
              'max-width': '40px',
              overflow: 'hidden',
              'box-sizing': 'border-box',
            },
          },
          [createText(`ABCABCABCABC`)]
        )),
      ]
    );
    BODY.appendChild(parent);

    await snapshot();
  });
  it('ellipsis-editing-input-ref', async () => {
    let p;
    let inputElement;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`You should not see an ellipsis for the text below.`)]
    );
    inputElement = createElement('input', {
      id: 'input_element',
      style: {
        all: 'initial',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(inputElement);
    inputElement.setAttribute('value', 'xxxxxxxxxxxxxxxx');

    await snapshot();
  });
  
  // @TODO not impl yet
  xit('ellipsis-editing-input', async () => {
    let p;
    let inputElement;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`You should see an ellipsis for the text below.`)]
    );
    inputElement = createElement('input', {
      id: 'input_element',
      style: {
        width: '100px',
        'text-overflow': 'ellipsis',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(inputElement);
    inputElement.setAttribute('value', 'xxxxxxxxxxxxxxxx');

    await snapshot();
  });
});
