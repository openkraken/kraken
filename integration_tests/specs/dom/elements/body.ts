describe('body', () => {
  it('should exist', async () => {
    expect(document.body).toBeDefined();
    expect(document.body.appendChild).toBeDefined();
  });
});
