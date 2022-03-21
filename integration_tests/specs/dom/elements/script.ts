
describe('script element', () => {
  it('should work with src', async (done) => {
    const p = <p>Should see hello below:</p>;
    document.body.appendChild(p);
    var x = document.createElement('script');
    x.src = 'assets://assets/hello.js';
    document.head.appendChild(x);
    x.onload = async () => {
      await snapshot();
      done();
    };
  });
});
