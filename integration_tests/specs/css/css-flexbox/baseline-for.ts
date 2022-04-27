/*auto generated*/
describe('baseline-for', () => {
  it('empty-line-expected', async () => {
    let b;
    let b_1;
    let b_2;
    let p;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`abc
`),
        (b = createElement(
          'span',
          {
            class: 'b',
            style: {
              display: 'inline-block',
              border: 'rgba(255,0,0,0.5) solid 1px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              contenteditable: 'true',
              style: {
                display: 'inline-block',
                background: '#ddf',
                'min-width': '20px',
                margin: '2px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
        (b_1 = createElement(
          'span',
          {
            class: 'b',
            style: {
              display: 'inline-block',
              border: 'rgba(255,0,0,0.5) solid 1px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                contenteditable: 'true',
                style: {
                  display: 'inline-block',
                  background: '#ddf',
                  'min-width': '20px',
                  margin: '2px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`a`)]
            ),
          ]
        )),
        (b_2 = createElement(
          'span',
          {
            class: 'b',
            style: {
              display: 'inline-block',
              border: 'rgba(255,0,0,0.5) solid 1px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                contenteditable: 'true',
                style: {
                  display: 'inline-block',
                  background: '#ddf',
                  'min-width': '20px',
                  margin: '2px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`a`)]
            ),
            createElement('span', {
              contenteditable: 'true',
              style: {
                display: 'inline-block',
                background: '#ddf',
                'min-width': '20px',
                margin: '2px',
                'box-sizing': 'border-box',
              },
            }),
            createElement(
              'span',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`non-editable`)]
            ),
          ]
        )),
        createText(`
def`),
      ]
    );
    BODY.appendChild(p);

    await matchViewportSnapshot();
  });
  it('empty-line', async () => {
    let flex;
    let flex_1;
    let flex_2;
    let p;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`abc
`),
        (flex = createElement(
          'span',
          {
            class: 'flex',
            style: {
              display: 'inline-flex',
              border: 'rgba(255,0,0,0.5) solid 1px',
              'align-items': 'baseline',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('span', {
              contenteditable: 'true',
              style: {
                display: 'inline-block',
                background: '#ddf',
                'min-width': '20px',
                margin: '2px',
                'box-sizing': 'border-box',
              },
            }),
          ]
        )),
        (flex_1 = createElement(
          'span',
          {
            class: 'flex',
            style: {
              display: 'inline-flex',
              border: 'rgba(255,0,0,0.5) solid 1px',
              'align-items': 'baseline',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                contenteditable: 'true',
                style: {
                  display: 'inline-block',
                  background: '#ddf',
                  'min-width': '20px',
                  margin: '2px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`a`)]
            ),
          ]
        )),
        (flex_2 = createElement(
          'span',
          {
            class: 'flex',
            style: {
              display: 'inline-flex',
              border: 'rgba(255,0,0,0.5) solid 1px',
              'align-items': 'baseline',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'span',
              {
                contenteditable: 'true',
                style: {
                  display: 'inline-block',
                  background: '#ddf',
                  'min-width': '20px',
                  margin: '2px',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`a`)]
            ),
            createElement('span', {
              contenteditable: 'true',
              style: {
                display: 'inline-block',
                background: '#ddf',
                'min-width': '20px',
                margin: '2px',
                'box-sizing': 'border-box',
              },
            }),
            createElement(
              'span',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`non-editable`)]
            ),
          ]
        )),
        createText(`
def`),
      ]
    );
    BODY.appendChild(p);

    await matchViewportSnapshot();
  });
});
