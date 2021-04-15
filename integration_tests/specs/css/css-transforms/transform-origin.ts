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

    xit('works width margin' , async () => {
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
});
