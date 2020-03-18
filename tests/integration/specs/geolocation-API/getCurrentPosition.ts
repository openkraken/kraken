xdescribe('Geolocation getCurrentPosition', function() {
  it('001', done => {
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
