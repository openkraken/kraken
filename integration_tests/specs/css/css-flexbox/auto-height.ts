describe('auto-height', () => {
  it('column-with-border-and-padding', async () => {
    let flexOneOneAuto;
    let flexbox;
    flexbox = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          'box-sizing': 'border-box',
          border: '5px solid salmon',
          padding: '5px',
          overflow: 'scroll',
        },
      },
      [
        (flexOneOneAuto = createElement(
          'div',
          {
            class: 'flex-one-one-auto',
            style: {
              'box-sizing': 'border-box',
              'min-height': '0',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  height: '50px',
                  'background-color': 'pink',
                },
              },
              [
                createElement('div', {
                  style: {
                    'box-sizing': 'border-box',
                  },
                }),
              ]
            ),
          ]
        )),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it("with flex", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
          border: '1px solid purple',
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
          [createText(`Header`)]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              flex: '1',
            },
          },
          [
            createText(`Flexible content`),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("should works with padding and flex item of flex-basis 0", async () => {
    let container;

    container = createElement(
      'div',
      {
        style: {
          "display": "flex",
          "flexDirection": "column",
          "padding": "4vw 0vw",
        },
      },
      [
        createElement('div', {
          style: {
            "flex": "1",
            "overflow": "scroll"
          }
        }, [
          createElement('div', {
            style: {
              width: '100px',
              height: '100px',
              background: 'green'    
            }
          }),
        ])
      ]);

    BODY.appendChild(container);

    await snapshot();
  });
});
