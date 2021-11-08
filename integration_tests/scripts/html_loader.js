module.exports = function(source) {
  return `
    it('htmltest', async () => {
      __kraken_parse_html__('${source.replace(/\n/g, '').replace(/'/g, '"')}');
      await snapshot();
    });
  `;
}
