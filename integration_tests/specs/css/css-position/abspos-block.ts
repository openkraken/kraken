/*auto generated*/
describe('abspos-block', () => {
  xit('level-001-ref', async () => {
    let absolute;
    let absolute_1;
    let div;
    let div_1;
    let rtl;
    let rtl_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (absolute = createElement(
          'span',
          {
            class: 'absolute green',
            style: {
              position: 'absolute',
              'background-color': 'lime',
              padding: '0 1ch',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos before inline content`)]
        )),
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Inline content`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos after inline content`)]
        ),
      ]
    );
    rtl = createElement(
      'div',
      {
        class: 'rtl',
        style: {
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        (absolute_1 = createElement(
          'span',
          {
            class: 'absolute green',
            style: {
              position: 'absolute',
              'background-color': 'lime',
              padding: '0 1ch',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos before inline content`)]
        )),
        createElement('br', {
          style: {
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    rtl_1 = createElement(
      'div',
      {
        class: 'rtl',
        style: {
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Inline content`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos after inline content`)]
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(rtl);
    BODY.appendChild(rtl_1);

    await snapshot();
  });
  it('level-001', async () => {
    let absolute;
    let absolute_1;
    let absolute_2;
    let absolute_3;
    let red;
    let red_1;
    let div;
    let div_1;
    let rtl;
    let rtl_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (absolute = createElement(
          'div',
          {
            class: 'absolute green',
            style: {
              position: 'absolute',
              'background-color': 'lime',
              padding: '0 1ch',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos before inline content`)]
        )),
        (red = createElement(
          'span',
          {
            class: 'red',
            style: {
              color: 'red',
              padding: '0 1ch',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Inline content`)]
        )),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Inline content`)]
        ),
        (absolute_1 = createElement(
          'div',
          {
            class: 'absolute',
            style: {
              position: 'absolute',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos after inline content`)]
        )),
      ]
    );
    rtl = createElement(
      'div',
      {
        class: 'rtl',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (absolute_2 = createElement(
          'div',
          {
            class: 'absolute green',
            style: {
              position: 'absolute',
              'background-color': 'lime',
              padding: '0 1ch',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos before inline content`)]
        )),
        (red_1 = createElement(
          'span',
          {
            class: 'red',
            style: {
              color: 'red',
              padding: '0 1ch',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Inline content`)]
        )),
      ]
    );
    rtl_1 = createElement(
      'div',
      {
        class: 'rtl',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`Inline content`)]
        ),
        (absolute_3 = createElement(
          'div',
          {
            class: 'absolute',
            style: {
              position: 'absolute',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Block-level abspos after inline content`)]
        )),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(rtl);
    BODY.appendChild(rtl_1);

    await snapshot();
  });
});
