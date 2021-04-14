describe('vertical-align', () => {
  it('with baseline', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '35px',
            width: '200px',
            height: '50px',
            verticalAlign: 'baseline',
            },
        },[
            createText(`ABCD`),
        ]),
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            height: '50px',
            },
        },[
            createText(`1234`),
        ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with top', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '35px',
            width: '200px',
            },
        },[
            createText(`ABCD`),
        ]),
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            verticalAlign: 'top',

            },
        },[
            createText(`1234`),
        ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('with bottom', async () => {
    const div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          'backgroundColor': 'green',
          fontSize: '16px',
          width: '200px',
          height: '100px',
        },
      },
      [
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'blue',
            fontSize: '35px',
            width: '200px',
            },
        },[
            createText(`ABCD`),
        ]),
        createElement(
        'span',
        {
            style: {
            'box-sizing': 'border-box',
            'backgroundColor': 'red',
            fontSize: '16px',
            width: '200px',
            verticalAlign: 'bottom',

            },
        },[
            createText(`1234`),
        ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with baseline in nested inline elements", async () => {
    let container;
    container = createElement(
      'div',
      {style: {
        'box-sizing': 'border-box',
        height: '100px',
        width: '500px',
      }},
      [
        (createElement('div', {
          style: {
            'box-sizing': 'border-box',
            margin: '20px 0 0',
            height: '200px',
            width: '100px',
            'background-color': 'red',
            display: 'inline-block',
          }})),
        (createElement(
          'div',
          {style: {
            'box-sizing': 'border-box',
            height: '200px',
            width: '300px',
            display: 'inline-block',
            backgroundColor: '#999'
          }},
          [
            (createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '150px',
                width: '100px',
                'background-color': 'yellow',
                display: 'inline-block',
              }})),
          ]
        )),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it("work with baseline in nested block elements", async () => {
    let container;
    container = createElement(
      'div',
      {style: {
        'box-sizing': 'border-box',
        height: '100px',
        width: '500px',
      }},
      [
        (createElement('div', {
          style: {
            'box-sizing': 'border-box',
            margin: '20px 0 0',
            height: '200px',
            width: '100px',
            'background-color': 'red',
            display: 'inline-block',
          }})),
        (createElement(
          'div',
          {style: {
            'box-sizing': 'border-box',
            height: '200px',
            width: '300px',
            display: 'inline-block',
            backgroundColor: '#999'
          }},
          [
            (createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '150px',
                width: '100px',
                'background-color': 'yellow',
              }})),
          ]
        )),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it("work with baseline in nested block elements and contain text", async () => {
    let container;
    container = createElement(
      'div',
      {style: {
        'box-sizing': 'border-box',
        height: '100px',
        width: '500px',
      }},
      [
        (createElement('div', {
          style: {
            'box-sizing': 'border-box',
            margin: '20px 0 0',
            height: '200px',
            width: '100px',
            'background-color': 'red',
            display: 'inline-block',
          }})),
        (createElement(
          'div',
          {style: {
            'box-sizing': 'border-box',
            height: '200px',
            width: '300px',
            display: 'inline-block',
            backgroundColor: '#999'
          }},
          [
            (createElement('div', {
              style: {
                'box-sizing': 'border-box',
                height: '150px',
                width: '100px',
                'background-color': 'yellow',
              }},
              [
                createText('foo bar')
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });
});
