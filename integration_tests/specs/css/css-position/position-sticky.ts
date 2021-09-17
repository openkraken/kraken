describe('position-sticky', () => {
  it('bottom', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  background: 'yellow',
                })),
                (sticky = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  bottom: '25px',
                  position: 'sticky',
                  height: '100px',
                  width: '100px',
                  'background-color': 'green',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();
  });

  it('change-top-ref', async () => {
    let box;
    let spacer;
    box = createElementWithStyle('div', {
      'backface-visibility': 'hidden',
      'background-color': 'green',
      position: 'sticky',
      top: '200px',
      width: '100px',
      height: '100px',
      'box-sizing': 'border-box',
    });
    spacer = createElementWithStyle('div', {
      height: '200vh',
      'background-image':
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/ruler-v-50px.png)',
      'background-repeat': 'repeat',
      'box-sizing': 'border-box',
    });
    BODY.appendChild(box);
    BODY.appendChild(spacer);

    await snapshot(0.4);
  });
  it('change-top', async () => {
    let marker;
    let sticky;
    let spacer;
    marker = createElementWithStyle('div', {
      'background-color': 'red',
      position: 'absolute',
      top: '200px',
      height: '100px',
      width: '100px',
      'box-sizing': 'border-box',
    });
    sticky = createElementWithStyle('div', {
      'backface-visibility': 'hidden',
      'background-color': 'green',
      position: 'sticky',
      top: '0',
      width: '100px',
      height: '100px',
      'box-sizing': 'border-box',
    });
    spacer = createElementWithStyle('div', {
      height: '200vh',
      'background-image':
        'url(assets/ruler-v-50px.png)',
      'background-repeat': 'repeat',
      'box-sizing': 'border-box',
    });
    BODY.appendChild(marker);
    BODY.appendChild(sticky);
    BODY.appendChild(spacer);

    await snapshot(0.1);
  });
  it('child-multicolumn-ref', async () => {
    let contents;
    let child;
    let relative;
    let spacer;
    let scroller: any;
    let div;
    scroller = createElementWithStyle(
      'div',
      {
        'overflow-y': 'scroll',
        width: '200px',
        height: '200px',
        'background-image':
          'url(assets/ruler-v-50px.png)',
        'background-repeat': 'repeat',
        'box-sizing': 'border-box',
      },
      [
        (relative = createElementWithStyle(
          'div',
          {
            position: 'relative',
            top: '100px',
            margin: '10px',
            'box-sizing': 'border-box',
          },
          [
            (child = createElementWithStyle(
              'div',
              {
                width: '100px',
                height: '100px',
                'background-color': 'green',
                'box-sizing': 'border-box',
              },
              [
                (contents = createElementWithStyle('div', {
                  position: 'relative',
                  top: '10px',
                  left: '10px',
                  width: '80px',
                  height: '80px',
                  'background-color': 'lightgreen',
                  'box-sizing': 'border-box',
                })),
              ]
            )),
          ]
        )),
        (spacer = createElementWithStyle('div', {
          height: '400px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    div = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [
        createText(
          `You should see a light green box above with a dark green border.`
        ),
      ]
    );
    BODY.appendChild(scroller);
    BODY.appendChild(div);

    window.addEventListener('load', function () {
      scroller.scrollTop = 100;
    });

    // wait for image load
    await sleep(1);

    await snapshot();
  });
  it('child-multicolumn', async () => {
    let contents;
    let multicolumn;
    let sticky;
    let spacer;
    let scroller: any;
    let div;
    scroller = createElementWithStyle(
      'div',
      {
        'overflow-y': 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = createElementWithStyle(
          'div',
          {
            position: 'sticky',
            top: '10px',
            margin: '10px',
            'background-color': 'red',
            'box-sizing': 'border-box',
          },
          [
            (multicolumn = createElementWithStyle(
              'div',
              {
                width: '100px',
                height: '100px',
                'background-color': 'green',
                padding: '10px',
                'box-sizing': 'border-box',
              },
              [
                (contents = createElementWithStyle('div', {
                  width: '80px',
                  height: '80px',
                  'background-color': 'lightgreen',
                  'box-sizing': 'border-box',
                })),
              ]
            )),
          ]
        )),
        (spacer = createElementWithStyle('div', {
          height: '400px',
          'background-image':
            'url(assets/ruler-v-50px.png)',
          'background-repeat': 'repeat',
          'box-sizing': 'border-box',
        })),
      ]
    );
    div = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [
        createText(
          `You should see a light green box above with a dark green border.`
        ),
      ]
    );
    BODY.appendChild(scroller);
    BODY.appendChild(div);

    window.addEventListener('load', function () {
      scroller.scrollTop = 100;
    });

    await snapshot(0.1);
  });
  it('flexbox-ref', async () => {
    let flexItem;
    let flexItem_1;
    let flexItem_2;
    let flexItem_3;
    let flexItem_4;
    let green;
    let green_1;
    let green_2;
    let green_3;
    let green_4;
    let flexContainer;
    let flexContainer_1;
    let flexContainer_2;
    let scroller1;
    let scroller2;
    let scroller3;
    let p;
    scroller1 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer = createElementWithStyle(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (flexItem = createElementWithStyle('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green = createElementWithStyle('div', {
              'background-color': 'green',
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_1 = createElementWithStyle('div', {
              'background-color': 'green',
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
          ]
        )),
      ]
    );
    scroller2 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_1 = createElementWithStyle(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (flexItem_1 = createElementWithStyle('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (flexItem_2 = createElementWithStyle('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_2 = createElementWithStyle('div', {
              'background-color': 'green',
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
          ]
        )),
      ]
    );
    scroller3 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_2 = createElementWithStyle(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (flexItem_3 = createElementWithStyle('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (flexItem_4 = createElementWithStyle('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_3 = createElementWithStyle('div', {
              'background-color': 'green',
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_4 = createElementWithStyle('div', {
              'background-color': 'green',
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
          ]
        )),
      ]
    );
    p = createElementWithStyle(
      'p',
      {
        'box-sizing': 'border-box',
      },
      [
        createText(
          `You should see three green boxes of varying size above. There should be no red.`
        ),
      ]
    );
    BODY.appendChild(scroller1);
    BODY.appendChild(scroller2);
    BODY.appendChild(scroller3);
    BODY.appendChild(p);
    await snapshot();
  });
  it('flexbox', async () => {
    let indicator;
    let indicator_1;
    let indicator_2;
    let flexItem;
    let flexItem_1;
    let flexItem_2;
    let sticky;
    let sticky_1;
    let sticky_2;
    let green;
    let green_1;
    let green_2;
    let flexContainer;
    let flexContainer_1;
    let flexContainer_2;
    let scroller1;
    let scroller2;
    let scroller3;
    scroller1 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer = createElementWithStyle(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (indicator = createElementWithStyle('div', {
              position: 'absolute',
              'background-color': 'red',
              width: '100px',
              height: '85px',
              'box-sizing': 'border-box',
              left: '100px',
            })),
            (flexItem = createElementWithStyle('div', {
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (sticky = createElementWithStyle('div', {
              position: 'sticky',
              left: '50px',
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green = createElementWithStyle('div', {
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
          ]
        )),
      ]
    );
    scroller2 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_1 = createElementWithStyle(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (indicator_1 = createElementWithStyle('div', {
              position: 'absolute',
              'background-color': 'red',
              width: '100px',
              height: '85px',
              'box-sizing': 'border-box',
              left: '200px',
            })),
            (flexItem_1 = createElementWithStyle('div', {
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (sticky_1 = createElementWithStyle('div', {
              position: 'sticky',
              left: '50px',
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_1 = createElementWithStyle('div', {
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
          ]
        )),
      ]
    );
    scroller3 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_2 = createElementWithStyle(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (indicator_2 = createElementWithStyle('div', {
              position: 'absolute',
              'background-color': 'red',
              width: '100px',
              height: '85px',
              'box-sizing': 'border-box',
              left: '300px',
            })),
            (flexItem_2 = createElementWithStyle('div', {
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (sticky_2 = createElementWithStyle('div', {
              position: 'sticky',
              left: '50px',
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_2 = createElementWithStyle('div', {
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller1);
    BODY.appendChild(scroller2);
    BODY.appendChild(scroller3);

    await snapshot();
  });
  it('get-bounding-client-rect', async () => {
    let sticky1;
    let spacer;
    let spacer_1;
    let spacer_2;
    let scroller1;
    let sticky2;
    let scroller2;
    let sticky3;
    let scroller3;
    scroller1 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky1 = createElementWithStyle('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer = createElementWithStyle('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroller2 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky2 = createElementWithStyle('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer_1 = createElementWithStyle('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroller3 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky3 = createElementWithStyle('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer_2 = createElementWithStyle('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroller1);
    BODY.appendChild(scroller2);
    BODY.appendChild(scroller3);

    await snapshot();
  });
  it('inflow-position', async () => {
    let before;
    let sticky;
    let after;
    let padding;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        position: 'relative',
        height: '200px',
        width: '100px',
        overflow: 'scroll',
        'box-sizing': 'border-box',
      },
      [
        (before = createElementWithStyle('div', {
          'background-color': 'fuchsia',
          height: '50px',
          width: '50px',
          'box-sizing': 'border-box',
        })),
        (sticky = createElementWithStyle('div', {
          'background-color': 'green',
          position: 'sticky',
          top: '150px',
          height: '50px',
          width: '50px',
          'box-sizing': 'border-box',
        })),
        (after = createElementWithStyle('div', {
          'background-color': 'orange',
          height: '50px',
          width: '50px',
          'box-sizing': 'border-box',
        })),
        (padding = createElementWithStyle('div', {
          height: '500px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroller);


    await snapshot();
  });
  it('inline-ref', async () => {
    let indicator;
    let indicator_1;
    let indicator_2;
    let contents;
    let contents_1;
    let contents_2;
    let scroller1;
    let group;
    let group_1;
    let group_2;
    let scroller2;
    let scroller3;
    group = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (contents = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (indicator = createElementWithStyle(
                  'div',
                  {
                    position: 'absolute',
                    left: '0',
                    color: 'green',
                    display: 'inline',
                    'box-sizing': 'border-box',
                    top: '50px',
                  },
                  [createText(`XXX`)]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_1 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (contents_1 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (indicator_1 = createElementWithStyle(
                  'div',
                  {
                    position: 'absolute',
                    left: '0',
                    color: 'green',
                    display: 'inline',
                    'box-sizing': 'border-box',
                    top: '75px',
                  },
                  [createText(`XXX`)]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_2 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (contents_2 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (indicator_2 = createElementWithStyle(
                  'div',
                  {
                    position: 'absolute',
                    left: '0',
                    color: 'green',
                    display: 'inline',
                    'box-sizing': 'border-box',
                    top: '100px',
                  },
                  [createText(`XXX`)]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(group);
    BODY.appendChild(group_1);
    BODY.appendChild(group_2);

    await snapshot();
  });
  it('inline', async () => {
    let indicator;
    let indicator_1;
    let indicator_2;
    let prepadding;
    let prepadding_1;
    let prepadding_2;
    let innerpadding;
    let innerpadding_1;
    let innerpadding_2;
    let sticky;
    let sticky_1;
    let sticky_2;
    let container;
    let container_1;
    let container_2;
    let contents;
    let contents_1;
    let contents_2;
    let scroller1;
    let group;
    let group_1;
    let group_2;
    let scroller2;
    let scroller3;
    group = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px',
            'box-sizing': 'border-box',
          },
          [
            (indicator = createElementWithStyle(
              'div',
              {
                position: 'absolute',
                left: '0',
                color: 'red',
                display: 'inline',
                'box-sizing': 'border-box',
                top: '550px',
              },
              [createText(`XXX`)]
            )),
            (contents = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding = createElementWithStyle('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container = createElementWithStyle(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding = createElementWithStyle('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (sticky = createElementWithStyle(
                      'div',
                      {
                        position: 'sticky',
                        top: '50px',
                        color: 'green',
                        display: 'inline',
                        'box-sizing': 'border-box',
                      },
                      [createText(`XXX`)]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_1 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px',
            'box-sizing': 'border-box',
          },
          [
            (indicator_1 = createElementWithStyle(
              'div',
              {
                position: 'absolute',
                left: '0',
                color: 'red',
                display: 'inline',
                'box-sizing': 'border-box',
                top: '75px',
              },
              [createText(`XXX`)]
            )),
            (contents_1 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_1 = createElementWithStyle('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_1 = createElementWithStyle(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_1 = createElementWithStyle('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (sticky_1 = createElementWithStyle(
                      'div',
                      {
                        position: 'sticky',
                        top: '50px',
                        color: 'green',
                        display: 'inline',
                        'box-sizing': 'border-box',
                      },
                      [createText(`XXX`)]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_2 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px',
            'box-sizing': 'border-box',
          },
          [
            (indicator_2 = createElementWithStyle(
              'div',
              {
                position: 'absolute',
                left: '0',
                color: 'red',
                display: 'inline',
                'box-sizing': 'border-box',
                top: '100px',
              },
              [createText(`XXX`)]
            )),
            (contents_2 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_2 = createElementWithStyle('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_2 = createElementWithStyle(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_2 = createElementWithStyle('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (sticky_2 = createElementWithStyle(
                      'div',
                      {
                        position: 'sticky',
                        top: '50px',
                        color: 'green',
                        display: 'inline',
                        'box-sizing': 'border-box',
                      },
                      [createText(`XXX`)]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(group);
    BODY.appendChild(group_1);
    BODY.appendChild(group_2);

    await snapshot();
  });
  it('large-top-2-ref', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2;
    scroll = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        padding: '5px 3px 0 8px',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        transform: 'scale(1)',
        'box-sizing': 'border-box',
      },
      [
        createElementWithStyle(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky = createElementWithStyle('div', {
              position: 'absolute',
              'background-color': 'purple',
              width: '50px',
              height: '50px',
              top: '205px',
              'z-index': '1',
              'box-sizing': 'border-box',
            })),
          ]
        ),
        (block = createElementWithStyle('div', {
          width: '150px',
          height: '200px',
          'background-color': 'yellow',
          position: 'absolute',
          top: '55px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        padding: '5px 3px 0 8px',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        transform: 'scale(1)',
        'box-sizing': 'border-box',
      },
      [
        createElementWithStyle(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky_1 = createElementWithStyle('div', {
              position: 'absolute',
              'background-color': 'purple',
              width: '50px',
              height: '50px',
              top: '205px',
              'z-index': '1',
              'box-sizing': 'border-box',
            })),
          ]
        ),
        (block_1 = createElementWithStyle('div', {
          width: '150px',
          height: '200px',
          'background-color': 'yellow',
          position: 'absolute',
          top: '55px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroll);
    BODY.appendChild(scroll2);

    function runTest() {
      // document.getElementById("scroll2").scrollTop = 50;
    }

    await snapshot();

    await snapshot();
  });
  // @TODO: inline nest none-inline case does not work
  xit('large-top-2.tentative', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2;
    scroll = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        padding: '5px 3px 0 8px',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        'box-sizing': 'border-box',
      },
      [
        createElementWithStyle(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky = createElementWithStyle('div', {
              position: 'sticky',
              background: 'purple',
              width: '50px',
              height: '50px',
              top: '200px',
              'box-sizing': 'border-box',
            })),
          ]
        ),
        (block = createElementWithStyle('div', {
          width: '150px',
          height: '200px',
          background: 'yellow',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        padding: '5px 3px 0 8px',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        'box-sizing': 'border-box',
      },
      [
        createElementWithStyle(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky_1 = createElementWithStyle('div', {
              position: 'sticky',
              background: 'purple',
              width: '50px',
              height: '50px',
              top: '200px',
              'box-sizing': 'border-box',
            })),
          ]
        ),
        (block_1 = createElementWithStyle('div', {
          width: '150px',
          height: '200px',
          background: 'yellow',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroll);
    BODY.appendChild(scroll2);

    await snapshot();
  });
  it('large-top-ref', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2: any;
    scroll = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        transform: 'scale(1)',
        'box-sizing': 'border-box',
      },
      [
        (sticky = createElementWithStyle('div', {
          position: 'absolute',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'z-index': '1',
          'box-sizing': 'border-box',
        })),
        (block = createElementWithStyle('div', {
          width: '200px',
          height: '200px',
          background: 'yellow',
          position: 'absolute',
          top: '50px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        transform: 'scale(1)',
        'box-sizing': 'border-box',
      },
      [
        (sticky_1 = createElementWithStyle('div', {
          position: 'absolute',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'z-index': '1',
          'box-sizing': 'border-box',
        })),
        (block_1 = createElementWithStyle('div', {
          width: '200px',
          height: '200px',
          background: 'yellow',
          position: 'absolute',
          top: '50px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroll);
    BODY.appendChild(scroll2);

    function runTest() {
      scroll2.scrollTop = 50;
    }

    await snapshot();
  });
  it('large-top.tentative', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2: any;
    scroll = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = createElementWithStyle('div', {
          position: 'sticky',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'box-sizing': 'border-box',
        })),
        (block = createElementWithStyle('div', {
          width: '200px',
          height: '200px',
          background: 'yellow',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = createElementWithStyle(
      'div',
      {
        border: '5px solid blue',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky_1 = createElementWithStyle('div', {
          position: 'sticky',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'box-sizing': 'border-box',
        })),
        (block_1 = createElementWithStyle('div', {
          width: '200px',
          height: '200px',
          background: 'yellow',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroll);
    BODY.appendChild(scroll2);

    function runTest() {
      scroll2.scrollTop = 50;
    }

    await snapshot();
  });
  // @TODO: nested children size does not count into scroll container size
  xit('left', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '200px',
        height: '100px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '100px',
            width: '500px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '200px',
              width: '100px',
              'background-color': 'red',
              display: 'inline-block',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '200px',
                width: '300px',
                display: 'inline-block',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                  display: 'inline-block',
                })),
                (sticky = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  left: '50px',
                  position: 'sticky',
                  height: '100px',
                  width: '100px',
                  'background-color': 'green',
                  display: 'inline-block',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();
  });
  it('margins', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  top: '50px',
                  position: 'sticky',
                  height: '100px',
                  width: '100px',
                  'background-color': 'green',
                  margin: '15px',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();
  });
  it('nested-bottom', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = createElementWithStyle(
                  'div',
                  {
                    'box-sizing': 'border-box',
                    bottom: '25px',
                    position: 'sticky',
                    height: '100px',
                    width: '100px',
                    'background-color': 'green',
                  },
                  [
                    createElementWithStyle('div', {
                      'box-sizing': 'border-box',
                      height: '50px',
                      width: '100px',
                    }),
                    createElementWithStyle('div', {
                      'box-sizing': 'border-box',
                      bottom: '35px',
                      position: 'sticky',
                      height: '50px',
                      width: '100px',
                      'background-color': 'blue',
                    }),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();
  });
  it('nested-inline-ref', async () => {
    let outerIndicator;
    let outerIndicator_1;
    let outerIndicator_2;
    let innerIndicator;
    let innerIndicator_1;
    let innerIndicator_2;
    let contents;
    let contents_1;
    let contents_2;
    let scroller1;
    let group;
    let group_1;
    let group_2;
    let scroller2;
    let scroller3;
    let div;
    group = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (contents = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (outerIndicator = createElementWithStyle(
                  'div',
                  {
                    color: 'green',
                    position: 'absolute',
                    left: '0',
                    'box-sizing': 'border-box',
                    top: '50px',
                  },
                  [createText(`X`)]
                )),
                (innerIndicator = createElementWithStyle(
                  'div',
                  {
                    color: 'blue',
                    position: 'absolute',
                    left: '25px',
                    'box-sizing': 'border-box',
                    top: '50px',
                  },
                  [createText(`XX`)]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_1 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (contents_1 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (outerIndicator_1 = createElementWithStyle(
                  'div',
                  {
                    color: 'green',
                    position: 'absolute',
                    left: '0',
                    'box-sizing': 'border-box',
                    top: '75px',
                  },
                  [createText(`X`)]
                )),
                (innerIndicator_1 = createElementWithStyle(
                  'div',
                  {
                    color: 'blue',
                    position: 'absolute',
                    left: '25px',
                    'box-sizing': 'border-box',
                    top: '85px',
                  },
                  [createText(`XX`)]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_2 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (contents_2 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (outerIndicator_2 = createElementWithStyle(
                  'div',
                  {
                    color: 'green',
                    position: 'absolute',
                    left: '0',
                    'box-sizing': 'border-box',
                    top: '100px',
                  },
                  [createText(`X`)]
                )),
                (innerIndicator_2 = createElementWithStyle(
                  'div',
                  {
                    color: 'blue',
                    position: 'absolute',
                    left: '25px',
                    'box-sizing': 'border-box',
                    top: '100px',
                  },
                  [createText(`XX`)]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    div = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [
        createText(
          `You should see three green and three blue rectangles above. No red should be visible.`
        ),
      ]
    );
    BODY.appendChild(group);
    BODY.appendChild(group_1);
    BODY.appendChild(group_2);
    BODY.appendChild(div);

    await snapshot();
  });

  // @TODO: inline nest none-inline case does not work
  xit('nested-inline', async () => {
    let outerIndicator;
    let outerIndicator_1;
    let outerIndicator_2;
    let prepadding;
    let prepadding_1;
    let prepadding_2;
    let innerpadding;
    let innerpadding_1;
    let innerpadding_2;
    let innerIndicator;
    let innerIndicator_1;
    let innerIndicator_2;
    let innerSticky;
    let innerSticky_1;
    let innerSticky_2;
    let outerSticky;
    let outerSticky_1;
    let outerSticky_2;
    let container;
    let container_1;
    let container_2;
    let contents;
    let contents_1;
    let contents_2;
    let scroller1;
    let group;
    let group_1;
    let group_2;
    let scroller2;
    let scroller3;
    group = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (outerIndicator = createElementWithStyle(
              'div',
              {
                color: 'red',
                position: 'absolute',
                left: '0',
                'box-sizing': 'border-box',
                top: '50px',
              },
              [createText(`X`)]
            )),
            (contents = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding = createElementWithStyle('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container = createElementWithStyle(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding = createElementWithStyle('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (outerSticky = createElementWithStyle(
                      'div',
                      {
                        display: 'inline',
                        color: 'green',
                        position: 'sticky',
                        top: '50px',
                        'box-sizing': 'border-box',
                      },
                      [
                        createText(`X`),
                        (innerIndicator = createElementWithStyle(
                          'div',
                          {
                            color: 'red',
                            position: 'absolute',
                            left: '25px',
                            'box-sizing': 'border-box',
                            top: '0',
                          },
                          [createText(`XX`)]
                        )),
                        (innerSticky = createElementWithStyle(
                          'div',
                          {
                            display: 'inline',
                            color: 'blue',
                            position: 'sticky',
                            top: '60px',
                            'box-sizing': 'border-box',
                          },
                          [createText(`XX`)]
                        )),
                      ]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_1 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (outerIndicator_1 = createElementWithStyle(
              'div',
              {
                color: 'red',
                position: 'absolute',
                left: '0',
                'box-sizing': 'border-box',
                top: '75px',
              },
              [createText(`X`)]
            )),
            (contents_1 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_1 = createElementWithStyle('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_1 = createElementWithStyle(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_1 = createElementWithStyle('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (outerSticky_1 = createElementWithStyle(
                      'div',
                      {
                        display: 'inline',
                        color: 'green',
                        position: 'sticky',
                        top: '50px',
                        'box-sizing': 'border-box',
                      },
                      [
                        createText(`X`),
                        (innerIndicator_1 = createElementWithStyle(
                          'div',
                          {
                            color: 'red',
                            position: 'absolute',
                            left: '25px',
                            'box-sizing': 'border-box',
                            top: '10px',
                          },
                          [createText(`XX`)]
                        )),
                        (innerSticky_1 = createElementWithStyle(
                          'div',
                          {
                            display: 'inline',
                            color: 'blue',
                            position: 'sticky',
                            top: '60px',
                            'box-sizing': 'border-box',
                          },
                          [createText(`XX`)]
                        )),
                      ]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    group_2 = createElementWithStyle(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = createElementWithStyle(
          'div',
          {
            position: 'relative',
            width: '100px',
            height: '200px',
            'overflow-x': 'hidden',
            'overflow-y': 'auto',
            font: '25px/1 Ahem',
            'box-sizing': 'border-box',
          },
          [
            (outerIndicator_2 = createElementWithStyle(
              'div',
              {
                color: 'red',
                position: 'absolute',
                left: '0',
                'box-sizing': 'border-box',
                top: '100px',
              },
              [createText(`X`)]
            )),
            (contents_2 = createElementWithStyle(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_2 = createElementWithStyle('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_2 = createElementWithStyle(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_2 = createElementWithStyle('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (outerSticky_2 = createElementWithStyle(
                      'div',
                      {
                        display: 'inline',
                        color: 'green',
                        position: 'sticky',
                        top: '50px',
                        'box-sizing': 'border-box',
                      },
                      [
                        createText(`X`),
                        (innerIndicator_2 = createElementWithStyle(
                          'div',
                          {
                            color: 'red',
                            position: 'absolute',
                            left: '25px',
                            'box-sizing': 'border-box',
                            top: '0',
                          },
                          [createText(`XX`)]
                        )),
                        (innerSticky_2 = createElementWithStyle(
                          'div',
                          {
                            display: 'inline',
                            color: 'blue',
                            position: 'sticky',
                            top: '60px',
                            'box-sizing': 'border-box',
                          },
                          [createText(`XX`)]
                        )),
                      ]
                    )),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(group);
    BODY.appendChild(group_1);
    BODY.appendChild(group_2);

    await snapshot();
  });
  // @TODO: nested children size does not count into scroll container size
  xit('nested-left', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '200px',
        height: '100px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '100px',
            width: '500px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '200px',
              width: '100px',
              'background-color': 'red',
              display: 'inline-block',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '200px',
                width: '300px',
                display: 'inline-block',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                  display: 'inline-block',
                })),
                (sticky = createElementWithStyle(
                  'div',
                  {
                    'box-sizing': 'border-box',
                    left: '50px',
                    position: 'sticky',
                    height: '100px',
                    width: '100px',
                    'background-color': 'green',
                    display: 'inline-block',
                  },
                  [
                    createElementWithStyle('div', {
                      'box-sizing': 'border-box',
                      left: '60px',
                      position: 'sticky',
                      height: '100%',
                      width: '50px',
                      'background-color': 'blue',
                      display: 'inline-block',
                    }),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();

    await snapshot();
  });

  // @TODO: nested children size does not count into scroll container size
  xit('nested-right', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '200px',
        height: '100px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '100px',
            width: '500px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '200px',
              width: '100px',
              'background-color': 'red',
              display: 'inline-block',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '200px',
                width: '300px',
                display: 'inline-block',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                  display: 'inline-block',
                })),
                (sticky = createElementWithStyle(
                  'div',
                  {
                    'box-sizing': 'border-box',
                    right: '25px',
                    position: 'sticky',
                    height: '100px',
                    width: '100px',
                    'background-color': 'green',
                    display: 'inline-block',
                  },
                  [
                    createElementWithStyle('div', {
                      'box-sizing': 'border-box',
                      height: '100%',
                      width: '50px',
                      display: 'inline-block',
                    }),
                    createElementWithStyle('div', {
                      'box-sizing': 'border-box',
                      right: '35px',
                      position: 'sticky',
                      height: '100%',
                      width: '50px',
                      'background-color': 'blue',
                      display: 'inline-block',
                    }),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();

    await snapshot();
  });
  it('nested-top', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = createElementWithStyle(
                  'div',
                  {
                    'box-sizing': 'border-box',
                    top: '50px',
                    position: 'sticky',
                    height: '100px',
                    width: '100px',
                    'background-color': 'green',
                  },
                  [
                    createElementWithStyle('div', {
                      'box-sizing': 'border-box',
                      top: '60px',
                      position: 'sticky',
                      height: '50px',
                      width: '100%',
                      'background-color': 'blue',
                    }),
                  ]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();
  });
  it('offset-overflow', async () => {
    let sticky;
    let scroller1;
    scroller1 = createElementWithStyle(
      'div',
      {
        overflow: 'scroll',
        width: '100px',
        height: '100px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = createElementWithStyle('div', {
          'background-color': 'green',
          height: '50px',
          width: '50px',
          position: 'sticky',
          top: '200px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroller1);

    await snapshot();
  });
  it('offset-top-left', async () => {
    let sticky;
    let spacer;
    let scroller1;
    scroller1 = createElementWithStyle(
      'div',
      {
        position: 'relative',
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = createElementWithStyle('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer = createElementWithStyle('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroller1);

    await snapshot();
  });
  it('overflow-hidden', async () => {
    let div;
    div = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        width: '100px',
        height: '100px',
        overflow: 'scroll',
      },
      [
        createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            width: '80px',
            height: '200px',
            overflow: 'hidden',
          },
          [
            createElementWithStyle('div', {
              'box-sizing': 'border-box',
              width: '20px',
              height: '20px',
              position: 'sticky',
              top: '0px',
              'background-color': 'red',
            }),
            createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '500px',
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);
    await snapshot();
  });
  it('overflow-padding', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
        padding: '20px 0px',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  top: '50px',
                  position: 'sticky',
                  height: '100px',
                  width: '100px',
                  'background-color': 'green',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();

    await snapshot();
  });
  it('scroll-reposition', async (done) => {
    let sticky: any;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        width: '200px',
        height: '200px',
        'overflow-y': 'scroll',
      },
      [
        (sticky = createElementWithStyle('div', {
          'box-sizing': 'border-box',
          width: '100px',
          height: '100px',
          position: 'sticky',
          backgroundColor: 'lightblue',
          top: '50px',
          left: '50px',
          contain: 'strict',
        })),
        createElementWithStyle('div', {
          'box-sizing': 'border-box',
          width: '100px',
          height: '500px',
        }),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();

    requestAnimationFrame(async () => {
      sticky.style.top = '5px';
      await snapshot();
      done();
    });

  });
  it('scrolled-remove-sibling', async (done) => {
    let bigItem: any;
    let container;
    container = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        overflow: 'auto',
        width: '100px',
        height: '100px',
        'background-color': 'red',
      },
      [
        createElementWithStyle('div', {
          'box-sizing': 'border-box',
          position: 'sticky',
          top: '0',
          height: '100px',
          'background-color': 'green',
        }),
        (bigItem = createElementWithStyle('div', {
          'box-sizing': 'border-box',
          height: '600px',
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      bigItem.style.display = 'none';
      await snapshot();
      done();
    });
  });
  it('stacking-context-ref', async () => {
    let indicator;
    let div;
    indicator = createElementWithStyle('div', {
      'background-color': 'green',
      width: '200px',
      height: '200px',
      'box-sizing': 'border-box',
    });
    div = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [
        createText(
          `You should see a single green box above. No red should be visible.`
        ),
      ]
    );
    BODY.appendChild(indicator);
    BODY.appendChild(div);

    await snapshot();
  });
  it('stacking-context', async () => {
    let indicator;
    let child;
    let sticky;
    let div;
    indicator = createElementWithStyle('div', {
      position: 'absolute',
      'background-color': 'green',
      'z-index': '1',
      width: '200px',
      height: '200px',
      'box-sizing': 'border-box',
    });
    sticky = createElementWithStyle(
      'div',
      {
        position: 'sticky',
        'z-index': '0',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (child = createElementWithStyle('div', {
          position: 'relative',
          'background-color': 'red',
          'z-index': '2',
          width: '200px',
          height: '200px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    div = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
      },
      [
        createText(
          `You should see a single green box above. No red should be visible.`
        ),
      ]
    );
    BODY.appendChild(indicator);
    BODY.appendChild(sticky);
    BODY.appendChild(div);

    await snapshot();
  });
  it('transforms-translate', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = createElementWithStyle(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = createElementWithStyle('div', {
                  'box-sizing': 'border-box',
                  top: '50px',
                  position: 'sticky',
                  height: '100px',
                  width: '100px',
                  'background-color': 'green',
                  transform: 'translateY(-100px)',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();

    await snapshot();
  });

  it('transforms-translate works with position sticky element', async (done) => {
    let sticky;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        border: '1px solid rgb(0, 0, 0)',
      },
      [
        (sticky = createElementWithStyle('div', {
          display: 'flex',
          top: '50px',
          position: 'sticky',
          height: '100px',
          width: '100px',
          'background-color': 'green',
        })),
      ]
    );

    BODY.appendChild(scroller);

    await snapshot();

    requestAnimationFrame(async () => {
      sticky.style.transform = 'translateY(-100px)';
      await snapshot();
      done();
    });
  });

  it('should work with image', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '300px',
          overflow: 'scroll',
          background: 'yellow',
        },
      },
      [
        createElement('div', {
          style: {
            height: '550px',
            paddingTop: '100px',
            background: 'grey',
          },
        }, [
          createElement('img', {
            src: 'assets/200x200-green.png',
            style: {
                backgroundColor: 'green',
                width: '4vw',
                height: '4vw',
                position: 'sticky',
                top: '50px',
            }
          }),
        ]),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
    div.scrollBy(0, 100);
    await snapshot();
    div.scrollTo(0, 300);
    await snapshot(0.2);
  });
});
