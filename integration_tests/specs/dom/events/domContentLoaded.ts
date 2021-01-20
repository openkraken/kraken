let fired = false;

window.addEventListener('DOMContentLoaded', () => {
  fired = true;
});

describe('DOMContentLoaded', () => {
  it('should fired', () => {
    expect(fired).toBe(true);
  });
});
