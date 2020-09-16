describe('max-height', () => {
  it("should not work with display inline element", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '10px',
        display: 'inline',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display inline-block when child height is larger than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '10px',
        display: 'inline-block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display inline-block when child height is smaller than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '50px',
        display: 'inline-block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display inline-flex when child height is larger than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '10px',
        display: 'inline-flex',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display inline-flex when child height is smaller than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '50px',
        display: 'inline-block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display block when child height is larger than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '10px',
        display: 'block',
      }
    }, [
      createText('This text should be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display block when child length is smaller than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '50px',
        display: 'block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });


  it("should work with display flex when child height is larger than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '10px',
        display: 'flex',
      }
    }, [
      createText('This text should be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display flex when child height is smaller than max-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        maxHeight: '50px',
        display: 'flex',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it('should work with replaced element when element height is smaller than intrinsic height', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': '#999',
          height: '200px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
            src: 'assets/100x100-green.png',
            style: {
              'background-color': 'green',
              maxHeight: '50px',
              'box-sizing': 'border-box',
            },
          },
        )
      ]
    );
    BODY.appendChild(flexbox);

    await matchViewportSnapshot(0.1);
  });

  it('should work with replaced element when element height is larger than intrinsic height', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        style: {
          'background-color': '#999',
          height: '200px',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
            src: 'assets/100x100-green.png',
            style: {
              'background-color': 'green',
              maxHeight: '200px',
              'box-sizing': 'border-box',
            },
          },
        )
      ]
    );
    BODY.appendChild(flexbox);

    await matchViewportSnapshot(0.1);
  });

});
