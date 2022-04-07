describe('Transform origin', () => {
  it('length', async function() {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transformOrigin: '15px 20px',
        transform: 'rotate(0.3turn)',
      })
    );

    await snapshot();
  });
  it('percent', async function() {
      document.body.appendChild(
        createElementWithStyle('div', {
          width: '100px',
          height: '100px',
          backgroundColor: 'red',
          transformOrigin: '60% 60%',
          transform: 'rotate(0.3turn)',
        })
      );

      await snapshot();
    });
    it('keyword', async function() {
        document.body.appendChild(
          createElementWithStyle('div', {
            width: '100px',
            height: '100px',
            backgroundColor: 'red',
            transformOrigin: 'top right',
            transform: 'rotate(0.1turn)',
          })
        );

        await snapshot();
      });
      it('keyword center', async function() {
              document.body.appendChild(
                createElementWithStyle('div', {
                  width: '100px',
                  height: '100px',
                  backgroundColor: 'red',
                  transformOrigin: 'center bottom',
                  transform: 'rotate(0.1turn)',
                })
              );

              await snapshot();
            });

    it('works width margin' , async () => {
      let n1, n2;
      n1 = createElementWithStyle(
         'div',
         {
           display: 'flex',
           flexDirection: 'column',
           justifyContent: 'center',
           alignItems: 'center',
           width: '300px',
           height: '300px',
           backgroundColor: 'gray',
         },
         [
          (n2 = createElementWithStyle(
            'div',
             {
               position: 'relative',
               width: '100px',
               height: '100px',
               backgroundColor: 'blue',
               marginRight: '100px',
               transform: 'scale(1.5)'
             },
          ))
         ]
       );
      BODY.appendChild(n1);

      await snapshot();
    });

  it('should work with value change to empty string', async (done) => {
    let div;
    div = createElement(
    'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'yellow',
          overflow: 'hidden',
          transformOrigin: '100px 100px',
          transform: 'rotate(45deg)'
        },
      },
    );

    document.body.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div.style.transformOrigin = '';
      await snapshot();
      done();
    });
  });
});
