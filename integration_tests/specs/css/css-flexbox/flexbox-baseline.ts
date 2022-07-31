/*auto generated*/
describe('flexbox-baseline', () => {
  it('baseline', async () => {
    let inlineFlexbox;
    let inlineFlexbox_1;
    let inlineFlexbox_2;
    let inlineFlexbox_3;
    let inlineFlexbox_4;
    let inlineFlexbox_5;
    let inlineFlexbox_6;
    let inlineFlexbox_7;
    let inlineFlexbox_8;
    let inlineFlexbox_9;
    let inlineFlexbox_10;
    let inlineFlexbox_11;
    let inlineFlexbox_12;
    let div;
    let div_1;
    let div_2;
    let div_3;
    let div_4;
    let div_5;
    let div_6;
    let div_7;
    let div_8;
    let div_9;
    let div_10;
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
    let flexitemWithScrollbar;
    let flexboxWithScrollbar;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
before text
`),
        (inlineFlexbox = createElement(
          'div',
          {
            class: 'inline-flexbox',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'box-sizing': 'border-box',
              height: '50px',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  'align-self': 'flex-end',
                },
              },
              [createText(`below`)]
            ),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  'align-self': 'baseline',
                  'margin-top': '15px',
                },
              },
              [createText(`baseline`)]
            ),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  'align-self': 'flex-start',
                },
              },
              [createText(`above`)]
            ),
          ]
        )),
        createText(`
after text
`),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
before text
`),
        (inlineFlexbox_1 = createElement(
          'div',
          {
            class: 'inline-flexbox',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'box-sizing': 'border-box',
              height: '40px',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  'align-self': 'flex-end',
                },
              },
              [createText(`baseline`)]
            ),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                'align-self': 'baseline',
                'writing-mode': 'vertical-rl',
              },
            }),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  'align-self': 'flex-start',
                },
              },
              [createText(`above`)]
            ),
          ]
        )),
        createText(`
after text
`),
      ]
    );
    div_2 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
before text
`),
        (inlineFlexbox_2 = createElement(
          'div',
          {
            class: 'inline-flexbox',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'h2',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`h2 baseline`)]
            ),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`above`)]
            ),
          ]
        )),
        createText(`
after text
`),
      ]
    );
    div_3 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
before text
`),
        (inlineFlexbox_3 = createElement(
          'div',
          {
            class: 'inline-flexbox',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`baseline`)]
            ),
            createElement(
              'h2',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`h2 below`)]
            ),
          ]
        )),
        createText(`
after text
`),
      ]
    );
    div_4 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
should align with the middle
`),
        (inlineFlexbox_4 = createElement(
          'div',
          {
            class: 'inline-flexbox',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'box-sizing': 'border-box',
              width: '40px',
              height: '40px',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                'writing-mode': 'vertical-rl',
                height: '20px',
                width: '40px',
                'border-bottom': '1px solid black',
              },
            }),
          ]
        )),
        createText(`
of the grey flexbox
`),
      ]
    );
    div_5 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
should align with the bottom
`),
        (inlineFlexbox_5 = createElement('div', {
          class: 'inline-flexbox',
          style: {
            display: 'inline-flex',
            'background-color': 'lightgrey',
            'margin-top': '5px',
            'box-sizing': 'border-box',
            width: '30px',
            height: '30px',
          },
        })),
        createText(`
of the grey flexbox
`),
      ]
    );
    div_6 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
before text
`),
        (inlineFlexbox_6 = createElement(
          'div',
          {
            class: 'inline-flexbox column',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'flex-flow': 'column',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`baseline`)]
            ),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`below`)]
            ),
          ]
        )),
        createText(`
after text
`),
      ]
    );
    div_7 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
before text
`),
        (inlineFlexbox_7 = createElement(
          'div',
          {
            class: 'inline-flexbox column-reverse',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'flex-flow': 'column-reverse',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`baseline`)]
            ),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText(`above`)]
            ),
          ]
        )),
        createText(`
after text
`),
      ]
    );
    div_8 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
should align with the middle
`),
        (inlineFlexbox_8 = createElement(
          'div',
          {
            class: 'inline-flexbox column',
            style: {
              display: 'inline-flex',
              'background-color': 'lightgrey',
              'margin-top': '5px',
              'flex-flow': 'column',
              'box-sizing': 'border-box',
              width: '40px',
              height: '40px',
            },
          },
          [
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                'writing-mode': 'vertical-rl',
                width: '40px',
                height: '20px',
                'border-bottom': '1px solid black',
              },
            }),
            createElement('div', {
              style: {
                'box-sizing': 'border-box',
                'writing-mode': 'vertical-rl',
                width: '40px',
                height: '20px',
              },
            }),
          ]
        )),
        createText(`
of the grey flexbox
`),
      ]
    );
    div_9 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
should align with the bottom
`),
        (inlineFlexbox_9 = createElement('div', {
          class: 'inline-flexbox column',
          style: {
            display: 'inline-flex',
            'background-color': 'lightgrey',
            'margin-top': '5px',
            'flex-flow': 'column',
            'box-sizing': 'border-box',
            width: '30px',
            height: '30px',
          },
        })),
        createText(`
of the grey flexbox
`),
      ]
    );
    div_10 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'absolute',
          top: '0',
          left: '400px',
          width: '360px',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
before text
`),
            (inlineFlexbox_10 = createElement(
              'div',
              {
                class: 'inline-flexbox',
                style: {
                  display: 'inline-flex',
                  'background-color': 'lightgrey',
                  'margin-top': '5px',
                  'box-sizing': 'border-box',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      position: 'absolute',
                    },
                  },
                  [createText(`absolute`)]
                ),
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      'margin-top': '30px',
                    },
                  },
                  [createText(`baseline`)]
                ),
              ]
            )),
            createText(`
after text
`),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
before text
`),
            (inlineFlexbox_11 = createElement(
              'div',
              {
                class: 'inline-flexbox',
                style: {
                  display: 'inline-flex',
                  'background-color': 'lightgrey',
                  'margin-top': '5px',
                  'box-sizing': 'border-box',
                  height: '40px',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText(`baseline`)]
                ),
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      'align-self': 'baseline',
                      'margin-top': 'auto',
                    },
                  },
                  [createText(`below`)]
                ),
              ]
            )),
            createText(`
after text
`),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
before text
`),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  display: 'inline-block',
                },
              },
              [
                (inlineFlexbox_12 = createElement(
                  'div',
                  {
                    class: 'inline-flexbox',
                    style: {
                      display: 'inline-flex',
                      'background-color': 'lightgrey',
                      'margin-top': '5px',
                      'box-sizing': 'border-box',
                      height: '40px',
                    },
                  },
                  [
                    createElement(
                      'div',
                      {
                        style: {
                          'box-sizing': 'border-box',
                        },
                      },
                      [createText(`above`)]
                    ),
                    createElement(
                      'div',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'align-self': 'baseline',
                          'margin-top': '10px',
                        },
                      },
                      [createText(`baseline`)]
                    ),
                    createElement(
                      'div',
                      {
                        style: {
                          'box-sizing': 'border-box',
                        },
                      },
                      [createText(`above`)]
                    ),
                  ]
                )),
                createText(`
after
`),
              ]
            ),
            createText(`
text
`),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
before text
`),
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  display: 'inline-block',
                },
              },
              [
                (flexbox = createElement(
                  'div',
                  {
                    class: 'flexbox',
                    style: {
                      display: 'flex',
                      'background-color': 'grey',
                      'margin-top': '10px',
                      'box-sizing': 'border-box',
                      height: '30px',
                    },
                  },
                  [
                    createText(`
  baseline
`),
                  ]
                )),
              ]
            ),
            createText(`
after text
`),
          ]
        ),
        createElement(
          'table',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'lightgrey',
              'margin-top': '5px',
            },
          },
          [
            createElement(
              'tbody',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [
                createElement(
                  'tr',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      height: '50px',
                    },
                  },
                  [
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'bottom',
                        },
                      },
                      [createText(`bottom`)]
                    ),
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'baseline',
                        },
                      },
                      [createText(`baseline`)]
                    ),
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'top',
                        },
                      },
                      [createText(`top`)]
                    ),
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'baseline',
                        },
                      },
                      [
                        (flexbox_1 = createElement(
                          'div',
                          {
                            class: 'flexbox column',
                            style: {
                              display: 'flex',
                              'background-color': 'grey',
                              'margin-top': '10px',
                              'flex-flow': 'column',
                              'box-sizing': 'border-box',
                            },
                          },
                          [
                            createElement(
                              'div',
                              {
                                style: {
                                  'box-sizing': 'border-box',
                                },
                              },
                              [createText(`baseline`)]
                            ),
                            createElement(
                              'div',
                              {
                                style: {
                                  'box-sizing': 'border-box',
                                },
                              },
                              [createText(`below`)]
                            ),
                          ]
                        )),
                      ]
                    ),
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'baseline',
                        },
                      },
                      [
                        (flexbox_2 = createElement(
                          'div',
                          {
                            class: 'flexbox column-reverse',
                            style: {
                              display: 'flex',
                              'background-color': 'grey',
                              'margin-top': '10px',
                              'flex-flow': 'column-reverse',
                              'box-sizing': 'border-box',
                            },
                          },
                          [
                            createElement(
                              'div',
                              {
                                style: {
                                  'box-sizing': 'border-box',
                                },
                              },
                              [createText(`baseline`)]
                            ),
                            createElement(
                              'div',
                              {
                                style: {
                                  'box-sizing': 'border-box',
                                },
                              },
                              [createText(`above`)]
                            ),
                          ]
                        )),
                      ]
                    ),
                  ]
                ),
              ]
            ),
          ]
        ),
        createElement(
          'table',
          {
            style: {
              'box-sizing': 'border-box',
              'background-color': 'lightgrey',
              'margin-top': '5px',
            },
          },
          [
            createElement(
              'tbody',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [
                createElement(
                  'tr',
                  {
                    style: {
                      'box-sizing': 'border-box',
                      height: '50px',
                    },
                  },
                  [
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'bottom',
                        },
                      },
                      [createText(`bottom`)]
                    ),
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'baseline',
                        },
                      },
                      [createText(`baseline`)]
                    ),
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'top',
                        },
                      },
                      [createText(`top`)]
                    ),
                    createElement(
                      'td',
                      {
                        style: {
                          'box-sizing': 'border-box',
                          'vertical-align': 'baseline',
                        },
                      },
                      [
                        (flexbox_3 = createElement(
                          'div',
                          {
                            class: 'flexbox',
                            style: {
                              display: 'flex',
                              'background-color': 'grey',
                              'margin-top': '10px',
                              'box-sizing': 'border-box',
                            },
                          },
                          [
                            createElement(
                              'h2',
                              {
                                style: {
                                  'box-sizing': 'border-box',
                                },
                              },
                              [createText(`h2 baseline`)]
                            ),
                            createElement(
                              'div',
                              {
                                style: {
                                  'box-sizing': 'border-box',
                                },
                              },
                              [createText(`above`)]
                            ),
                          ]
                        )),
                      ]
                    ),
                  ]
                ),
              ]
            ),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
before text
`),
            (flexboxWithScrollbar = createElement(
              'div',
              {
                id: 'flexbox-with-scrollbar',
                class: 'inline-flexbox',
                style: {
                  display: 'inline-flex',
                  'background-color': 'lightgrey',
                  'margin-top': '5px',
                  'box-sizing': 'border-box',
                  height: '65px',
                  width: 'auto',
                },
              },
              [
                (flexitemWithScrollbar = createElement(
                  'div',
                  {
                    id: 'flexitem-with-scrollbar',
                    style: {
                      'box-sizing': 'border-box',
                      'align-self': 'baseline',
                      'padding-top': '15px',
                      height: '50px',
                      'overflow-y': 'scroll',
                    },
                  },
                  [
                    createText(`
        The baseline is based on`),
                    createElement('br', {
                      style: {
                        'box-sizing': 'border-box',
                      },
                    }),
                    createText(`
        the non-scrolled position;`),
                    createElement('br', {
                      style: {
                        'box-sizing': 'border-box',
                      },
                    }),
                    createText(`
        this won't line up.
    `),
                  ]
                )),
              ]
            )),
            createText(`
after text
`),
          ]
        ),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(div_2);
    BODY.appendChild(div_3);
    BODY.appendChild(div_4);
    BODY.appendChild(div_5);
    BODY.appendChild(div_6);
    BODY.appendChild(div_7);
    BODY.appendChild(div_8);
    BODY.appendChild(div_9);
    BODY.appendChild(div_10);

    document.getElementById('flexitem-with-scrollbar').scrollTop = 999;
    document.getElementById('flexbox-with-scrollbar').style.width = 'auto';

    await matchViewportSnapshot();
  });
  it('margins', async () => {
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
    let flexbox_4;
    let flexbox_5;
    let flexbox_6;
    let border;
    let div;
    let div_1;
    let div_2;
    let div_3;
    let div_4;
    let div_5;
    let flexOne;
    let flexOne_1;
    let flexOne_2;
    let flexOne_3;
    let inlineBlock;
    let inlineBlock_1;
    let inlineBlock_2;
    let inlineBlock_3;
    let inlineBlock_4;
    let inlineBlock_5;
    let inlineFlexbox;
    let inlineFlexbox_1;
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
before text
`),
        (border = createElement(
          'div',
          {
            class: 'border',
            style: {
              border: '11px solid pink',
              'box-sizing': 'border-box',
              display: 'inline-block',
              'background-color': 'lightgrey',
            },
          },
          [
            (flexbox = createElement(
              'div',
              {
                class: 'flexbox',
                style: {
                  display: 'flex',
                  'background-color': 'lightgrey',
                  'box-sizing': 'border-box',
                  height: '30px',
                  'margin-top': '7px',
                  'padding-top': '10px',
                },
              },
              [
                createText(`
  baseline
`),
              ]
            )),
          ]
        )),
        createText(`
after text
`),
      ]
    );
    div_1 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
Should align
`),
        (inlineBlock = createElement(
          'div',
          {
            class: 'inline-block border',
            style: {
              display: 'inline-block',
              border: '11px solid pink',
              'box-sizing': 'border-box',
            },
          },
          [
            (flexbox_1 = createElement(
              'div',
              {
                class: 'flexbox padding',
                style: {
                  display: 'flex',
                  'background-color': 'pink',
                  padding: '13px',
                  'box-sizing': 'border-box',
                  width: '50px',
                  height: '50px',
                },
              },
              [
                (flexOne = createElement('div', {
                  class: 'flex-one',
                  style: {
                    '-webkit-flex': '1',
                    flex: '1',
                    'min-width': '0',
                    'min-height': '0',
                    'box-sizing': 'border-box',
                    'background-color': 'lightgrey',
                  },
                })),
              ]
            )),
          ]
        )),
        createText(`
with the
`),
        (inlineBlock_1 = createElement(
          'div',
          {
            class: 'inline-block margin',
            style: {
              display: 'inline-block',
              margin: '8px 0',
              'box-sizing': 'border-box',
            },
          },
          [
            (flexbox_2 = createElement(
              'div',
              {
                class: 'flexbox border',
                style: {
                  display: 'flex',
                  'background-color': 'pink',
                  border: '11px solid pink',
                  'box-sizing': 'border-box',
                  width: '50px',
                  height: '50px',
                },
              },
              [
                (flexOne_1 = createElement('div', {
                  class: 'flex-one',
                  style: {
                    '-webkit-flex': '1',
                    flex: '1',
                    'min-width': '0',
                    'min-height': '0',
                    'box-sizing': 'border-box',
                    'background-color': 'lightgrey',
                  },
                })),
              ]
            )),
          ]
        )),
        createText(`
bottom of
`),
        (inlineBlock_2 = createElement(
          'div',
          {
            class: 'inline-block padding',
            style: {
              display: 'inline-block',
              padding: '13px',
              'box-sizing': 'border-box',
              'padding-left': '0',
              'padding-right': '0',
            },
          },
          [
            (flexbox_3 = createElement(
              'div',
              {
                class: 'flexbox margin border',
                style: {
                  display: 'flex',
                  'background-color': 'pink',
                  border: '11px solid pink',
                  margin: '8px 0',
                  'box-sizing': 'border-box',
                  width: '50px',
                  height: '50px',
                },
              },
              [
                (flexOne_2 = createElement('div', {
                  class: 'flex-one',
                  style: {
                    '-webkit-flex': '1',
                    flex: '1',
                    'min-width': '0',
                    'min-height': '0',
                    'box-sizing': 'border-box',
                    'background-color': 'lightgrey',
                  },
                })),
              ]
            )),
          ]
        )),
        createText(`
the grey box.
`),
      ]
    );
    div_2 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
Should align with the
`),
        (inlineBlock_3 = createElement(
          'div',
          {
            class: 'inline-block',
            style: {
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [
            (flexbox_4 = createElement(
              'div',
              {
                class: 'flexbox',
                style: {
                  display: 'flex',
                  'background-color': 'white',
                  'box-sizing': 'border-box',
                },
              },
              [
                (flexOne_3 = createElement('div', {
                  class: 'flex-one border padding margin',
                  style: {
                    '-webkit-flex': '1',
                    flex: '1',
                    border: '11px solid pink',
                    padding: '13px',
                    margin: '8px 0',
                    'min-width': '0',
                    'min-height': '0',
                    'box-sizing': 'border-box',
                    'background-color': 'lightgrey',
                  },
                })),
              ]
            )),
          ]
        )),
        createText(`
bottom of the pink box.
`),
      ]
    );
    div_3 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
Should align 8px
`),
        (inlineFlexbox = createElement('div', {
          class: 'inline-flexbox margin border',
          style: {
            display: 'inline-flex',
            'background-color': 'lightgrey',
            border: '11px solid pink',
            margin: '8px 0',
            'box-sizing': 'border-box',
            width: '30px',
            height: '30px',
          },
        })),
        createText(`
below the bottom
`),
        (inlineFlexbox_1 = createElement('div', {
          class: 'inline-flexbox margin border padding',
          style: {
            display: 'inline-flex',
            'background-color': 'lightgrey',
            border: '11px solid pink',
            padding: '13px',
            margin: '8px 0',
            'box-sizing': 'border-box',
          },
        })),
        createText(`
of the pink box.
`),
      ]
    );
    div_4 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
Should align with the bottom
`),
        (inlineBlock_4 = createElement(
          'div',
          {
            class: 'inline-block border margin padding',
            style: {
              display: 'inline-block',
              border: '11px solid pink',
              padding: '13px',
              margin: '8px 0',
              'box-sizing': 'border-box',
              'background-color': 'pink',
            },
          },
          [
            (flexbox_5 = createElement(
              'div',
              {
                class: 'flexbox border margin padding',
                style: {
                  display: 'flex',
                  'background-color': 'pink',
                  border: '11px solid pink',
                  padding: '13px',
                  margin: '8px 0',
                  'box-sizing': 'border-box',
                  width: '50px',
                  height: '50px',
                },
              },
              [
                createElement('div', {
                  style: {
                    'min-width': '0',
                    'min-height': '0',
                    'box-sizing': 'border-box',
                    width: '200px',
                    overflow: 'scroll',
                    'background-color': 'lightgrey',
                    'margin-top': '4px',
                    'border-top': '9px solid pink',
                  },
                }),
              ]
            )),
          ]
        )),
        createText(`
of the horizontal scrollbar.
`),
      ]
    );
    div_5 = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`
Should align 10px below the
`),
        (inlineBlock_5 = createElement(
          'div',
          {
            class: 'inline-block',
            style: {
              display: 'inline-block',
              'box-sizing': 'border-box',
              'background-color': 'pink',
            },
          },
          [
            (flexbox_6 = createElement(
              'div',
              {
                class: 'flexbox',
                style: {
                  display: 'flex',
                  'background-color': 'pink',
                  'box-sizing': 'border-box',
                  width: '50px',
                  height: '50px',
                },
              },
              [
                createElement('div', {
                  style: {
                    'min-width': '0',
                    'min-height': '0',
                    'box-sizing': 'border-box',
                    width: '200px',
                    overflow: 'scroll',
                    'background-color': 'lightgrey',
                    'padding-bottom': '10px',
                    'border-bottom': '10px solid pink',
                  },
                }),
              ]
            )),
          ]
        )),
        createText(`
of the horizontal scrollbar, if one is visible.
`),
      ]
    );
    BODY.appendChild(div);
    BODY.appendChild(div_1);
    BODY.appendChild(div_2);
    BODY.appendChild(div_3);
    BODY.appendChild(div_4);
    BODY.appendChild(div_5);

    await matchViewportSnapshot();
  });
});
