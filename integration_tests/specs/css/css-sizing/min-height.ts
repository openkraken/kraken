describe('min-height', () => {
  it("should not work with display inline element", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '50px',
        display: 'inline',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display inline-block when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        minHeight: '100px',
        display: 'inline-block',
      }
    });
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display block when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        minHeight: '100px',
        display: 'block',
      }
    });
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display inline-flex when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        minHeight: '100px',
        display: 'inline-flex',
      }
    });
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display flex when it has no children and height not exist", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        width: '300px',
        minHeight: '100px',
        display: 'flex',
      }
    });
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display inline-block when child height is larger than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '10px',
        display: 'inline-block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display inline-block when child height is smaller than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '50px',
        display: 'inline-block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display inline-flex when child height is larger than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '10px',
        display: 'inline-flex',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display inline-flex when child height is smaller than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '50px',
        display: 'inline-block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display block when child height is larger than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '10px',
        display: 'block',
      }
    }, [
      createText('This text should be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display block when child length is smaller than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '50px',
        display: 'block',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });


  it("should work with display flex when child height is larger than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '10px',
        display: 'flex',
      }
    }, [
      createText('This text should be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
  });

  it("should work with display flex when child height is smaller than min-height", async () => {
    let containingBlock = createElement('div', {
      style: {
        border: '2px solid #000',
        minHeight: '50px',
        display: 'flex',
      }
    }, [
      createText('This text should not be wrapped')
    ]);
    BODY.appendChild(containingBlock);

    await snapshot();
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
              minHeight: '50px',
              'box-sizing': 'border-box',
            },
          },
        )
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot(0.1);
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
              minHeight: '200px',
              'box-sizing': 'border-box',
            },
          },
        )
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot(0.1);
  });

  it('should work with percentage in flow layout', async () => {
    let div;
    let foo;
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
                minHeight: '50%',
                width: '100px',
                backgroundColor: 'yellow',
            }
          }),
          createElement('div', {
            style: {
                minHeight: '50%',
                width: '100%',
                backgroundColor: 'blue',
            }
          }
         )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage in flex layout in row direction', async () => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          position: 'relative',
        },
      },
      [
          createElement('div', {
            style: {
                minHeight: '50%',
                width: '100px',
                backgroundColor: 'yellow',
            }
          }),
          createElement('div', {
            style: {
                minHeight: '50%',
                width: '100%',
                backgroundColor: 'blue',
            }
          }
         )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage in flex layout in column direction', async () => {
    let div;
    let foo;
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
                minHeight: '50%',
                width: '100px',
                backgroundColor: 'yellow',
            }
          }),
          createElement('div', {
            style: {
                minHeight: '50%',
                width: '100%',
                backgroundColor: 'blue',
            }
          }
         )
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

});
