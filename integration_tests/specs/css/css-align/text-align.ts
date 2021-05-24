describe('Align text-align', () => {
  it('001', async () => {
    var container = document.createElement('div');

    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      textAlign: 'center',
      backgroundColor: '#f40',
    });
    div1.appendChild(document.createTextNode('flow layout text-align center'));
    container.appendChild(div1);

    var div2 = document.createElement('div');
    Object.assign(div2.style, {
      boxSizing: 'border-box',
      display: 'flex',
      flexDirection: 'column',
      alignContent: 'flex-start',
      flexShrink: 0,
      position: 'relative',
      textAlign: 'center',
      backgroundColor: 'green',
    });
    div2.appendChild(document.createTextNode('flex layout text-align center'));
    container.appendChild(div2);

    var div3 = document.createElement('div');
    Object.assign(div3.style, {
      textAlign: 'left',
      backgroundColor: 'red',
      lineHeight: '30px',
    });
    div3.appendChild(document.createTextNode('flow layout line-height 30'));
    container.appendChild(div3);

    var div4 = document.createElement('div');
    Object.assign(div4.style, {
      textAlign: 'right',
      backgroundColor: 'yellow',
      lineHeight: '40px',
    });
    div4.appendChild(document.createTextNode('flow layout line-height 40'));
    container.appendChild(div4);

    document.body.appendChild(container);

    await snapshot();
  });
});
