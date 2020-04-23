/*auto generated*/
describe('position-sticky', () => {
  xit('bottom', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  background: 'yellow',
                })),
                (sticky = create('div', {
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

    await matchScreenshot();

    await matchScreenshot();
  });
  it('change-top-ref', async () => {
    let box;
    let spacer;
    box = create('div', {
      'backface-visibility': 'hidden',
      'background-color': 'green',
      position: 'sticky',
      top: '200px',
      width: '100px',
      height: '100px',
      'box-sizing': 'border-box',
    });
    spacer = create('div', {
      height: '200vh',
      'background-image':
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/ruler-v-50px.png)',
      'background-repeat': 'repeat',
      'box-sizing': 'border-box',
    });
    BODY.appendChild(box);
    BODY.appendChild(spacer);

    await matchScreenshot();
  });
  xit('change-top', async () => {
    let marker;
    let sticky;
    let spacer;
    marker = create('div', {
      'background-color': 'red',
      position: 'absolute',
      top: '200px',
      height: '100px',
      width: '100px',
      'box-sizing': 'border-box',
    });
    sticky = create('div', {
      'backface-visibility': 'hidden',
      'background-color': 'green',
      position: 'sticky',
      top: '0',
      width: '100px',
      height: '100px',
      'box-sizing': 'border-box',
    });
    spacer = create('div', {
      height: '200vh',
      'background-image':
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/ruler-v-50px.png)',
      'background-repeat': 'repeat',
      'box-sizing': 'border-box',
    });
    BODY.appendChild(marker);
    BODY.appendChild(sticky);
    BODY.appendChild(spacer);

    await matchScreenshot();
  });
  it('child-multicolumn-ref', async () => {
    let contents;
    let child;
    let relative;
    let spacer;
    let scroller: any;
    let div;
    scroller = create(
      'div',
      {
        'overflow-y': 'scroll',
        width: '200px',
        height: '200px',
        'background-image':
          'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/ruler-v-50px.png)',
        'background-repeat': 'repeat',
        'box-sizing': 'border-box',
      },
      [
        (relative = create(
          'div',
          {
            position: 'relative',
            top: '100px',
            margin: '10px',
            'box-sizing': 'border-box',
          },
          [
            (child = create(
              'div',
              {
                width: '100px',
                height: '100px',
                'background-color': 'green',
                'box-sizing': 'border-box',
              },
              [
                (contents = create('div', {
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
        (spacer = create('div', {
          height: '400px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    div = create(
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

    await matchScreenshot();
  });
  it('child-multicolumn', async () => {
    let contents;
    let multicolumn;
    let sticky;
    let spacer;
    let scroller: any;
    let div;
    scroller = create(
      'div',
      {
        'overflow-y': 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = create(
          'div',
          {
            position: 'sticky',
            top: '10px',
            margin: '10px',
            'background-color': 'red',
            'box-sizing': 'border-box',
          },
          [
            (multicolumn = create(
              'div',
              {
                width: '100px',
                height: '100px',
                'background-color': 'green',
                padding: '10px',
                'box-sizing': 'border-box',
              },
              [
                (contents = create('div', {
                  width: '80px',
                  height: '80px',
                  'background-color': 'lightgreen',
                  'box-sizing': 'border-box',
                })),
              ]
            )),
          ]
        )),
        (spacer = create('div', {
          height: '400px',
          'background-image':
            'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/ruler-v-50px.png)',
          'background-repeat': 'repeat',
          'box-sizing': 'border-box',
        })),
      ]
    );
    div = create(
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

    await matchScreenshot();
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
    scroller1 = create(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer = create(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (flexItem = create('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green = create('div', {
              'background-color': 'green',
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_1 = create('div', {
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
    scroller2 = create(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_1 = create(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (flexItem_1 = create('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (flexItem_2 = create('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_2 = create('div', {
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
    scroller3 = create(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_2 = create(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (flexItem_3 = create('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (flexItem_4 = create('div', {
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_3 = create('div', {
              'background-color': 'green',
              height: '85px',
              width: '100px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_4 = create('div', {
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
    p = create(
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
    await matchScreenshot();
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
    scroller1 = create(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer = create(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (indicator = create('div', {
              position: 'absolute',
              'background-color': 'red',
              width: '100px',
              height: '85px',
              'box-sizing': 'border-box',
              left: '100px',
            })),
            (flexItem = create('div', {
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (sticky = create('div', {
              position: 'sticky',
              left: '50px',
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green = create('div', {
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
    scroller2 = create(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_1 = create(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (indicator_1 = create('div', {
              position: 'absolute',
              'background-color': 'red',
              width: '100px',
              height: '85px',
              'box-sizing': 'border-box',
              left: '200px',
            })),
            (flexItem_1 = create('div', {
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (sticky_1 = create('div', {
              position: 'sticky',
              left: '50px',
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_1 = create('div', {
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
    scroller3 = create(
      'div',
      {
        overflow: 'scroll',
        width: '350px',
        height: '100px',
        'margin-bottom': '15px',
        'box-sizing': 'border-box',
      },
      [
        (flexContainer_2 = create(
          'div',
          {
            width: '600px',
            position: 'relative',
            display: 'flex',
            'flex-flow': 'row wrap',
            'box-sizing': 'border-box',
          },
          [
            (indicator_2 = create('div', {
              position: 'absolute',
              'background-color': 'red',
              width: '100px',
              height: '85px',
              'box-sizing': 'border-box',
              left: '300px',
            })),
            (flexItem_2 = create('div', {
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (sticky_2 = create('div', {
              position: 'sticky',
              left: '50px',
              'background-color': 'green',
              width: '100px',
              height: '85px',
              display: 'flex',
              'box-sizing': 'border-box',
            })),
            (green_2 = create('div', {
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

    await matchScreenshot();
  });
  xit('get-bounding-client-rect', async () => {
    let sticky1;
    let spacer;
    let spacer_1;
    let spacer_2;
    let scroller1;
    let sticky2;
    let scroller2;
    let sticky3;
    let scroller3;
    scroller1 = create(
      'div',
      {
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky1 = create('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer = create('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroller2 = create(
      'div',
      {
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky2 = create('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer_1 = create('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroller3 = create(
      'div',
      {
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky3 = create('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer_2 = create('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroller1);
    BODY.appendChild(scroller2);
    BODY.appendChild(scroller3);

    await matchScreenshot();
  });
  it('inflow-position', async () => {
    let before;
    let sticky;
    let after;
    let padding;
    let scroller;
    scroller = create(
      'div',
      {
        position: 'relative',
        height: '200px',
        width: '100px',
        overflow: 'scroll',
        'box-sizing': 'border-box',
      },
      [
        (before = create('div', {
          'background-color': 'fuchsia',
          height: '50px',
          width: '50px',
          'box-sizing': 'border-box',
        })),
        (sticky = create('div', {
          'background-color': 'green',
          position: 'sticky',
          top: '150px',
          height: '50px',
          width: '50px',
          'box-sizing': 'border-box',
        })),
        (after = create('div', {
          'background-color': 'orange',
          height: '50px',
          width: '50px',
          'box-sizing': 'border-box',
        })),
        (padding = create('div', {
          height: '500px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroller);


    await matchScreenshot();
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
    group = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = create(
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
            (contents = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (indicator = create(
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
    group_1 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = create(
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
            (contents_1 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (indicator_1 = create(
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
    group_2 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = create(
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
            (contents_2 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (indicator_2 = create(
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

    await matchScreenshot();
  });
  xit('inline', async () => {
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
    group = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = create(
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
            (indicator = create(
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
            (contents = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding = create('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container = create(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding = create('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (sticky = create(
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
    group_1 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = create(
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
            (indicator_1 = create(
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
            (contents_1 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_1 = create('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_1 = create(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_1 = create('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (sticky_1 = create(
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
    group_2 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = create(
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
            (indicator_2 = create(
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
            (contents_2 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_2 = create('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_2 = create(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_2 = create('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (sticky_2 = create(
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

    await matchScreenshot();
  });
  xit('large-top-2-ref', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2;
    scroll = create(
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
        create(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky = create('div', {
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
        (block = create('div', {
          width: '150px',
          height: '200px',
          'background-color': 'yellow',
          position: 'absolute',
          top: '55px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = create(
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
        create(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky_1 = create('div', {
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
        (block_1 = create('div', {
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

    await matchScreenshot();

    await matchScreenshot();
  });
  xit('large-top-2.tentative', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2;
    scroll = create(
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
        create(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky = create('div', {
              position: 'sticky',
              background: 'purple',
              width: '50px',
              height: '50px',
              top: '200px',
              'box-sizing': 'border-box',
            })),
          ]
        ),
        (block = create('div', {
          width: '150px',
          height: '200px',
          background: 'yellow',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = create(
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
        create(
          'span',
          {
            'box-sizing': 'border-box',
          },
          [
            (sticky_1 = create('div', {
              position: 'sticky',
              background: 'purple',
              width: '50px',
              height: '50px',
              top: '200px',
              'box-sizing': 'border-box',
            })),
          ]
        ),
        (block_1 = create('div', {
          width: '150px',
          height: '200px',
          background: 'yellow',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroll);
    BODY.appendChild(scroll2);

    await matchScreenshot();
  });
  xit('large-top-ref', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2: any;
    scroll = create(
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
        (sticky = create('div', {
          position: 'absolute',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'z-index': '1',
          'box-sizing': 'border-box',
        })),
        (block = create('div', {
          width: '100%',
          height: '200px',
          background: 'yellow',
          position: 'absolute',
          top: '50px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = create(
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
        (sticky_1 = create('div', {
          position: 'absolute',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'z-index': '1',
          'box-sizing': 'border-box',
        })),
        (block_1 = create('div', {
          width: '100%',
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

    await matchScreenshot();
  });
  xit('large-top.tentative', async () => {
    let sticky;
    let sticky_1;
    let block;
    let block_1;
    let scroll;
    let scroll2: any;
    scroll = create(
      'div',
      {
        border: '5px solid blue',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = create('div', {
          position: 'sticky',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'box-sizing': 'border-box',
        })),
        (block = create('div', {
          width: '100%',
          height: '200px',
          background: 'yellow',
          'box-sizing': 'border-box',
        })),
      ]
    );
    scroll2 = create(
      'div',
      {
        border: '5px solid blue',
        overflow: 'auto',
        height: '200px',
        width: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky_1 = create('div', {
          position: 'sticky',
          background: 'purple',
          width: '50px',
          height: '50px',
          top: '200px',
          'box-sizing': 'border-box',
        })),
        (block_1 = create('div', {
          width: '100%',
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

    await matchScreenshot();
  });
  xit('left', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '100px',
            width: '500px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '200px',
              width: '100px',
              'background-color': 'red',
              display: 'inline-block',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '200px',
                width: '300px',
                display: 'inline-block',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                  display: 'inline-block',
                })),
                (sticky = create('div', {
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

    await matchScreenshot();
  });
  it('margins', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = create('div', {
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

    await matchScreenshot();
  });
  xit('nested-bottom', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = create(
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
                    create('div', {
                      'box-sizing': 'border-box',
                      height: '50px',
                      width: '100%',
                    }),
                    create('div', {
                      'box-sizing': 'border-box',
                      bottom: '35px',
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

    await matchScreenshot();
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
    group = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = create(
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
            (contents = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (outerIndicator = create(
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
                (innerIndicator = create(
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
    group_1 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = create(
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
            (contents_1 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (outerIndicator_1 = create(
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
                (innerIndicator_1 = create(
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
    group_2 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = create(
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
            (contents_2 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (outerIndicator_2 = create(
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
                (innerIndicator_2 = create(
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
    div = create(
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

    await matchScreenshot();
  });
  it('nested-inline', async () => {
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
    group = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller1 = create(
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
            (outerIndicator = create(
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
            (contents = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding = create('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container = create(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding = create('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (outerSticky = create(
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
                        (innerIndicator = create(
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
                        (innerSticky = create(
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
    group_1 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller2 = create(
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
            (outerIndicator_1 = create(
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
            (contents_1 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_1 = create('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_1 = create(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_1 = create('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (outerSticky_1 = create(
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
                        (innerIndicator_1 = create(
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
                        (innerSticky_1 = create(
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
    group_2 = create(
      'div',
      {
        display: 'inline-block',
        position: 'relative',
        width: '120px',
        height: '250px',
        'box-sizing': 'border-box',
      },
      [
        (scroller3 = create(
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
            (outerIndicator_2 = create(
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
            (contents_2 = create(
              'div',
              {
                height: '500px',
                'box-sizing': 'border-box',
              },
              [
                (prepadding_2 = create('div', {
                  height: '100px',
                  'box-sizing': 'border-box',
                })),
                (container_2 = create(
                  'div',
                  {
                    height: '200px',
                    'box-sizing': 'border-box',
                  },
                  [
                    (innerpadding_2 = create('div', {
                      height: '50px',
                      'box-sizing': 'border-box',
                    })),
                    (outerSticky_2 = create(
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
                        (innerIndicator_2 = create(
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
                        (innerSticky_2 = create(
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

    await matchScreenshot();
  });
  xit('nested-left', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '100px',
            width: '500px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '200px',
              width: '100px',
              'background-color': 'red',
              display: 'inline-block',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '200px',
                width: '300px',
                display: 'inline-block',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                  display: 'inline-block',
                })),
                (sticky = create(
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
                    create('div', {
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

    await matchScreenshot();

    await matchScreenshot();
  });
  xit('nested-right', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '100px',
            width: '500px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '200px',
              width: '100px',
              'background-color': 'red',
              display: 'inline-block',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '200px',
                width: '300px',
                display: 'inline-block',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                  display: 'inline-block',
                })),
                (sticky = create(
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
                    create('div', {
                      'box-sizing': 'border-box',
                      height: '100%',
                      width: '50px',
                      display: 'inline-block',
                    }),
                    create('div', {
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

    await matchScreenshot();

    await matchScreenshot();
  });
  xit('nested-top', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = create(
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
                    create('div', {
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

    await matchScreenshot();
  });
  xit('offset-overflow', async () => {
    let sticky;
    let scroller1;
    scroller1 = create(
      'div',
      {
        overflow: 'scroll',
        width: '100px',
        height: '100px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = create('div', {
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

    await matchScreenshot();
  });
  it('offset-top-left', async () => {
    let sticky;
    let spacer;
    let scroller1;
    scroller1 = create(
      'div',
      {
        position: 'relative',
        overflow: 'scroll',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (sticky = create('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'sticky',
          top: '50px',
          left: '20px',
          'box-sizing': 'border-box',
        })),
        (spacer = create('div', {
          width: '2000px',
          height: '2000px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    BODY.appendChild(scroller1);

    await matchScreenshot();
  });
  it('overflow-hidden', async () => {
    let div;
    div = create(
      'div',
      {
        'box-sizing': 'border-box',
        width: '100px',
        height: '100px',
        overflow: 'scroll',
      },
      [
        create(
          'div',
          {
            'box-sizing': 'border-box',
            width: '80px',
            height: '200px',
            overflow: 'hidden',
          },
          [
            create('div', {
              'box-sizing': 'border-box',
              width: '20px',
              height: '20px',
              position: 'sticky',
              top: '0px',
              'background-color': 'red',
            }),
            create('div', {
              'box-sizing': 'border-box',
              height: '500px',
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);
    await matchScreenshot();
  });
  xit('overflow-padding', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = create('div', {
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

    await matchScreenshot();

    await matchScreenshot();
  });
  it('scroll-reposition', async (done) => {
    let sticky: any;
    let scroller;
    scroller = create(
      'div',
      {
        'box-sizing': 'border-box',
        width: '200px',
        height: '200px',
        'overflow-y': 'scroll',
      },
      [
        (sticky = create('div', {
          'box-sizing': 'border-box',
          width: '100px',
          height: '100px',
          position: 'sticky',
          backgroundColor: 'lightblue',
          top: '50px',
          left: '50px',
          contain: 'strict',
        })),
        create('div', {
          'box-sizing': 'border-box',
          width: '100px',
          height: '500px',
        }),
      ]
    );
    BODY.appendChild(scroller);

    requestAnimationFrame(() =>
      requestAnimationFrame(async () => {
        sticky.style.top = '5px';
        await matchScreenshot();
        done();
      })
    );

    await matchScreenshot();
  });
  it('scrolled-remove-sibling', async (done) => {
    let bigItem: any;
    let container;
    container = create(
      'div',
      {
        'box-sizing': 'border-box',
        overflow: 'auto',
        width: '100px',
        height: '100px',
        'background-color': 'red',
      },
      [
        create('div', {
          'box-sizing': 'border-box',
          position: 'sticky',
          top: '0',
          height: '100px',
          'background-color': 'green',
        }),
        (bigItem = create('div', {
          'box-sizing': 'border-box',
          height: '600px',
        })),
      ]
    );
    BODY.appendChild(container);

    requestAnimationFrame(() => {
      requestAnimationFrame(async () => {
        bigItem.style.display = 'none';
        await matchScreenshot();
        done();
      });
    });

    await matchScreenshot();
  });
  it('stacking-context-ref', async () => {
    let indicator;
    let div;
    indicator = create('div', {
      'background-color': 'green',
      width: '200px',
      height: '200px',
      'box-sizing': 'border-box',
    });
    div = create(
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

    await matchScreenshot();
  });
  it('stacking-context', async () => {
    let indicator;
    let child;
    let sticky;
    let div;
    indicator = create('div', {
      position: 'absolute',
      'background-color': 'green',
      'z-index': '1',
      width: '200px',
      height: '200px',
      'box-sizing': 'border-box',
    });
    sticky = create(
      'div',
      {
        position: 'sticky',
        'z-index': '0',
        width: '200px',
        height: '200px',
        'box-sizing': 'border-box',
      },
      [
        (child = create('div', {
          position: 'relative',
          'background-color': 'red',
          'z-index': '2',
          width: '200px',
          height: '200px',
          'box-sizing': 'border-box',
        })),
      ]
    );
    div = create(
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

    await matchScreenshot();
  });
  xit('transforms-translate', async () => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let contents;
    let scroller;
    scroller = create(
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
        (contents = create(
          'div',
          {
            'box-sizing': 'border-box',
            height: '500px',
            width: '100px',
          },
          [
            (prepadding = create('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            (container = create(
              'div',
              {
                'box-sizing': 'border-box',
                height: '300px',
                width: '100px',
              },
              [
                (filter = create('div', {
                  'box-sizing': 'border-box',
                  height: '100px',
                  width: '100px',
                  'background-color': 'yellow',
                })),
                (sticky = create('div', {
                  'box-sizing': 'border-box',
                  top: '50px',
                  position: 'sticky',
                  height: '100px',
                  width: '100px',
                  'background-color': 'green',
                  transform: 'translateY(-100%)',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await matchScreenshot();

    await matchScreenshot();
  });
});
