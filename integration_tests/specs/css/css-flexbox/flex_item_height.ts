describe('flexbox flex-item', () => {
  it('should work with height', async () => {
    var container = document.createElement('div');
    document.body.appendChild(container);

    var flex1 = document.createElement('div');
    setElementStyle(flex1, {
      display: 'flex',
      flexDirection: 'row',
      justifyContent: 'space-between',
      backgroundColor: '#f40',
      height: '100px',
    });

    var div1 = document.createElement('div');
    setElementStyle(div1, {
      backgroundColor: '#999',
      height: '50px',
    });
    var text1 = document.createTextNode('1111');
    div1.appendChild(text1);

    var div2 = document.createElement('div');
    setElementStyle(div2, {
      backgroundColor: '#999',
    });
    var text2 = document.createTextNode('2222');
    div2.appendChild(text2);

    var div3 = document.createElement('div');
    setElementStyle(div3, {
      display: 'flex',
      backgroundColor: '#999',
      height: '50px',
    });
    var text3 = document.createTextNode('3333');
    div3.appendChild(text3);

    var div4 = document.createElement('div');
    setElementStyle(div4, {
      display: 'flex',
      backgroundColor: '#999',
    });
    var text4 = document.createTextNode('4444');
    div4.appendChild(text4);

    container.appendChild(flex1);
    flex1.appendChild(div1);
    flex1.appendChild(div2);
    flex1.appendChild(div3);
    flex1.appendChild(div4);

    await snapshot();
  });
});
