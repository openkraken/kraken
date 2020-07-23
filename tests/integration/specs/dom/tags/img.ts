describe('Tags img', () => {
  it('basic', (done) => {
    const img = document.createElement('img');
    img.addEventListener('load', async () => {
      await matchElementImageSnapshot(img);
      done();
    });
    img.style.width = '60px';
    img.setAttribute(
      'src',
      '//gw.alicdn.com/tfs/TB1MRC_cvb2gK0jSZK9XXaEgFXa-1701-1535.png'
    );

    document.body.appendChild(img);
  });

  fit('new Image', (done) => {
    const img = new Image();
    img.onload = img.onerror = (evt) => {
      done();
    };
    img.src = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
  });

  describe('object-fit', () => {
    const imageURL = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    const OBJECT_FITS = [
      'contain',
      'cover',
      'fill',
      'none',
      'scale-down',
    ];
    OBJECT_FITS.forEach((value) => {
      it(`should work with ${value}`, (done) => {
        const img = document.createElement('img');
        img.style.width = img.style.height = '300px';
        img.style.border = '3px solid #000';
        img.style.objectFit = value;
        img.setAttribute(
          'src',
          imageURL + '?objectFit=' + value
        );

        img.addEventListener('load', async () => {
          await matchElementImageSnapshot(img);
          done();
        });

        document.body.appendChild(img);
      });
    });
  });

  describe('object-position', () => {
    const imageURL = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    const OBJECT_POSITIONS = [
      '50% 50%',
      'right top',
      'left bottom',
      'center bottom',
    ];
    OBJECT_POSITIONS.forEach((value) => {
      it(`should work with ${value}`, (done) => {
        const img = document.createElement('img');
        img.style.width = img.style.height = '300px';
        img.style.border = '3px solid #000';
        img.style.objectFit = 'none';
        img.style.objectPosition = value;
        img.setAttribute(
          'src',
          imageURL + '?objectPosition=' + value
        );

        img.addEventListener('load', async () => {
          await matchElementImageSnapshot(img);
          done();
        });

        document.body.appendChild(img);
      });
    });
  });

  it('set src property setter', async () => {
    const img = createElement('img', {
      src: 'assets/rabbit.png'
    }) as HTMLImageElement;
    BODY.appendChild(img);
    let src = img.src;
    expect(src).toBe('assets/rabbit.png');
    // have to wait for asset load?
    await sleep(0.1);
    await matchScreenshot();
    img.src = 'assets/solidblue.png';
    await sleep(0.1);
    await matchScreenshot();
    src = img.src;
    expect(src).toBe('assets/solidblue.png');
  });

  it('read image size through property', async (done) => {
    const img = document.createElement('img');
    img.onload = async () => {
      expect(img.width).toBe(70);
      expect(img.height).toBe(72);
      await matchScreenshot();
      done();
    };
    img.src = 'assets/rabbit.png';
    BODY.appendChild(img);
  });

  it('change image src dynamically', async () => {
    const img = createElement('img', {
      src: 'assets/rabbit.png'
    }) as HTMLImageElement;
    BODY.appendChild(img);
    await matchScreenshot();
    img.src = 'assets/300x150-green.png';
    await matchScreenshot();
  });


  it('support base64 data url', async () => {
    var img = document.createElement('img');
    img.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAIAAAC0tAIdAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAACJJREFUKFNjZGD4z0AKAKomHpGgFOQK4g0eVY01rEZCCAIAC+rSL3tdVQUAAAAASUVORK5CYII=';
    document.body.appendChild(img);
    await matchElementImageSnapshot(img);
  })
});
