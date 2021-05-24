/*auto generated*/
describe('overfow-outside', () => {
  it('padding', async () => {
    let target;
    let target_1;
    let target_2;
    let target_3;
    let target_4;
    let target_5;
    let container;
    let container_1;
    let container_2;
    let container_3;
    let container_4;
    let container_5;
    container = createElement(
      'div',
      {
        class: 'container htb',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          'box-sizing': 'border-box',
        },
      },
      [
        (target = createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            top: '-1000px',
          },
        })),
        createText(`
  htb
`),
      ]
    );
    container_1 = createElement(
      'div',
      {
        class: 'container htb rtl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        (target_1 = createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            right: '-1000px',
          },
        })),
        createText(`
  htb rtl
`),
      ]
    );
    container_2 = createElement(
      'div',
      {
        class: 'container vrl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          'box-sizing': 'border-box',
        },
      },
      [
        (target_2 = createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            top: '-1000px',
          },
        })),
        createText(`
  vrl
`),
      ]
    );
    container_3 = createElement(
      'div',
      {
        class: 'container vrl rtl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        (target_3 = createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            bottom: '-1000px',
          },
        })),
        createText(`
  vrl rtl
`),
      ]
    );
    container_4 = createElement(
      'div',
      {
        class: 'container vlr',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          'box-sizing': 'border-box',
        },
      },
      [
        (target_4 = createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            top: '-1000px',
          },
        })),
        createText(`
  vlr
`),
      ]
    );
    container_5 = createElement(
      'div',
      {
        class: 'container vlr rtl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        (target_5 = createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            left: '-1000px',
          },
        })),
        createText(`
  vlr rtl
`),
      ]
    );
    BODY.appendChild(container);
    BODY.appendChild(container_1);
    BODY.appendChild(container_2);
    BODY.appendChild(container_3);
    BODY.appendChild(container_4);
    BODY.appendChild(container_5);

    await snapshot();
  });
});
