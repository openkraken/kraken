/*auto generated*/
describe('flex-aspect', () => {
  it('ratio-img-column-001', async () => {
    let referenceOverlappedRed;
    let testFlexItemOverlappingGreen;
    let constrainedFlex;
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
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(constrainedFlex);

    await snapshot();
  });
  it('ratio-img-column-002', async () => {
    let referenceOverlappedRed;
    let testFlexItemOverlappingGreen;
    let constrainedFlex;
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        'background-color': 'red',
        width: '100px',
        height: '100px',
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
          src: 'assets/300x150-green.png',
          style: {
            'min-width': '0',
            'min-height': '0',
            height: '100px',
            'align-self': 'flex-start',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(constrainedFlex);

    await sleep(0.1);
    await snapshot();
  });
  it('ratio-img-column-003', async () => {
    let testFlexItemOverlappingGreen;
    let constrainedFlex;
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
            'align-self': 'flex-start',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(constrainedFlex);
    await sleep(0.5);
    await snapshot();
  });
  it('ratio-img-column-004', async () => {
    let flex;
    flex = createElement(
      'div',
      {
        class: 'flex',
        style: {
          display: 'flex',
          width: '100px',
          'min-height': '500px',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            'max-width': '100px',
            height: '50px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            width: '100px',
            height: '50px',
            background: 'green',
          },
        }),
      ]
    );
    BODY.appendChild(flex);
    await sleep(0.1);
    await snapshot();
  });
  it('ratio-img-column-005', async () => {
    let flex;
    flex = createElement(
      'div',
      {
        class: 'flex',
        style: {
          display: 'flex',
          width: '100px',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            'max-width': '100px',
            width: '500px',
            'min-height': '0',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(flex);
    await sleep(0.1);
    await snapshot();
  });
  xit('ratio-img-column-008', async () => {
    let referenceOverlappedRed;
    let div;
    let flex;
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
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        width: '60px',
        height: '100px',
        background: 'green',
        float: 'left',
      },
    });
    flex = createElement(
      'div',
      {
        class: 'flex',
        style: {
          display: 'flex',
          'justify-content': 'flex-start',
          'align-items': 'flex-start',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: 'assets/20x50-green.png',
          style: {
            'padding-left': '5%',
            'min-width': '40px',
            'min-height': '0',
            'margin-left': '-10px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(div);
    BODY.appendChild(flex);
    await sleep(0.1);
    await snapshot();
  });
  it('ratio-img-row-001', async () => {
    let referenceOverlappedRed;
    let testFlexItemOverlappingGreen;
    let constrainedFlex;
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        width: '100px',
        height: '100px',
        'box-sizing': 'border-box',
      },
    });
    constrainedFlex = createElement(
      'div',
      {
        id: 'constrained-flex',
        style: {
          display: 'flex',
          width: '10px',
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
            height: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(constrainedFlex);
    await sleep(0.1);
    await snapshot();
  });
  xit('ratio-img-row-002', async () => {
    let referenceOverlappedRed;
    let testFlexItemOverlappingGreen;
    let constrainedFlex;
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        width: '100px',
        height: '100px',
        'box-sizing': 'border-box',
      },
    });
    constrainedFlex = createElement(
      'div',
      {
        id: 'constrained-flex',
        style: {
          display: 'flex',
          width: '10px',
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
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(constrainedFlex);
    await sleep(0.1);
    await snapshot();
  });
  it('ratio-img-row-003', async () => {
    let referenceOverlappedRed;
    let testFlexItemOverlappingGreen;
    let constrainedFlex;
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        width: '100px',
        height: '100px',
        'box-sizing': 'border-box',
      },
    });
    constrainedFlex = createElement(
      'div',
      {
        id: 'constrained-flex',
        style: {
          display: 'flex',
          width: '10px',
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
            'flex-basis': '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(constrainedFlex);
    await sleep(0.1);
    await snapshot();
  });
});
