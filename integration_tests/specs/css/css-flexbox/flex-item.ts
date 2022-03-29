/*auto generated*/
describe('flex-item', () => {
  // @TODO: Need to impl stacking-context.
  xit('z-ordering-001', async () => {
    let flexItem;
    let flexItem_1;
    let flexItem_2;
    let flexItem_3;
    let positioned;
    let positioned_1;
    let positioned_2;
    let positioned_3;
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `The green boxes should be above the orange boxes, which should be above the purple boxes, which are above the salmon boxes.`
        ),
        createElement(
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
                  position: 'relative',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      display: 'flex',
                    },
                  },
                  [
                    (flexItem = createElement('div', {
                      class: 'flex-item',
                      style: {
                        width: '50px',
                        height: '50px',
                        'box-sizing': 'border-box',
                        'z-index': '1',
                        'background-color': 'salmon',
                      },
                    })),
                    (flexItem_1 = createElement('div', {
                      class: 'flex-item',
                      style: {
                        width: '50px',
                        height: '50px',
                        'box-sizing': 'border-box',
                        'z-index': '100',
                        'background-color': 'orange',
                      },
                    })),
                  ]
                ),
                (positioned = createElement('div', {
                  class: 'positioned',
                  style: {
                    position: 'absolute',
                    left: '25px',
                    height: '25px',
                    width: '50px',
                    'box-sizing': 'border-box',
                    top: '0',
                    'z-index': '150',
                    'background-color': 'green',
                  },
                })),
                (positioned_1 = createElement('div', {
                  class: 'positioned',
                  style: {
                    position: 'absolute',
                    left: '25px',
                    height: '25px',
                    width: '50px',
                    'box-sizing': 'border-box',
                    top: '25px',
                    'z-index': '50',
                    'background-color': 'purple',
                  },
                })),
              ]
            ),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  position: 'relative',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      display: 'flex',
                    },
                  },
                  [
                    (flexItem_2 = createElement('img', {
                      class: 'flex-item',
                      style: {
                        width: '50px',
                        height: '50px',
                        'box-sizing': 'border-box',
                        'z-index': '1',
                        'background-color': 'salmon',
                      },
                    })),
                    (flexItem_3 = createElement('img', {
                      class: 'flex-item',
                      style: {
                        width: '50px',
                        height: '50px',
                        'box-sizing': 'border-box',
                        'z-index': '100',
                        'background-color': 'orange',
                      },
                    })),
                  ]
                ),
                (positioned_2 = createElement('img', {
                  class: 'positioned',
                  style: {
                    position: 'absolute',
                    left: '25px',
                    height: '25px',
                    width: '50px',
                    'box-sizing': 'border-box',
                    top: '0',
                    'z-index': '150',
                    'background-color': 'green',
                  },
                })),
                (positioned_3 = createElement('img', {
                  class: 'positioned',
                  style: {
                    position: 'absolute',
                    left: '25px',
                    height: '25px',
                    width: '50px',
                    'box-sizing': 'border-box',
                    top: '25px',
                    'z-index': '50',
                    'background-color': 'purple',
                  },
                })),
              ]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it("img-size", async () => {
    let flexItem;
    let flexItem_1;
    let positioned;
    let positioned_1;
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `The green boxes should be above the orange boxes, which should be above the purple boxes, which are above the salmon boxes.`
        ),
        createElement(
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
                  position: 'relative',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      display: 'flex',
                    },
                  },
                  [
                    (flexItem = createElement('img', {
                      class: 'flex-item',
                      style: {
                        width: '50px',
                        height: '50px',
                        'box-sizing': 'border-box',
                        'z-index': '1',
                        'background-color': 'salmon',
                      },
                    })),
                    (flexItem_1 = createElement('img', {
                      class: 'flex-item',
                      style: {
                        width: '50px',
                        height: '50px',
                        'box-sizing': 'border-box',
                        'z-index': '100',
                        'background-color': 'orange',
                      },
                    }))
                  ]
                ),
              ]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(div);


    await snapshot();
  });
  it('and-percentage-abspos', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              overflow: 'hidden',
              position: 'relative',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '100%',
                height: '100%',
                position: 'absolute',
                top: '0',
                left: '0',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                width: '100px',
                height: '100px',
                background: 'green',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
