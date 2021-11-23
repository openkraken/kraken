describe('Display inline-block', () => {
  it('should work with basic samples', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '100px',
      height: '100px',
      display: 'inline-block',
      backgroundColor: '#666',
    });

    document.body.appendChild(container);
    document.body.appendChild(
      document.createTextNode(
        'This text should display as the same line as the box'
      )
    );

    await snapshot();
  });

  xit('inline-block box constraint is tight', async () => {
    let magenta = createElementWithStyle('div', {
      border: '5px solid magenta',
      display: 'inline-block',
    });
    // append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      border: '10px solid cyan',
      padding: '15px',
      margin: '20px 0px',
      backgroundColor: 'yellow',
      display: 'inline-flex',
    });
    append(magenta, box);
    append(BODY, magenta);
    await snapshot();
  });

  xit('inline-block nest inline-block should behavior like inline-block', async () => {
    let magenta = createElementWithStyle('div', {
      border: '5px solid magenta',
      display: 'inline-block',
    });
    let box = createElementWithStyle('div', {
      border: '10px solid cyan',
      padding: '15px',
      margin: '20px 0px',
      backgroundColor: 'yellow',
      display: 'inline-block',
    });
    append(magenta, box);
    append(BODY, magenta);
    await snapshot(magenta);
  });

  xit('inline-block nest block should behavior like inline-block', async () => {
    let magenta = createElementWithStyle('div', {
      border: '5px solid magenta',
      display: 'inline-block',
    });
    let box = createElementWithStyle('div', {
      border: '10px solid cyan',
      padding: '15px',
      margin: '20px 0px',
      backgroundColor: 'yellow',
      display: 'block',
    });
    append(magenta, box);
    append(BODY, magenta);
    await snapshot(magenta);
  });

  xit('textNode only if have one space', async () => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };

    let divStyle = {
      display: 'inline-block'
    };

    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', divStyle, createText('Several ')),
      createElementWithStyle('div', divStyle, createText(' inline elements')),
      createText(' are '),
      createElementWithStyle('div', divStyle, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('Several inline elements are in this sentence.')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();
  });

  it('text not wrap when inline-block width exceeds its container', async() => {
    const container = createElement('div', {
      style: {
        "display": "inline-block",
        "padding": "10px 300px",
        backgroundColor: 'yellow'
      }
    }, [
        createText('11111'),
    ]);
  
    document.body.appendChild(container);
    await snapshot();
  });
  
  it('element wrap when inline-block width exceeds its container', async() => {
    const container = createElement('div', {
      style: {
        "display": "inline-block",
        "padding": "10px 300px",
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            backgroundColor: 'yellow'
        }
      }),
      createElement('div', {
        style: {
            display: 'inline-block',
            width: '50px',
            height: '50px',
            backgroundColor: 'red'
        }
      })
    ]);
  
    document.body.appendChild(container);
    await snapshot();
  });
});
