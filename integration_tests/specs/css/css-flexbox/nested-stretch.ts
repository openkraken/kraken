/*auto generated*/
describe('nested', () => {
  it('stretch', async () => {
    let log;
    let flex;
    let flex_1;
    let flex_2;
    let flex_3;
    let flex_4;
    let column;
    let column_1;
    let column_2;
    let flexbox;
    let flexbox_1;
    log = createElement('div', {
      id: 'log',
      style: {
        border: '1px solid black',
        background: 'hsla(210,100%,90%, .8)',
        padding: '5px',
        margin: '5px',
        'box-sizing': 'border-box',
      },
    });
    flexbox = createElement(
      'div',
      {
        class: 'flexbox row',
        style: {
          border: '1px solid black',
          background: 'hsla(210,100%,90%, .8)',
          padding: '5px',
          margin: '5px',
          display: 'flex',
          'flex-direction': 'row',
          'box-sizing': 'border-box',
          width: '600px',
        },
      },
      [
        (column = createElement(
          'div',
          {
            'data-expected-width': '290',
            'data-expected-height': '220',
            class: 'column flex',
            style: {
              border: '1px solid black',
              background: 'hsla(210,100%,90%, .8)',
              padding: '5px',
              margin: '5px',
              display: 'flex',
              'flex-direction': 'column',
              flex: '1 0 auto',
              'box-sizing': 'border-box',
            },
          },
          [
            (flex = createElement('div', {
              'data-expected-width': '270',
              'data-expected-height': '95',
              class: 'flex',
              style: {
                border: '1px solid black',
                background: 'hsla(210,100%,90%, .8)',
                padding: '5px',
                margin: '5px',
                flex: '1 0 auto',
                'box-sizing': 'border-box',
              },
            })),
            (flex_1 = createElement('div', {
              'data-expected-width': '270',
              'data-expected-height': '95',
              class: 'flex',
              style: {
                border: '1px solid black',
                background: 'hsla(210,100%,90%, .8)',
                padding: '5px',
                margin: '5px',
                flex: '1 0 auto',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        (column_1 = createElement(
          'div',
          {
            'data-expected-width': '290',
            'data-expected-height': '220',
            class: 'column flex',
            style: {
              border: '1px solid black',
              background: 'hsla(210,100%,90%, .8)',
              padding: '5px',
              margin: '5px',
              display: 'flex',
              'flex-direction': 'column',
              flex: '1 0 auto',
              'box-sizing': 'border-box',
            },
          },
          [
            (flex_2 = createElement('div', {
              'data-expected-width': '270',
              'data-expected-height': '60',
              class: 'flex',
              style: {
                border: '1px solid black',
                background: 'hsla(210,100%,90%, .8)',
                padding: '5px',
                margin: '5px',
                flex: '1 0 auto',
                'box-sizing': 'border-box',
                height: '50px',
              },
            })),
            (flex_3 = createElement('div', {
              'data-expected-width': '270',
              'data-expected-height': '60',
              class: 'flex',
              style: {
                border: '1px solid black',
                background: 'hsla(210,100%,90%, .8)',
                padding: '5px',
                margin: '5px',
                flex: '1 0 auto',
                'box-sizing': 'border-box',
                height: '50px',
              },
            })),
            (flex_4 = createElement('div', {
              'data-expected-width': '270',
              'data-expected-height': '60',
              class: 'flex',
              style: {
                border: '1px solid black',
                background: 'hsla(210,100%,90%, .8)',
                padding: '5px',
                margin: '5px',
                flex: '1 0 auto',
                'box-sizing': 'border-box',
                height: '50px',
              },
            })),
          ]
        )),
      ]
    );
    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          border: '1px solid black',
          background: 'hsla(210,100%,90%, .8)',
          padding: '5px',
          margin: '5px',
          display: 'flex',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
          width: '600px',
          height: '300px',
          position: 'relative',
        },
      },
      [
        (column_2 = createElement(
          'div',
          {
            'data-expected-width': '590',
            'data-expected-height': '250',
            class: 'column flex',
            style: {
              border: '1px solid black',
              background: 'hsla(210,100%,90%, .8)',
              padding: '5px',
              margin: '5px',
              display: 'flex',
              'flex-direction': 'column',
              flex: '1 0 auto',
              'box-sizing': 'border-box',
              'justify-content': 'flex-end',
            },
          },
          [
            createElement('div', {
              'data-offset-y': '180',
              'data-expected-width': '570',
              'data-expected-height': '30',
              style: {
                border: '1px solid black',
                background: 'hsla(210,100%,90%, .8)',
                padding: '5px',
                margin: '5px',
                'box-sizing': 'border-box',
                height: '20px',
                flex: 'none',
              },
            }),
            createElement('div', {
              'data-offset-y': '220',
              'data-expected-width': '570',
              'data-expected-height': '30',
              style: {
                border: '1px solid black',
                background: 'hsla(210,100%,90%, .8)',
                padding: '5px',
                margin: '5px',
                'box-sizing': 'border-box',
                height: '20px',
                flex: 'none',
              },
            }),
          ]
        )),
        createElement('div', {
          'data-expected-width': '590',
          'data-expected-height': '30',
          style: {
            border: '1px solid black',
            background: 'hsla(210,100%,90%, .8)',
            padding: '5px',
            margin: '5px',
            'box-sizing': 'border-box',
            height: '20px',
            flex: 'none',
          },
        }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);

    await matchViewportSnapshot();
  });
});
