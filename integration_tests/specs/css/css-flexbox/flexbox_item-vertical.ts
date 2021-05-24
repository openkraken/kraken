/*auto generated*/
describe('flexbox_item-vertical', () => {
  it('align', async () => {
    let one;
    let two;
    let three;
    let four;
    let five;
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'yellow',
          border: '1px solid black',
          width: '600px',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        (one = createElement('p', {
          id: 'one',
          style: {
            background: '#3366cc',
            margin: '20px',
            width: '20px',
            height: '20px',
            'vertical-align': 'bottom',
            'box-sizing': 'border-box',
          },
        })),
        (two = createElement('p', {
          id: 'two',
          style: {
            background: '#3366cc',
            margin: '20px',
            width: '20px',
            height: '20px',
            'vertical-align': 'top',
            'box-sizing': 'border-box',
          },
        })),
        (three = createElement('p', {
          id: 'three',
          style: {
            background: '#3366cc',
            margin: '20px',
            width: '20px',
            height: '20px',
            'vertical-align': 'middle',
            'box-sizing': 'border-box',
          },
        })),
        (four = createElement('p', {
          id: 'four',
          style: {
            background: '#3366cc',
            margin: '20px',
            width: '20px',
            height: '20px',
            'vertical-align': 'super',
            'box-sizing': 'border-box',
          },
        })),
        (five = createElement('p', {
          id: 'five',
          style: {
            background: '#3366cc',
            margin: '20px',
            width: '20px',
            height: '20px',
            'vertical-align': 'sub',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
