// Authority require, which will pending tests, disable it.
xdescribe('Geolocation', () => {
  it('getCurrentPosition', done => {
    navigator.geolocation.getCurrentPosition(
      position => {
        expect(typeof position.coords).toBe('object');
        done();
      },
      err => {
        done.fail();
      }
    );
  });
});
