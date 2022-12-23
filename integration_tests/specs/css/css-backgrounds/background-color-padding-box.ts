describe('Background-color-padding-box', function() {
  const divStyle = {
    width: '250px',
    height: '250px',
    padding: '10px',
    backgroundImage:
      'url("assets/orange_color.png"), url("assets/white_color.png")',
    'background-repeat': 'no-repeat',
    'background-clip': 'border-box, border-box, padding-box',
    'background-position': '30px 30px, 60px 60px, 90px 90px',
    'background-color': 'black',
  };

  // @TODO: Support multiple background-image
  xit('basic', async () => {
    let parent = createElementWithStyle('div', {
      ...divStyle,
      width: '290px',
      backgroundColor: 'green',
    });
    let div = createElementWithStyle('div', divStyle);
    append(parent, div);
    append(BODY, parent);
    await snapshot();
  });
});
