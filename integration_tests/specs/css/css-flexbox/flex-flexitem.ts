/*auto generated*/
describe('flex-flexitem', () => {
  it("childmargin", async () => {
    let fixed;
    let flex;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: 'blue',
          display: 'flex',
          height: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (fixed = createElement(
          'div',
          {
            class: 'fixed',
            style: {
              height: '300px',
              flex: '1',
              background: 'red',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'p',
              {
                style: {
                  margin: '200px 0 0 0',
                  'box-sizing': 'border-box',
                  width: '100px',
                  height: '100px',
                  background: 'orange',
                },
              },
              [
                createText(`
            a
            `),
              ]
            ),
          ]
        )),
        (flex = createElement(
          'div',
          {
            class: 'flex',
            style: {
              width: '100px',
              background: 'red',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'p',
              {
                style: {
                  margin: '200px 0 0 0',
                  'box-sizing': 'border-box',
                  width: '100px',
                  height: '100px',
                  background: 'green',
                },
              },
              [
                createText(`
            b
            `),
              ]
            ),
          ]
        )),
      ]
    );
    BODY.appendChild(test);


    await snapshot();
  })
  it('childmargin-ref', async () => {
    let fixed;
    let flex;
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: 'blue',
          display: 'block',
          height: '300px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (fixed = createElement(
          'div',
          {
            class: 'fixed',
            style: {
              height: '300px',
              flex: '1',
              background: 'red',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'p',
              {
                style: {
                  margin: '200px 0 0 0',
                  'box-sizing': 'border-box',
                  width: '100px',
                  height: '100px',
                  background: 'orange',
                  position: 'absolute',
                  left: '0px',
                  bottom: '0px',
                },
              },
              [
                createText(`
        a
        `),
              ]
            ),
          ]
        )),
        (flex = createElement(
          'div',
          {
            class: 'flex',
            style: {
              width: '100px',
              background: 'red',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'p',
              {
                style: {
                  margin: '200px 0 0 0',
                  'box-sizing': 'border-box',
                  width: '100px',
                  height: '100px',
                  background: 'green',
                  position: 'absolute',
                  right: '0px',
                  bottom: '0px',
                },
              },
              [
                createText(`
        b
        `),
              ]
            ),
          ]
        )),
      ]
    );
    BODY.appendChild(test);

    await snapshot();
  });
  it('percentage-prescation-ref', async () => {
    let test;
    let test_1;
    test_1 = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: 'red',
          position: 'relative',
          height: '300px',
          width: '101px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement(
          'div',
          {
            id: 'test',
            style: {
              background: 'red',
              position: 'relative',
              height: '300px',
              width: '101px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'p',
              {
                style: {
                  position: 'absolute',
                  margin: '0 0 0 0',
                  'box-sizing': 'border-box',
                  background: 'green',
                  top: '0px',
                  height: '300px',
                  left: '0px',
                  width: '50.5px',
                },
              },
              [createText(`d`)]
            ),
            createElement(
              'p',
              {
                style: {
                  position: 'absolute',
                  margin: '0 0 0 0',
                  'box-sizing': 'border-box',
                  top: '0px',
                  left: '50.5px',
                  height: '300px',
                  background: 'olive',
                  width: '50.5px',
                },
              },
              [createText(`d`)]
            ),
          ]
        )),
      ]
    );
    BODY.appendChild(test_1);

    await snapshot();
  });
  it("percentage-prescation", async () => {
    let test;
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: 'red',
          display: 'flex',
          height: '300px',
          width: '101px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'p',
          {
            style: {
              flex: '1',
              background: 'green',
              'flex-direction': 'row',
              margin: '0 0 0 0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d`)]
        ),
        createElement(
          'p',
          {
            style: {
              flex: '1',
              background: 'olive',
              'flex-direction': 'row',
              margin: '0 0 0 0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`d`)]
        ),
      ]
    );
    BODY.appendChild(test);


    await snapshot();
  })
});
