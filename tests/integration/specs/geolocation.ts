describe('Geolocation', () => {
  it('geolocation', done => {
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
