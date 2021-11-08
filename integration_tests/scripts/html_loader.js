module.exports = function(source) {
  return `
    it('htmltest', async () => {
      parseTestHTML('${source.replace(/\n/g, '').replace(/'/g, '"')}');
      await snapshot();
    });
  `;
}
