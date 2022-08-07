describe('text', () => {
  it('should wrap in the boundary of flex container', async () => {
    let div;
 
    div = createElement('div', {
      style: {
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: 'yellow'
      }
    }, [
      (createElement('div', {
          style: {
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'flex-start',
            flexShrink: 0,
            height: '100px'
          },
        },
        [
          createElement('span', {
            style: {
              lineHeight: '18px',
            }
          }, [
            createText('hello world hello world hello world hello world hello world hello world hello world hello world hello world ')
          ])
        ]
      ))
    ]);
    
    BODY.appendChild(div);

    await snapshot();
  });

  it('should not wrap when its ancestor has flex-shrink 0 in the horizontal axis', async () => {
    let div;
 
    div = createElement('div', {
      style: {
        display: 'flex',
        backgroundColor: 'yellow'
      }
    }, [
      (createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start',
          flexShrink: 0,
          height: '100px'
        },
      },
      [
        createElement('span', {
          style: {
            lineHeight: '18px',
          }
        }, [
          createText('hello world hello world hello world hello world hello world hello world hello world hello world hello world ')
        ])
      ]
      ))
    ]);
    
    BODY.appendChild(div);

    await snapshot();
  });
});
