describe('FontStyle', () => {
  it('should works with normal', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontStyle: 'normal',
        fontSize: '32px',
      },
      createText('These text should in normal style.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontStyle: 'normal',
        fontSize: '32px',
      },
      createText('普通文本。')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('should works with italic', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontStyle: 'italic',
        fontSize: '32px',
      },
      createText('These text should in italic style.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontStyle: 'italic',
        fontSize: '32px',
      },
      createText('斜体文本。')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('should works with oblique', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontStyle: 'oblique',
        fontSize: '32px',
      },
      createText('These text should in oblique style.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontStyle: 'oblique',
        fontSize: '32px',
      },
      createText('倾斜体(oblique)文本。')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });
});
