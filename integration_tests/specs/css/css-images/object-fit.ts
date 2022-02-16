describe('object-fit', () => {
  it('should works with fill of image when width is larger than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-h-50px.png',
        style: {
          display: 'block',
          'object-fit': 'fill',
          width: '100px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should works with fill of image when width is smaller than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'fill',
          width: '100px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should works with cover of image aspect ratio smaller than size aspect ratio when width is larger than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-h-50px.png',
        style: {
          display: 'block',
          'object-fit': 'cover',
          width: '200px',
          height: '40px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should works with cover of image aspect ratio larger than size aspect ratio  when width is larger than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-h-50px.png',
        style: {
          display: 'block',
          'object-fit': 'cover',
          width: '100px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should works with cover of image aspect ratio smaller than size aspect ratio when width is smaller than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'cover',
          width: '40px',
          height: '200px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should works with cover of image aspect ratio larger than size aspect ratio  when width is smaller than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'cover',
          width: '100px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should works with contain of image aspect ratio smaller than size aspect ratio when width is larger than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-h-50px.png',
        style: {
          display: 'block',
          'object-fit': 'contain',
          width: '200px',
          height: '40px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should works with contain of image aspect ratio larger than size aspect ratio  when width is larger than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-h-50px.png',
        style: {
          display: 'block',
          'object-fit': 'contain',
          width: '100px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  fit('should works with contain of image aspect ratio smaller than size aspect ratio when width is smaller than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'contain',
          width: '40px',
          height: '200px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  fit('should works with contain of image aspect ratio larger than size aspect ratio  when width is smaller than heigth', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'contain',
          width: '100px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

});
