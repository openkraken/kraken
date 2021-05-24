/*auto generated*/
describe('abspos-inline', () => {
  xit('001', async () => {
    let filler;
    let filler_1;
    let absolute;
    let fail;
    let test;
    let p;
    let p_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        (filler = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createText(` The test has `),
            (absolute = createElement(
              'span',
              {
                class: 'absolute',
                style: {
                  color: 'white',
                  background: 'green',
                  position: 'absolute',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`PASSED`)]
            )),
            (fail = createElement(
              'span',
              {
                class: 'fail',
                style: {
                  color: 'yellow',
                  background: 'red',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`FAILED`)]
            )),
            createText(`.`),
          ]
        )),
        (filler_1 = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
      ]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`(Exception: when the word FAILED is at the beginning of a
  line, the word PASSED may still be at the end of the previous
  line.)`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);

    await snapshot();
  });
  xit('002', async () => {
    let filler;
    let filler_1;
    let absolute;
    let fail;
    let test;
    let p;
    let p_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        (filler = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(` The test has `),
            (absolute = createElement(
              'span',
              {
                class: 'absolute',
                style: {
                  color: 'white',
                  background: 'green',
                  position: 'absolute',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`PASSED`)]
            )),
            (fail = createElement(
              'span',
              {
                class: 'fail',
                style: {
                  color: 'yellow',
                  background: 'red',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`FAILED`)]
            )),
            createText(`.`),
          ]
        )),
        (filler_1 = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
      ]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`(Exception: when the word FAILED is at the beginning of a
  line, the word PASSED may still be at the end of the previous
  line.)`),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);

    await snapshot();
  });
  xit('003', async () => {
    let filler;
    let filler_1;
    let absolute;
    let fail;
    let test;
    let p;
    let p_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        (filler = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
        createText(`
   The test has `),
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [
            (absolute = createElement(
              'span',
              {
                class: 'absolute',
                style: {
                  color: 'white',
                  background: 'green',
                  position: 'absolute',
                  top: '0',
                  left: '0',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`PASSED`)]
            )),
            (fail = createElement(
              'span',
              {
                class: 'fail',
                style: {
                  color: 'yellow',
                  background: 'red',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`FAILED`)]
            )),
          ]
        )),
        createText(`.
   `),
        (filler_1 = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
      ]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be no red after resizing viewport.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);

    await snapshot();
  });
  xit('004', async () => {
    let filler;
    let filler_1;
    let absolute;
    let fail;
    let test;
    let p;
    let p_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        (filler = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
        createText(`
   The test has `),
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [
            (absolute = createElement(
              'span',
              {
                class: 'absolute',
                style: {
                  color: 'white',
                  background: 'green',
                  position: 'absolute',
                  top: '0',
                  right: '0',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`PASSED`)]
            )),
            (fail = createElement(
              'span',
              {
                class: 'fail',
                style: {
                  color: 'yellow',
                  background: 'red',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`FAILED`)]
            )),
          ]
        )),
        createText(`.
   `),
        (filler_1 = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
      ]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be no red after resizing viewport.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);

    await snapshot();
  });
  xit('005', async () => {
    let filler;
    let filler_1;
    let absolute;
    let fail;
    let test;
    let p;
    let p_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        (filler = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
        createText(`
   The test has `),
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [
            (absolute = createElement(
              'span',
              {
                class: 'absolute',
                style: {
                  color: 'white',
                  background: 'green',
                  position: 'absolute',
                  bottom: '0',
                  left: '0',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`PASSED`)]
            )),
            (fail = createElement(
              'span',
              {
                class: 'fail',
                style: {
                  color: 'yellow',
                  background: 'red',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`FAILED`)]
            )),
          ]
        )),
        createText(`.
   `),
        (filler_1 = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
      ]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be no red after resizing viewport.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);

    await snapshot();
  });
  xit('006', async () => {
    let filler;
    let filler_1;
    let absolute;
    let fail;
    let test;
    let p;
    let p_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [
        (filler = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
        createText(`
   The test has `),
        (test = createElement(
          'span',
          {
            class: 'test',
            style: {
              position: 'relative',
              'box-sizing': 'border-box',
            },
          },
          [
            (absolute = createElement(
              'span',
              {
                class: 'absolute',
                style: {
                  color: 'white',
                  background: 'green',
                  position: 'absolute',
                  bottom: '0',
                  right: '0',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`PASSED`)]
            )),
            (fail = createElement(
              'span',
              {
                class: 'fail',
                style: {
                  color: 'yellow',
                  background: 'red',
                  'box-sizing': 'border-box',
                },
              },
              [createText(`FAILED`)]
            )),
          ]
        )),
        createText(`.
   `),
        (filler_1 = createElement(
          'span',
          {
            class: 'filler',
            style: {
              color: 'silver',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(
              ` This is filler text. This is filler text. This is filler text. `
            ),
          ]
        )),
      ]
    );
    p_1 = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          font: '10px monospace',
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be no red after resizing viewport.`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(p_1);

    await snapshot();
  });
  it('007-ref', async () => {
    let abspos;
    let abspos_1;
    let abspos_2;
    let parentBlock;
    let parentBlock_1;
    let parentBlock_2;
    let filler;
    let filler_1;
    let filler_2;
    let inlineContainer;
    let inlineContainer_1;
    let inlineContainer_2;
    let blockContainer;
    let p;
    blockContainer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'block-container',
        style: {
          font: '20px NaNpx',
          height: '20px',
          position: 'relative',
          top: '-1px',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
   x
    `),
        (inlineContainer = createElement(
          'div',
          {
            class: 'inline-container',
            style: {
              position: 'relative',
              border: '1px solid black',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
     tl
      `),
            (abspos = createElement('div', {
              class: 'abspos tl',
              style: {
                position: 'absolute',
                width: '10px',
                height: '10px',
                'background-color': 'green',
                display: 'inline-block',
                'vertical-align': 'baseline',
                top: '0',
                left: '0',
                'box-sizing': 'border-box',
              },
            })),
            (parentBlock = createElement('div', {
              class: 'parent-block',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
            (filler = createElement('div', {
              class: 'filler',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        createText(`x
    `),
        (inlineContainer_1 = createElement(
          'div',
          {
            class: 'inline-container',
            style: {
              position: 'relative',
              border: '1px solid black',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
     br
      `),
            (abspos_1 = createElement('div', {
              class: 'abspos br',
              style: {
                position: 'absolute',
                width: '10px',
                height: '10px',
                'background-color': 'green',
                display: 'inline-block',
                'vertical-align': 'baseline',
                right: '0',
                bottom: '0',
                'box-sizing': 'border-box',
              },
            })),
            (parentBlock_1 = createElement('div', {
              class: 'parent-block',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
            (filler_1 = createElement('div', {
              class: 'filler',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        createText(`x
    `),
        (inlineContainer_2 = createElement(
          'div',
          {
            class: 'inline-container',
            style: {
              position: 'relative',
              border: '1px solid black',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
      static
      `),
            (abspos_2 = createElement('div', {
              class: 'abspos',
              style: {
                position: 'static',
                width: '10px',
                height: '10px',
                'background-color': 'green',
                display: 'inline-block',
                'vertical-align': 'baseline',
                'box-sizing': 'border-box',
              },
            })),
            (parentBlock_2 = createElement('div', {
              class: 'parent-block',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
            (filler_2 = createElement('div', {
              class: 'filler',
              style: {
                display: 'inline-block',
                width: '20px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Tests abspos positioning of an Element that 1) has an inline containing
block, and 2) is not a child of the inline containing block, but a descendant.`),
      ]
    );
    BODY.appendChild(blockContainer);
    BODY.appendChild(p);

    await snapshot();
  });
  xit('007', async () => {
    let abspos;
    let abspos_1;
    let abspos_2;
    let parentBlock;
    let parentBlock_1;
    let parentBlock_2;
    let filler;
    let filler_1;
    let filler_2;
    let inlineContainer;
    let inlineContainer_1;
    let inlineContainer_2;
    let blockContainer;
    let p;
    blockContainer = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'block-container',
        style: {
          position: 'relative',
          font: '20px NaNpx',
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
   x
    `),
        (inlineContainer = createElement(
          'span',
          {
            class: 'inline-container',
            style: {
              position: 'relative',
              border: '1px solid black',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
     tl
      `),
            (parentBlock = createElement(
              'div',
              {
                class: 'parent-block',
                style: {
                  display: 'inline-block',
                  width: '30px',
                  height: '10px',
                  'box-sizing': 'border-box',
                },
              },
              [
                (abspos = createElement('div', {
                  class: 'abspos tl',
                  style: {
                    position: 'absolute',
                    width: '10px',
                    height: '10px',
                    'background-color': 'green',
                    top: '0',
                    left: '0',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            )),
            (filler = createElement('div', {
              class: 'filler',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        createText(`
    x
    `),
        (inlineContainer_1 = createElement(
          'span',
          {
            class: 'inline-container',
            style: {
              position: 'relative',
              border: '1px solid black',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
     br
      `),
            (parentBlock_1 = createElement(
              'div',
              {
                class: 'parent-block',
                style: {
                  display: 'inline-block',
                  width: '30px',
                  height: '10px',
                  'box-sizing': 'border-box',
                },
              },
              [
                (abspos_1 = createElement('div', {
                  class: 'abspos br',
                  style: {
                    position: 'absolute',
                    width: '10px',
                    height: '10px',
                    'background-color': 'green',
                    right: '0',
                    bottom: '0',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            )),
            (filler_1 = createElement('div', {
              class: 'filler',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
        createText(`
    x
    `),
        (inlineContainer_2 = createElement(
          'span',
          {
            class: 'inline-container',
            style: {
              position: 'relative',
              border: '1px solid black',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
      static
      `),
            (parentBlock_2 = createElement(
              'div',
              {
                class: 'parent-block',
                style: {
                  display: 'inline-block',
                  width: '30px',
                  height: '10px',
                  'box-sizing': 'border-box',
                },
              },
              [
                (abspos_2 = createElement('div', {
                  class: 'abspos',
                  style: {
                    position: 'absolute',
                    width: '10px',
                    height: '10px',
                    'background-color': 'green',
                    'box-sizing': 'border-box',
                  },
                })),
              ]
            )),
            (filler_2 = createElement('div', {
              class: 'filler',
              style: {
                display: 'inline-block',
                width: '30px',
                height: '10px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Tests abspos positioning of an Element that 1) has an inline containing
block, and 2) is not a child of the inline containing block, but a descendant.`),
      ]
    );
    BODY.appendChild(blockContainer);
    BODY.appendChild(p);

    await snapshot();
  });
  it('008', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
          position: 'relative',
          left: '100px',
          width: '100px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
              position: 'relative',
              left: '-100px',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                position: 'absolute',
                display: 'inline-block',
                width: '100px',
                height: '100px',
                background: 'green',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
