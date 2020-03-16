it('geolocation', () => new Promise((resolve, reject) => {
  navigator.geolocation.getCurrentPosition((position) => {
    console.log(position.coords);
    assert.equal(typeof position.coords, 'object');
    resolve(position);
  }, (err) => {
    reject(err);
  })
}));