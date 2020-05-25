/*auto generated*/
describe('flex-items', () => {
  xit('flexibility', async () => {
    let failFlag;
    let flex;
    let container;
    failFlag = createElement('div', {
      id: 'fail-flag',
      style: {
        padding: '10px',
        width: '120px',
        height: '40px',
        'text-align': 'center',
        flex: '1 0 auto',
        position: 'absolute',
        top: '150px',
        left: '100px',
        background: 'red',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'justify-content': 'center',
          'align-items': 'center',
          border: '5px solid green',
          width: '300px',
          height: '200px',
          padding: '5px',
          'border-radius': '3px',
          position: 'absolute',
          top: '70px',
          left: '10px',
          'text-align': 'center',
          flex: '1 0 auto',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: '1 0 auto',
            'box-sizing': 'border-box',
          },
        }),
        (flex = createElement('div', {
          id: 'flex',
          style: {
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: '2 0 auto',
            border: '2px dotted blue',
            background: 'green',
            'border-radius': '3px',
            'box-sizing': 'border-box',
          },
        })),
        createElement('div', {
          style: {
            padding: '10px',
            width: '30px',
            height: '40px',
            'text-align': 'center',
            flex: '1 0 auto',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(failFlag);
    BODY.appendChild(container);

    await matchScreenshot();
  });

  it('works with multiple relative item', async (done) => {
    const n1 = createElementWithStyle(
       'div',
       {
         display: 'flex',
         flexDirection: 'column',
         width: '300px',
         height: '300px',
         backgroundColor: 'gray',
       },
       [
        createElementWithStyle(
          'div',
           {
             position: 'relative',
             width: '100px',
             height: '100px',
             backgroundColor: 'blue',
           },
        ),
        createElementWithStyle(
          'div',
           {
             position: 'relative',
             width: '100px',
             height: '100px',
             backgroundColor: 'green',
           },
        ),
       ]
     );
    BODY.appendChild(n1);

    await matchScreenshot();
  });
});
