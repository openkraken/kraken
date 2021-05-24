describe('Box', () => {
  it('should work with basic samples', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '20px',
      border: '5px solid #000',
    });

    const container2 = document.createElement('div');
    setElementStyle(container2, {
      padding: '20px',
      backgroundColor: '#666',
      margin: '20px',
      border: '5px solid #000',
    });

    const container3 = document.createElement('div');
    setElementStyle(container3, {
      padding: '20px',
      height: '100px',
      backgroundColor: '#f40',
      margin: '20px',
      border: '5px solid #000',
    });

    const textNode = document.createTextNode('Hello World');
    document.body.appendChild(container1);
    container1.appendChild(container2);
    container2.appendChild(container3);
    container3.appendChild(textNode);

    await snapshot();
  });
});
