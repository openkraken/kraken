const filepath = require('path');

let filename = '';

const loader = function(source) {
  const opts = this.query || {};
  const snapshotFilepath = filepath.relative(
    opts.workspacePath,
    filepath.join(
      opts.snapshotPath,
      filepath.relative(opts.testPath, filename),
    )
  );

  return `
    describe(${snapshotFilepath}, async (done) => {
      window.html_snapshot = async (...argv) => {
        console.log('window.html_snapshot')
        if (argv.length === 0) {
          await snapshot(null, '${snapshotFilepath}');
        } else if (argv.length === 1) {
          await snapshot(argv[0], '${snapshotFilepath}');
        }
      };
      __kraken_parse_html__('${source.replace(/\n/g, '').replace(/'/g, '"')}');
    });
  `;
}

loader.pitch = (f) => {
  filename = f;
}

module.exports = loader;