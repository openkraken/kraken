/*auto generated*/
describe('flex-aspect', () => {
  it('ratio-img-column-001', async () => {
    let p;
    let referenceOverlappedRed;
    let testFlexItemOverlappingGreen;
    let constrainedFlex;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createText(`.`),
      ]
    );
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        'background-color': 'red',
        width: '100px',
        height: '100px',
        'z-index': '-1',
        'box-sizing': 'border-box',
      },
    });
    constrainedFlex = createElement(
      'div',
      {
        id: 'constrained-flex',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          height: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (testFlexItemOverlappingGreen = createElement('img', {
          id: 'test-flex-item-overlapping-green',
          src: 'assets/100x100-green.png',
          style: {
            'min-width': '0',
            'min-height': '0',
            flex: 'none',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(constrainedFlex);

    await matchScreenshot();
  });
});
