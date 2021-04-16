describe('flexbox flex-item', () => {
  it('should work with width', async () => {
    var container = document.createElement('div');
    document.body.appendChild(container);
    var flex2 = document.createElement('div');
    setElementStyle(flex2, {
      display: 'flex',
      flexDirection: 'column',
      backgroundColor: 'blue',
      justifyContent: 'center',
      height: '100px',
    });

    var div5 = document.createElement('div');
    setElementStyle(div5, {
      backgroundColor: '#999',
      width: '100px',
    });
    var text5 = document.createTextNode('5555');
    div5.appendChild(text5);

    var div6 = document.createElement('div');
    setElementStyle(div6, {
      backgroundColor: '#999',
    });
    var text6 = document.createTextNode('6666');
    div6.appendChild(text6);

    flex2.appendChild(div5);
    flex2.appendChild(div6);

    container.appendChild(flex2);
    await snapshot();
  });
});
