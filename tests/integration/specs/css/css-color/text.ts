fdescribe('Color text', () => {
  function testColor(name: string, rgb: string, colorName: string, decimal: string) {
    it(name, async () => {
      let container = create('div', {});
      let p1 = create('p', {
        color: rgb
      });
      let p2 = create('p', {
        color: colorName
      });
      let p3 = create('p', {
        color: decimal
      });
      let t1 = createText('helloworld');
      let t2 = createText('helloworld');
      let t3 = createText('helloworld');
      append(p1, t1);
      append(p2, t2);
      append(p3, t3);
      append(container, p1);
      append(container, p2);
      append(container, p3);
      append(BODY, container);
      await matchScreenshot(container);
    });
  }


  testColor('black', 'rgb(0,0,0)', 'black', '#000000');
  testColor('white', 'rgb(255,255,255)', 'white', '#ffffff');
  testColor('red', 'rgb(255,0,0)', 'red', '#ff0000');
  testColor('lime', 'rgb(0,255,0)', 'lime', '#00ff00');
  testColor('blue', 'rgb(0,0,255)', 'blue', '#0000ff');
  testColor('yellow', 'rgb(255,255,0)', 'yellow', '#ffff00');
  testColor('cyan', 'rgb(0,255,255)', 'cyan', '#00ffff');
  testColor('magenta', 'rgb(255,0,255)', 'magenta', '#ff00ff');
  testColor('sliver', 'rgb(192,192,192)', 'sliver', '#c0c0c0');
  testColor('gray', 'rgb(128,128,128)', 'gray', '#808080');
  testColor('maroon', 'rgb(128,0,0)', 'maroon', '#800000');
  testColor('olive', 'rgb(128,128,0)', 'olive', '#808000');
  testColor('green', 'rgb(0,128,0)', 'green', '#008000');
  testColor('purple', 'rgb(128,0,128)', 'purple', '#800080');
  testColor('teal', 'rgb(0,128,128)', 'teal', '#008080');
  testColor('navy', 'rgb(0,0,128)', 'navy', '#000080');

  it('blue border', async () => {
    let test = create('div', {
      border: '5px solid blue',
      width: '100px',
      height: '100px'
    });
    let div = create('div', {
      borderBottomStyle: 'solid',
      borderBottomWidth: '1px',
      borderBottomColor: '#1000',
      height: 0,
      width: '100px'
    });
    append(test, div);
    append(BODY, test);
    await matchScreenshot(test);
  });

});