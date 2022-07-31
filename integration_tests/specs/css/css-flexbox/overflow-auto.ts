/*auto generated*/
describe('overflow-auto', () => {
  it('intrinsic-size', async () => {
    let log;
    let overflow;
    let overflow_1;
    let overflow_2;
    let overflow_3;
    let inlineFlexbox;
    let inlineFlexbox_1;
    let inlineFlexbox_2;
    let inlineFlexbox_3;
    let measure;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    inlineFlexbox = createElement(
      'div',
      {
        class: 'inline-flexbox column to-be-checked',
        'check-width': '',
        'check-accounts-scrollbar': '',
        style: {
          display: 'inline-flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          border: '5px solid green',
          position: 'relative',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (overflow = createElement(
          'div',
          {
            class: 'overflow',
            style: {
              border: '1px solid red',
              overflow: 'auto',
              'min-width': '0',
              'min-height': '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '20px',
                height: '100px',
              },
            }),
          ]
        )),
      ]
    );
    inlineFlexbox_1 = createElement(
      'div',
      {
        class: 'inline-flexbox column-reverse to-be-checked',
        'check-width': '',
        'check-accounts-scrollbar': '',
        style: {
          display: 'inline-flex',
          '-webkit-flex-direction': 'column-reverse',
          'flex-direction': 'column-reverse',
          border: '5px solid green',
          position: 'relative',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (overflow_1 = createElement(
          'div',
          {
            class: 'overflow',
            style: {
              border: '1px solid red',
              overflow: 'auto',
              'min-width': '0',
              'min-height': '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '20px',
                height: '100px',
              },
            }),
          ]
        )),
      ]
    );
    inlineFlexbox_2 = createElement(
      'div',
      {
        class: 'inline-flexbox column to-be-checked',
        'check-width': '',
        'check-accounts-scrollbar': '',
        style: {
          display: 'inline-flex',
          '-webkit-flex-direction': 'column',
          'flex-direction': 'column',
          border: '5px solid green',
          position: 'relative',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (overflow_2 = createElement(
          'div',
          {
            class: 'overflow align-self-baseline',
            style: {
              '-webkit-align-self': 'baseline',
              'align-self': 'baseline',
              border: '1px solid red',
              overflow: 'auto',
              'min-width': '0',
              'min-height': '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '20px',
                height: '100px',
              },
            }),
          ]
        )),
      ]
    );
    inlineFlexbox_3 = createElement(
      'div',
      {
        class: 'inline-flexbox column-reverse to-be-checked',
        'check-width': '',
        'check-accounts-scrollbar': '',
        style: {
          display: 'inline-flex',
          '-webkit-flex-direction': 'column-reverse',
          'flex-direction': 'column-reverse',
          border: '5px solid green',
          position: 'relative',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [
        (overflow_3 = createElement(
          'div',
          {
            class: 'overflow align-self-baseline',
            style: {
              '-webkit-align-self': 'baseline',
              'align-self': 'baseline',
              border: '1px solid red',
              overflow: 'auto',
              'min-width': '0',
              'min-height': '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '20px',
                height: '100px',
              },
            }),
          ]
        )),
      ]
    );
    measure = createElement(
      'div',
      {
        id: 'measure',
        style: {
          'box-sizing': 'border-box',
          height: '100px',
          width: '100px',
          display: 'inline-block',
          overflow: 'auto',
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            'min-height': '300px',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(inlineFlexbox);
    BODY.appendChild(inlineFlexbox_1);
    BODY.appendChild(inlineFlexbox_2);
    BODY.appendChild(inlineFlexbox_3);
    BODY.appendChild(measure);

    await matchViewportSnapshot();
  });
  it('resizes-correctly', async () => {
    let rect;
    let vbox;
    let hflex;
    let inner;
    let div;
    let measure;
    hflex = createElement(
      'div',
      {
        class: 'hflex',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          'max-height': '200px',
          margin: '10px 0 10px 0',
          'box-sizing': 'border-box',
        },
      },
      [
        (vbox = createElement(
          'div',
          {
            class: 'vbox',
            style: {
              'overflow-y': 'auto',
              'max-height': '200px',
              'box-sizing': 'border-box',
            },
          },
          [
            (rect = createElement('div', {
              class: 'rect',
              style: {
                'min-height': '300px',
                'min-width': '100px',
                'background-color': 'green',
                display: 'inline-block',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          width: '100px',
          height: '100px',
        },
      },
      [
        (inner = createElement(
          'div',
          {
            id: 'inner',
            style: {
              'box-sizing': 'border-box',
              flex: 'none',
              height: '100px',
              overflow: 'auto',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '100px',
                height: '150px',
                'background-color': 'green',
              },
            }),
          ]
        )),
      ]
    );
    measure = createElement(
      'div',
      {
        id: 'measure',
        style: {
          'box-sizing': 'border-box',
          height: '100px',
          width: '100px',
          display: 'inline-box',
          overflow: 'auto',
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            'min-height': '300px',
          },
        }),
      ]
    );
    BODY.appendChild(hflex);
    BODY.appendChild(div);
    BODY.appendChild(measure);

    await matchViewportSnapshot();
  });
});
