describe('FontSize', () => {
  it('should work with english', () => {
    const p1 = create('p', {
      fontSize: '24px',
    }, createText('These text should be 24px.'));
    append(BODY, p1);

    return matchScreenshot();
  });

  it('should work with chinese', () => {
    const p1 = create('p', {
      fontSize: '24px',
    }, createText('24号字。'));
    append(BODY, p1);

    return matchScreenshot();
  });

  it('should work with less than 12px', () => {
    const p1 = create('p', {
      fontSize: '12px',
    }, createText('These lines should with 12px text size.'));
    const p2 = create('p', {
      fontSize: '5px',
    }, createText('These lines should with 5px text size.'));

    append(BODY, p1);
    append(BODY, p2);

    return matchScreenshot();
  });
});
