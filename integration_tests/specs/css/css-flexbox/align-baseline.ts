/*auto generated*/
describe('align-baseline', () => {
  it("001", async () => {
    let flexbox;
    let flexbox_1;
    flexbox = createElement(
      'div',
      {
        class: 'flexbox column align-items-baseline',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'align-items': 'baseline',
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
          [createText(`This text`)]
        ),
        createElement(
          'p',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`should be left aligned.`)]
        ),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column align-items-baseline wrap-reverse',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'baseline',
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
          [createText(`This text`)]
        ),
        createElement(
          'p',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`should be right aligned.`)]
        ),
      ]
    );
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);


    await snapshot();
  });

  it('ref', async () => {
    let flexbox;
    let flexbox_1;
    flexbox = createElement(
      'div',
      {
        class: 'flexbox column align-items-flex-start',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'align-items': 'flex-start',
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
          [createText(`This text`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`should be left aligned.`)]
        ),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column align-items-flex-start wrap-reverse',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap-reverse',
          'align-items': 'flex-start',
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
          [createText(`This text`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`should be right aligned.`)]
        ),
      ]
    );
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);

    await snapshot();
  });
});
