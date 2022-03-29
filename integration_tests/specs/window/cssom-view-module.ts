// https://drafts.csswg.org/cssom-view
describe('CSSOM View Module', () => {
  it('innerWidth', () => {
    expect(window.innerWidth > 0).toEqual(true);
  });

  it('innerHeight', () => {
    expect(window.innerHeight > 0).toEqual(true);
  });

  // Custom added property.
  it('colorScheme', () => {
    expect(typeof window.colorScheme).toEqual('string');
  });
});
