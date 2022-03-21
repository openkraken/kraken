describe('percentage', () => {
  it('works in nested flex layout', async () => {
    let log;
    let child;
    let flexitem;
    let flexbox;
    let container;
    container = createElement(
      'div',
      {
        style: {
          "height": "86px",
          "flexDirection": "row",
          "alignItems": "center",
          "display": "flex",
          "width": "100%"
        },
      },
      [
        createElement(
          'img',
          {
            src: '/assets/100x100-green.png',
            style: {
              width: '50px',
              height: '50px',
            },
          },
        ),
        createElement(
          'div',
          {
            style: {
              "height": "50px",
              "display": "flex",
              "flexDirection": "column",
              "justifyContent": "space-between",
              "margin": "0 0 0 10px",
              "alignItems": "flex-start",
              "position": "relative",
              "width": "100%"

            }
          },
          [
            createElement('div', {
              style: {
                fontSize: '16px'
              }
            }, [
              createText('Main title')
            ]),
            createElement('div', {
              style: {
                "fontSize": "14px",
                "textOverflow": "ellipsis",
                "display": "block",
                "overflow": "hidden",
                "whiteSpace": "nowrap",
                "position": "absolute",
                "bottom": "0",
                "right": "0",
                "left": "0",
                "lineClamp": "1"
              }
            }, [
              createText('The end of this line should display an ellipsis instead of clipped text.')
            ]),
          ]
        )
      ]
    );
    BODY.appendChild(container);

    await snapshot(0.1);
  });
});
