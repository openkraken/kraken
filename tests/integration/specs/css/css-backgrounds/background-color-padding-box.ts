describe('Background-color-padding-box', function() {
  const divStyle = {
    width: '250px',
    height: '250px',
    padding: '10px',
    backgroundImage:
      'url("https://kraken.oss-cn-hangzhou.aliyuncs.com/images/blue_color.png"), url("https://kraken.oss-cn-hangzhou.aliyuncs.com/images/orange_color.png"), url("support/white_color.png")',
    'background-repeat': 'no-repeat',
    'background-clip': 'border-box, border-box, padding-box',
    'background-position': '30px 30px, 60px 60px, 90px 90px',
    'background-color': 'black',
  };
  xit('basic', async () => {
    let parent = createElement('div', {
      ...divStyle,
      width: '290px',
      backgroundColor: 'green',
    });
    let div = createElement('div', divStyle);
    append(parent, div);
    append(BODY, parent);
    await matchScreenshot();
  });
});
