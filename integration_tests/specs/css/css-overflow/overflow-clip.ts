describe('clip', () => {
  fit('should works with basic', async () => {
    let image;
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "clip",
      }
    }, [
      (image = createElement('img', {
          src: 'assets/100x100-green.png',
      })) 
    ]);
  
    document.body.appendChild(container);
  
    await snapshot(0.1);
  });

  fit('should works with children of appear event', async () => {
    let image;
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "clip",
      }
    }, [
      (image = createElement('img', {
          src: 'assets/100x100-green.png',
      })) 
    ]);
  
    image.addEventListener('appear', function onAppear() {});
  
    document.body.appendChild(container);
  
    await snapshot(0.1);
  });
});
