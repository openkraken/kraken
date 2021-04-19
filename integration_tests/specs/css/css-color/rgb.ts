describe('Color RGB and RGBA', () => {

  const COLORS = [
    'rgb(0,255,0)',
    'rgb(0, 255, 0)',
    'rgb(255,0,255)',
    'rgb(0,255,    0  )',
    'rgba(0, 255, 0, 0.5)',
    'rgba(0, 255, 0, .5)',
  ];

  COLORS.forEach(value => {
    it(`should work with ${value}`, () => {
      const div = createElementWithStyle(
        'div',
        {
          width: '100px',
          height: '100px',
          backgroundColor: value,
        }
      );
      append(BODY, div);

      return snapshot(div);
    });
  });
});
