describe('Position static', () => {
  it('001', async () => {
    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      position: 'static',
      top: '100px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('static element'));

    document.body.appendChild(div1);

    await snapshot();
  });
});
