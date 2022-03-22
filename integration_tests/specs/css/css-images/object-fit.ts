describe('object-fit', () => {
  it('should work with fill of image when width is larger than height', async () => {
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

  it('should work with fill of image when width is smaller than height', async () => {
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

  it('should work with cover of image aspect ratio smaller than size aspect ratio when width is larger than height', async () => {
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

  it('should work with cover of image aspect ratio larger than size aspect ratio  when width is larger than height', async () => {
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

  it('should work with cover of image aspect ratio smaller than size aspect ratio when width is smaller than height', async () => {
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

  it('should work with cover of image aspect ratio larger than size aspect ratio  when width is smaller than height', async () => {
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

  it('should work with contain of image aspect ratio smaller than size aspect ratio when width is larger than height', async () => {
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

  it('should work with contain of image aspect ratio larger than size aspect ratio  when width is larger than height', async () => {
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

  it('should work with contain of image aspect ratio smaller than size aspect ratio when width is smaller than height', async () => {
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

  it('should work with contain of image aspect ratio larger than size aspect ratio  when width is smaller than height', async () => {
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


  it('should work with none', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'none',
          width: '40px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should work with scale-down when it behaves as none', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'scale-down',
          width: '100px',
          height: '250px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  it('should work with scale-down when it behaves as contain', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/ruler-v-100px.png',
        style: {
          display: 'block',
          'object-fit': 'scale-down',
          width: '40px',
          height: '100px',
          backgroundColor: 'yellow'
        },
      },
    );
    BODY.appendChild(image);
 
    await snapshot(0.1);
  });

  describe('with scaling is scale', () => {
    it('should work with fill of image when width is larger than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-h-50px.png',
          scaling: 'scale',
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

    it('should work with fill of image when width is smaller than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
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

    it('should work with cover of image aspect ratio smaller than size aspect ratio when width is larger than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-h-50px.png',
          scaling: 'scale',
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

    it('should work with cover of image aspect ratio larger than size aspect ratio  when width is larger than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-h-50px.png',
          scaling: 'scale',
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

    it('should work with cover of image aspect ratio smaller than size aspect ratio when width is smaller than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
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

    it('should work with cover of image aspect ratio larger than size aspect ratio  when width is smaller than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
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

    it('should work with contain of image aspect ratio smaller than size aspect ratio when width is larger than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-h-50px.png',
          scaling: 'scale',
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

    it('should work with contain of image aspect ratio larger than size aspect ratio  when width is larger than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-h-50px.png',
          scaling: 'scale',
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

    it('should work with contain of image aspect ratio smaller than size aspect ratio when width is smaller than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
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

    it('should work with contain of image aspect ratio larger than size aspect ratio  when width is smaller than height', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
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


    it('should work with none', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
          style: {
            display: 'block',
            'object-fit': 'none',
            width: '40px',
            height: '100px',
            backgroundColor: 'yellow'
          },
        },
      );
      BODY.appendChild(image);
  
      await snapshot(0.1);
    });

    it('should work with scale-down when it behaves as none', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
          style: {
            display: 'block',
            'object-fit': 'scale-down',
            width: '100px',
            height: '250px',
            backgroundColor: 'yellow'
          },
        },
      );
      BODY.appendChild(image);
  
      await snapshot(0.1);
    });

    it('should work with scale-down when it behaves as contain', async () => {
      let image;
      image = createElement(
        'img',
        {
          src: 'assets/ruler-v-100px.png',
          scaling: 'scale',
          style: {
            display: 'block',
            'object-fit': 'scale-down',
            width: '40px',
            height: '100px',
            backgroundColor: 'yellow'
          },
        },
      );
      BODY.appendChild(image);
  
      await snapshot(0.1);
    });
  });

  it('should work with value change to empty string', async (done) => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/css3.png',
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
 
    requestAnimationFrame(async () => {
      image.style.objectFit = '';
      await snapshot(0.1);
      done();
    });
  });

});
