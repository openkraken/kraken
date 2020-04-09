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
});
