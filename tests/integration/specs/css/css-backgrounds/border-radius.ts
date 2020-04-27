describe('border_radius', () => {
  it('all_direction', async () => {
    let container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: '#252423',
      height: '500px',
    });

    for (let i = 0; i < 5; i++) {
      let dotEl = document.createElement('div');
      setElementStyle(dotEl, {
        display: 'inline-block',
        marginLeft: '5px',
        width: '40px',
        height: '40px',
        borderRadius: '20px',
        backgroundColor: '#FF4B4B',
      });
      container.appendChild(dotEl);
    }

    document.body.appendChild(container);

    await matchScreenshot();
  });
});
