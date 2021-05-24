/*auto generated*/
describe('relayout-align', () => {
  it('items', async (done) => {
    let log;
    let alignSelfAuto;
    let alignSelfAuto_1;
    let alignSelfFlexStart;
    let alignSelfFlexStart_1;
    let alignSelfFlexEnd;
    let alignSelfFlexEnd_1;
    let alignSelfCenter;
    let alignSelfCenter_1;
    let alignSelfBaseline;
    let alignSelfBaseline_1;
    let alignSelfStretch;
    let alignSelfStretch_1;
    let fromStretch;
    let toStretch;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    fromStretch = createElement(
      'div',
      {
        id: 'from-stretch',
        class: 'flexbox',
        style: {
          display: 'flex',
          height: '100px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '90',
          style: {
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        }),
        (alignSelfAuto = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '90',
          class: 'align-self-auto',
          style: {
            '-webkit-align-self': 'auto',
            'align-self': 'auto',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfFlexStart = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '0',
          class: 'align-self-flex-start',
          style: {
            '-webkit-align-self': 'flex-start',
            'align-self': 'flex-start',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfFlexEnd = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '90',
          class: 'align-self-flex-end',
          style: {
            '-webkit-align-self': 'flex-end',
            'align-self': 'flex-end',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfCenter = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '45',
          class: 'align-self-center',
          style: {
            '-webkit-align-self': 'center',
            'align-self': 'center',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfBaseline = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '0',
          class: 'align-self-baseline',
          style: {
            '-webkit-align-self': 'baseline',
            'align-self': 'baseline',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfStretch = createElement('div', {
          'data-expected-height': '100',
          'data-offset-y': '0',
          class: 'align-self-stretch',
          style: {
            '-webkit-align-self': 'stretch',
            'align-self': 'stretch',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    toStretch = createElement(
      'div',
      {
        id: 'to-stretch',
        class: 'flexbox align-items-flex-start',
        style: {
          display: 'flex',
          '-webkit-align-items': 'flex-start',
          height: '100px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '100',
          'data-offset-y': '0',
          style: {
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        }),
        (alignSelfAuto_1 = createElement('div', {
          'data-expected-height': '100',
          'data-offset-y': '0',
          class: 'align-self-auto',
          style: {
            '-webkit-align-self': 'auto',
            'align-self': 'auto',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfFlexStart_1 = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '0',
          class: 'align-self-flex-start',
          style: {
            '-webkit-align-self': 'flex-start',
            'align-self': 'flex-start',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfFlexEnd_1 = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '90',
          class: 'align-self-flex-end',
          style: {
            '-webkit-align-self': 'flex-end',
            'align-self': 'flex-end',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfCenter_1 = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '45',
          class: 'align-self-center',
          style: {
            '-webkit-align-self': 'center',
            'align-self': 'center',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfBaseline_1 = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '0',
          class: 'align-self-baseline',
          style: {
            '-webkit-align-self': 'baseline',
            'align-self': 'baseline',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfStretch_1 = createElement('div', {
          'data-expected-height': '100',
          'data-offset-y': '0',
          class: 'align-self-stretch',
          style: {
            '-webkit-align-self': 'stretch',
            'align-self': 'stretch',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(fromStretch);
    BODY.appendChild(toStretch);

    await snapshot();

    requestAnimationFrame(async () => {
      fromStretch.style.alignItems = 'flex-end';
      toStretch.style.alignItems = 'stretch';
      await snapshot(0.1);
      done();
    }); 
  });
});
