describe('Transform origin', () => {
  it('length', async function() {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transformOrigin: '15px 20px',
        transform: 'rotate(0.3turn)',
      })
    );

    await matchScreenshot();
  });
  it('percent', async function() {
      document.body.appendChild(
        create('div', {
          width: '100px',
          height: '100px',
          backgroundColor: 'red',
          transformOrigin: '60% 60%',
          transform: 'rotate(0.3turn)',
        })
      );

      await matchScreenshot();
    });
    it('keyword', async function() {
        document.body.appendChild(
          create('div', {
            width: '100px',
            height: '100px',
            backgroundColor: 'red',
            transformOrigin: 'top right',
            transform: 'rotate(0.1turn)',
          })
        );

        await matchScreenshot();
      });
      it('keyword center', async function() {
              document.body.appendChild(
                create('div', {
                  width: '100px',
                  height: '100px',
                  backgroundColor: 'red',
                  transformOrigin: 'center bottom',
                  transform: 'rotate(0.1turn)',
                })
              );

              await matchScreenshot();
            });
});
