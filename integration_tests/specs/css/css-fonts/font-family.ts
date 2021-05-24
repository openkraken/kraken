describe('FontFamily', () => {
  it('should works in english', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('should works in chinese', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });
});
