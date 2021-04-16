/*auto generated*/
describe('overflow-ellipsis', () => {
  it('dynamic-001', async () => {
    let p;
    p = createElement(
      'p',
      {
        style: {
          width: '40ch',
          font: '16px/1 monospace',
          'text-overflow': 'ellipsis',
          'white-space': 'nowrap',
          overflow: 'hidden',
          'box-sizing': 'border-box',
        },
      },
      [createText(`short`)]
    );
    BODY.appendChild(p);

    await snapshot();
  });
});
