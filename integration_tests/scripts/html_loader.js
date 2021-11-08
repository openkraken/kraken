const filepath = require('path');
var HTMLParser = require('node-html-parser');

const SCRIPT = 'script';

let filename = '';
const scripts = [];

const traverseParseHTML = (ele) => {
  ele.childNodes && ele.childNodes.forEach(e => {
    if (e.rawTagName === SCRIPT) {
      e.childNodes.forEach(item => {
        if (item.nodeType === 3) {
          scripts.push(item._rawText);
        }
      })
    }
    traverseParseHTML(e);
  });
}

const loader = function(source) {
  const opts = this.query || {};
  const snapshotFilepath = filepath.relative(
    opts.workspacePath,
    filepath.join(
      opts.snapshotPath,
      filepath.relative(opts.testPath, filename),
    )
  );

  traverseParseHTML(HTMLParser.parse(source));

  return `
    describe(${snapshotFilepath}, async (done) => {
      window.html_snapshot = async (...argv) => {
        if (argv.length === 0) {
          await snapshot(null, '${snapshotFilepath}');
        } else if (argv.length === 1) {
          await snapshot(argv[0], '${snapshotFilepath}');
        }
      };
      __kraken_parse_html__('${source.replace(/\n/g, '').replace(/'/g, '"')}');
      ${scripts.map(script => script)}
    });
  `;
}

loader.pitch = (f) => {
  filename = f;
}

module.exports = loader;
