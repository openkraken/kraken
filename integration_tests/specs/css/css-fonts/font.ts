
describe('Font', () => {
  it('shorthand', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        font: '12px "sans-serif"',
      },
      createText('font: 12px "sans-serif"')
    );
    
    const p2 = createElementWithStyle(
      'p',
      {
        font: 'italic 14px serif',
      },
      createText('font: italic 22px serif')
    );
    
    const p3 = createElementWithStyle(
      'p',
      {
        font: 'italic bold 16px/2 cursive',
      },
      createText('font: italic bold 16px/2 cursive')
    );
    
    const p4 = createElementWithStyle(
      'p',
      {
        font: 'normal 600 18px fantasy',
      },
      createText('font: normal 600 18px fantasy')
    );
    
    const p5 = createElementWithStyle(
      'p',
      {
        font: 'italic 20px monospace',
      },
      createText('font: italic 20px monospace')
    );
    
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, p5);

    return snapshot();
  });

  it('should work with font-style before font-weight', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: 'italic 600 20px monospace',
        }
      },
      createText('font-style before font-weight works')
    );
    
    append(BODY, div);

    return snapshot();
  });

  it('should work with font-style after font-weight', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '600 italic 20px monospace',
        }
      },
      createText('font-style after font-weight works')
    );
    
    append(BODY, div);

    return snapshot();
  });
  
  it('should not work with font-style after font-size', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '20px/40px italic',
        }
      },
      createText('font-style not work and font size works')
    );
    
    append(BODY, div);

    return snapshot();
  });

  it('should not work with font-weight after font-size', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '20px/40px 600 monospace',
        }
      },
      createText('font-weight after font-size not work')
    );
    
    append(BODY, div);

    return snapshot();
  });
  
  it('should work with line-height of px', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '20px/40px monospace',
        }
      },
      createText('line-height of px works')
    );
    
    append(BODY, div);

    return snapshot();
  });

  it('should work with line-height of number', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '20px/2.5 monospace',
        }
      },
      createText('line-height of number works')
    );
    
    append(BODY, div);

    return snapshot();
  });

  it('should work with both font-size and font-weight', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '20px monospace',
        }
      },
      createText('font-size and font-weight works')
    );
    
    append(BODY, div);

    return snapshot();
  });
  
  it('should not work with no font-size', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '600 monospace',
        }
      },
      createText('no font-size not work')
    );
    
    append(BODY, div);

    return snapshot();
  });

  it('should not work with no font-family', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: '20px',
        }
      },
      createText('no font-family not work')
    );
    
    append(BODY, div);

    return snapshot();
  });

  it('should not work with font-size after font-family', () => {
    const div = createElement('div',
      {
        style: {
          width: '200px',
          height: '100px',
          margin: '10px',
          backgroundColor: 'green',
          font: 'monospace 20px',
        }
      },
      createText('font-size after font-family not work')
    );
    
    append(BODY, div);

    return snapshot();
  });
});
