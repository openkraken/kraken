describe('scrollable-size', () => {
  it('works with html', async () => {
    let div1 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'grey'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '500px',
          height: '100px',
          backgroundColor: 'lightgrey'
        }
      })
    ]);
    let div2 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '700px',
          marginTop: '177px',
          backgroundColor: 'lightgreen'
        }
      })
    ]);
    let div3 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'blue'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
        }
      }, [
        createElement('div', {
          style: {
            width: '533px',
            height: '50px',
            backgroundColor: 'pink'
          }
        }),
      ])
    ]);

    let div = createElement('div', {
      style: {
        width: '350px',
        height: '350px',
        padding: '25px',
        backgroundColor: 'yellow',
      }
    });

    div.appendChild(div1);
    div.appendChild(div2);
    div.appendChild(div3);

    BODY.appendChild(div);

    await snapshot();
    document.documentElement.scrollTo(2000, 2000);
    await snapshot(0.2);
  });
});
