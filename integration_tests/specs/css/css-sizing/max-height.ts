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

  it("should work with display inline-block when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        maxHeight: '100px',
        display: 'inline-block',
      }
    });
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display block when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        maxHeight: '100px',
        display: 'block',
      }
    });
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display inline-flex when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        maxHeight: '100px',
        display: 'inline-flex',
      }
    });
    BODY.appendChild(containingBlock);

    await matchViewportSnapshot();
  });

  it("should work with display flex when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        maxHeight: '100px',
        display: 'flex',
      }
    });
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

  it('should work with percentage in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '200px',
            maxHeight: '50%',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '200px',
            maxHeight: '50%',
            width: '50%',
            backgroundColor: 'blue',
          }
        },
        )
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage in flex layout in row direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '200px',
            maxHeight: '50%',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '200px',
            maxHeight: '50%',
            width: '50%',
            backgroundColor: 'blue',
          }
        },
        )
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('should work with percentage in flex layout in column direction', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            height: '200px',
            maxHeight: '50%',
            width: '50%',
            backgroundColor: 'yellow',
          }
        }),
        createElement('div', {
          style: {
            height: '200px',
            maxHeight: '50%',
            width: '50%',
            backgroundColor: 'blue',
          }
        },
        )
      ]
    );

    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('change from not none to none', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          height: '200px',
          maxHeight: '100px',
          width: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
        }
      }
    );
    append(BODY, cont);

    await matchViewportSnapshot();

    requestAnimationFrame(async () => {
      cont.style.maxHeight = 'none';
      await matchViewportSnapshot(0.1);
      done();
    });
  });
});
