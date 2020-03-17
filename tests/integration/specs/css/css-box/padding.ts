describe('box', () => {
  it('should work with padding', async () => {
    const container1 = document.createElement('div');
    setStyle(container1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      padding: 0
    });

    document.body.appendChild(container1);

    const container2 = document.createElement('div');
    setStyle(container2, {
      width: '50px',
      height: '50px',
      backgroundColor: '#f40',
    });

    container1.appendChild(container2);
    container1.style.padding = '20px';

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();
  });
});
