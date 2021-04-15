describe('FontWeight', () => {
  const WEIGHTS = [
    'normal',
    'medium',
    'light',
    'bold',
    'lighter',
    'bolder',
    'alibaba',
    1,
    100,
    100.6,
    123,
    200,
    300,
    321,
    400,
    500,
    600,
    700,
    800,
    900,
    1000,
    10000,
  ];

  WEIGHTS.forEach(value => {
    it(`should work with ${value}`, () => {
      const p1 = createElementWithStyle(
        'p',
        {
          fontSize: '24px',
          fontWeight: value,
        },
        createText(`These text weight should be ${value}.`)
      );
      const p2 = createElementWithStyle(
        'p',
        {
          fontSize: '24px',
          fontWeight: value,
        },
        createText(`文本的 fontWeight 是: ${value}`)
      );
      append(BODY, p1);
      append(BODY, p2);

      return snapshot();
    });
  });
});
