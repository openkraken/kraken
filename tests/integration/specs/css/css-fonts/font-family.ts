describe('FontFamily', () => {
  it('should works in english', () => {
    const p1 = create(
      'p',
      {
        fontFamily: 'SimSun',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    const p2 = create(
      'p',
      {
        fontFamily: 'SimSun',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    append(BODY, p1);
    append(BODY, p2);

    return matchScreenshot();
  });

  it('should works in chinese', () => {
    const p1 = create(
      'p',
      {
        fontFamily: 'SimSun',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    const p2 = create(
      'p',
      {
        fontFamily: 'SimSun',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    append(BODY, p1);
    append(BODY, p2);

    return matchScreenshot();
  });
});
