describe('Tags img', () => {
  it('basic', (done) => {
    const img = document.createElement('img');
    img.addEventListener('load', async () => {
      await snapshot(img);
      done();
    });
    img.style.width = '60px';
    img.setAttribute(
      'src',
      'assets/100x100-green.png'
    );

    document.body.appendChild(img);
  });

  it('don\'t error when append child on img element', async (done) => {
    let img = document.createElement('img');
    img.src = 'https://gw.alicdn.com/tfs/TB1MRC_cvb2gK0jSZK9XXaEgFXa-1701-1535.png';
    document.body.appendChild(img);

    img.onload = async () => {
      await snapshot();
      let text = document.createTextNode('text');
      img.appendChild(text);
      await snapshot();

      done();
    };
  });

  it('new Image', (done) => {
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
          await snapshot(img);
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
          await snapshot(img);
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
    await snapshot();
    img.src = 'assets/solidblue.png';
    await sleep(0.1);
    await snapshot();
    src = img.src;
    expect(src).toBe('assets/solidblue.png');
  });

  it('read image size through property', async (done) => {
    const img = document.createElement('img');
    img.onload = async () => {
      expect(img.width).toBe(70);
      expect(img.height).toBe(72);
      await snapshot();
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
    await snapshot(0.2);
    img.src = 'assets/300x150-green.png';
    await snapshot(0.2);
  });

  it('support base64 data url', async () => {
    var img = document.createElement('img');
    img.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAIAAAC0tAIdAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAACJJREFUKFNjZGD4z0AKAKomHpGgFOQK4g0eVY01rEZCCAIAC+rSL3tdVQUAAAAASUVORK5CYII=';
    document.body.appendChild(img);
    await snapshot(0.2);
  });

  it('minwidth and minheight of image is 0', async () => {
    var img = document.createElement('img');
    img.src = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    img.style.minWidth = '0';
    img.style.minHeight = '0';
    img.style.display = 'inline';
    document.body.appendChild(img);
    await snapshot(0.2);
  });

  it('image size and image natural size', (done) => {
    var imageURL = 'https://img.alicdn.com/tfs/TB1RRzFeKL2gK0jSZFmXXc7iXXa-200-200.png?network';
    var img = document.createElement('img');
    img.onload = function() {
      expect(img.naturalWidth).toEqual(200);
      expect(img.naturalHeight).toEqual(200);
      done();
    };
    img.src = imageURL;
    Object.assign(img.style, {
      width: '20px',
      height: '20px',
    });

    document.body.style.background = 'green';
    document.body.appendChild(img);

    expect(img.width).toEqual(20);
    expect(img.height).toEqual(20);
    // Image has not been loaded.
    expect(img.naturalWidth).toEqual(0);
    expect(img.naturalHeight).toEqual(0);
  });

  it('should work with loading=lazy', (done) => {
    const img = document.createElement('img');
    // Make image loading=lazy.
    img.setAttribute('loading', 'lazy');
    img.src = 'assets/100x100-green.png';
    img.style.width = '60px';

    document.body.appendChild(img);

    img.onload = async () => {
      await snapshot(img);
      done();
    };
  });

  it ('lazy loading should work with scroll', (done) => {
    const img = document.createElement('img');
    img.setAttribute('loading', 'lazy');
    img.style.width = '60px';
    img.style.height = '60px';
    img.style.background = 'red';

    let div = document.createElement('div');
    div.style.width = '60px';
    div.style.height = '2000px';
    div.style.background = 'yellow';

    document.body.appendChild(div);
    document.body.appendChild(img);

    img.onload = async () => {
      window.scroll(0, 2000);
      await snapshot();
      done();
    };
    img.src = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';

    requestAnimationFrame(() => {
      window.scroll(0, 2000);
    });
  })

  it('should work with loading=lazy and transform', (done) => {
    const imageURL = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    const img = document.createElement('img');
    img.style.width = img.style.height = '300px';
    img.style.border = '3px solid #000';
    img.style.transform = 'translate(0, 100px)';
    img.setAttribute('loading', 'lazy');
    img.setAttribute(
      'src',
      imageURL
    );

    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });

    document.body.appendChild(img);
  });

  it('should work with loading=lazy and objectFit', (done) => {
    const imageURL = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    const img = document.createElement('img');
    img.style.width = img.style.height = '300px';
    img.style.border = '3px solid #000';
    img.style.objectFit = 'contain';
    img.setAttribute('loading', 'lazy');
    img.setAttribute(
      'src',
      imageURL
    );

    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });

    document.body.appendChild(img);
  });

  it('should work with loading=lazy and objectPosition', (done) => {
    const imageURL = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
    const img = document.createElement('img');
    img.style.width = img.style.height = '300px';
    img.style.border = '3px solid #000';
    img.style.objectFit = 'contain';
    img.style.objectPosition = 'center bottom';
    img.setAttribute('loading', 'lazy');
    img.setAttribute(
      'src',
      imageURL
    );

    img.addEventListener('load', async () => {
      await snapshot();
      done();
    });

    document.body.appendChild(img);
  });

  it('same image src should only trigger once event', async (done) => {
    const imageURL = 'assets/100x100-green.png';
    const img = document.createElement('img');
    img.src = imageURL;

    var loadCount = 0;
    img.onload = (event) => {
      loadCount++;
      document.body.removeChild(img);
      document.body.appendChild(img);
    };

    document.body.appendChild(img);

    setTimeout(() => {
      if (loadCount == 1) {
        done();
      } else {
        done('load event should only trigger once.');
      }
    }, 100);
  });

  it('gif can not replay by remove nodes', async (done) => {
    const imageURL = 'assets/sample-gif-40k.gif';
    const img = document.createElement('img');

    img.onload = async () => {
      await snapshot(img);
      document.body.removeChild(img);

      setTimeout(async () => {
        // When img re-append to document, to Gif image will continue to play.
        document.body.appendChild(img);
        await snapshot(img);
        done();
        // Delay 200ms to play gif.
      }, 200);
    };

    document.body.appendChild(img);
    img.src = imageURL;
  });

  it('width property change should work when width of style is not set', async (done) => {
    let img = createElement('img', {
      src: 'assets/300x150-green.png',
      width: 100,
      height: 100,
    });
    BODY.appendChild(img);
 
    requestAnimationFrame(async () => {
      img.width = 200;
      await snapshot(0.1);
      done();
    });
  });

  it('width property should not work when width of style is auto', async () => {
    let img = createElement('img', {
      src: 'assets/300x150-green.png',
      width: 100,
      height: 100,
      style: {
          width: 'auto'
      }
    });
    BODY.appendChild(img);
 
    await snapshot(0.1);
  });

  it('can get natualSize from repeat image url', async (done) => {
    const flutterContainer = document.createElement('div');
    flutterContainer.style.height = '100vh';
    flutterContainer.style.display = 'block';
    document.body.appendChild(flutterContainer);

    const colors = ['red', 'yellow', 'black', 'blue', 'green'];
    const images = [
      'assets/100x100-green.png',
      'assets/200x200-green.png',
      'assets/60x60-gg-rr.png',
    ];

    let loadedCount = 0;
    let imgCount = 10;

    for (let i = 0; i < imgCount; i++) {
      const div = document.createElement('div');
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.border = `3px solid ${colors[i % colors.length]}`
      div.appendChild(document.createTextNode(i));

      const img = document.createElement('img');
      img.src = images[i % images.length];
      div.appendChild(img);
      img.style.width = '80px';
      img.onload = async () => {
        loadedCount++;
        if (loadedCount == imgCount) {
          await snapshot();
          done();
        }
      };

      flutterContainer.appendChild(div);
    }
  });
});
