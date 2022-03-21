/*auto generated*/
describe('block-fit', () => {
  it('content-as-initial-ref', async () => {
    let child;
    let parent;
    parent = createElement(
      'div',
      {
        class: 'parent',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('img', {
          class: 'child',
          src:
            '/assets/60x60-green.png',
          style: {
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(parent);

    await snapshot(0.1);
  });
  xit('content-as-initial', async () => {
    let child;
    let parent;
    parent = createElement(
      'div',
      {
        class: 'parent',
        style: {
          height: 'fit-content',
          'box-sizing': 'border-box',
        },
      },
      [
        (child = createElement('img', {
          class: 'child',
          src:
            '/assets/60x60-green.png',
          style: {
            'max-height': '100%',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(parent);

    await snapshot();
  });
});
