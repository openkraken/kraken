describe('Box padding', () => {
  it('should work with basic samples', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      padding: 0,
    });

    document.body.appendChild(container1);

    const container2 = document.createElement('div');
    setElementStyle(container2, {
      width: '50px',
      height: '50px',
      backgroundColor: '#f40',
    });

    container1.appendChild(container2);
    container1.style.padding = '20px';

    await matchViewportSnapshot();
  });

  it('should work with background-color', async () => {
    let div = createElementWithStyle('div', {
      width: '200px',
      height: '200px',
      backgroundColor: 'yellow',
      border: '10px solid cyan',
      padding: '15px',
    });
    append(BODY, div);
    let box = createElementWithStyle('div', {
      width: '50px',
      height: '50px',
      backgroundColor: 'red',
    });
    append(div, box);
    await matchViewportSnapshot();
  });
});
