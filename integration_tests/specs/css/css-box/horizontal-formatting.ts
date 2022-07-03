// https://www.w3.org/Style/CSS/Test/CSS1/current/sec412.htm
describe('Horizontal formatting', () => {
  it('basic', async () => {
    const rulerStyle = {
      padding: '0px',
      margin: '0px',
      borderWidth: '0px',
    };

    const topRuler = document.createElement('div');
    const ruleImg = document.createElement('img');

    ruleImg.setAttribute(
      'src',
      'assets/scaleplate.png'
    );

    setElementStyle(ruleImg, {
      width: '641px',
      height: '20px',
    });

    let ruleImgP = new Promise((resolve, reject) => {
      ruleImg.onload = () => {
        resolve();
      };
    });

    setElementStyle(topRuler, rulerStyle);
    setElementStyle(ruleImg, rulerStyle);
    topRuler.appendChild(ruleImg);

    const p = document.createElement('p');
    const text = document.createTextNode(
      'This text is inside a P element. The border, padding, and margins for this paragraph should line up with the boundaries denoted in the image below; the edges of the light blue background should line up with the boundary between "padding" and "border." There should be no top or bottom margin; the images above and below should be flush with this paragraph.'
    );
    p.appendChild(text);

    setElementStyle(p, {
      backgroundColor: 'aqua',
      width: '560px',
      borderStyle: 'solid',
      borderColor: 'silver',
      borderTopWidth: '0px',
      borderBottomWidth: '0px',
      borderLeftWidth: '40px',
      borderRightWidth: '40px',
      paddingLeft: '40px',
      paddingRight: '40px',
      marginTop: '0px',
      marginBottom: '0px',
      marginLeft: '40px',
      marginRight: '40px',
    });

    const bottomRuler = document.createElement('div');
    const ruleImg2 = document.createElement('img');

    ruleImg2.setAttribute(
      'src',
      'assets/content-area.png'
    );
    setElementStyle(ruleImg2, {
      width: '640px',
      height: '64px',
    });

    let ruleImg2P = new Promise((resolve) => {
      ruleImg2.onload = () => {
        resolve();
      };
    });

    setElementStyle(bottomRuler, rulerStyle);
    setElementStyle(ruleImg2, rulerStyle);

    bottomRuler.appendChild(ruleImg2);

    document.body.appendChild(topRuler);
    document.body.appendChild(p);
    document.body.appendChild(bottomRuler);

    await Promise.all([ruleImgP, ruleImg2P]);
    await snapshot();
  });
});
