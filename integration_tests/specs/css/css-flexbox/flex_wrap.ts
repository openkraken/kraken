describe('flexbox flex-wrap', () => {
  it('should work with wrap', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          flexWrap: 'wrap',
          justifyContent: 'center',
          width: '300px',
          height: '400px',
          marginBottom: '10px',
          backgroundColor: '#ddd',
        },
      },
      [
        (createElement('div', {
          id: 'child_1',
          style: {
            backgroundColor: 'red',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with nowrap', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          flexWrap: 'nowrap',
          justifyContent: 'center',
          width: '300px',
          height: '400px',
          marginBottom: '10px',
          backgroundColor: '#ddd',
        },
      },
      [
        (createElement('div', {
          id: 'child_1',
          style: {
            backgroundColor: 'red',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it('should work with wrap-reverse', async () => {
    const container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          flexWrap: 'wrap-reverse',
          justifyContent: 'center',
          width: '300px',
          height: '400px',
          marginBottom: '10px',
          backgroundColor: '#ddd',
        },
      },
      [
        (createElement('div', {
          id: 'child_1',
          style: {
            backgroundColor: 'red',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'blue',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
        (createElement('div', {
          id: 'child_2',
          style: {
            backgroundColor: 'green',
            width: '100px',
            height: '100px',
            margin: '10px',
          },
        })),
      ]
    );

    document.body.appendChild(container);
    await snapshot();
  });

  it("should work with wrap when flex-direction is column and height not exists", async () => {
    let flexbox_1;

    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column align-items-flex-start wrap-reverse',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap',
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
    BODY.appendChild(flexbox_1);

    await snapshot();
  });

  it("should work with wrap when flex-direction is column and height is smaller than children's height", async () => {
    let flexbox_1;

    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column align-items-flex-start wrap-reverse',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap',
          'align-items': 'flex-start',
          'box-sizing': 'border-box',
          'height': '30px',
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
          [createText(`should not be left aligned.`)]
        ),
      ]
    );
    BODY.appendChild(flexbox_1);

    await snapshot();
  });
});
