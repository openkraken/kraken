const path = require('path');
const HTMLParser = require('node-html-parser');

const SCRIPT = 'script';

let filename = '';
const scripts = [];

const traverseParseHTML = (ele) => {
  ele.childNodes && ele.childNodes.forEach(e => {
    if (e.rawTagName === SCRIPT) {
      e.childNodes.forEach(item => {
        // TextNode of script element.
        if (item.nodeType === 3) {
          scripts.push(item._rawText);
        }
        // Delete content of script element for avoid to  script repetition.
        item._rawText = '';
      })
    }
    traverseParseHTML(e);
  });
}

const loader = function(source) {
  const opts = this.query || {};
  const snapshotFilepath = path.relative(
    opts.workspacePath,
    path.join(
      opts.snapshotPath,
      path.relative(opts.testPath, filename),
    )
  );

  let root = HTMLParser.parse(source);
  traverseParseHTML(root);
  
  // Set attr of HTML can let the case use fit. For example: <html fit> xxx </html>.
  let isFit = false;
  root.childNodes && root.childNodes.forEach(ele => {
    if (ele.rawAttrs && ele.rawAttrs.indexOf('fit') >= 0) {
      isFit = true;
    }
  })

  const htmlString = root.toString().replace(/\n/g, '');

  return `
    describe('html-${path.basename(filename)}', () => {
      // Use html_snapshot to snapshot in html file.
      const html_snapshot = async (...argv) => {
        if (argv.length === 0) {
          await snapshot(null, '${snapshotFilepath}');
        } else if (argv.length === 1) {
          await snapshot(argv[0], '${snapshotFilepath}');
        }
      };

      // Use html_parse to parser html in html file.
      const html_parse = () => __kraken_parse_html__('${htmlString}');

      ${isFit ? 'fit' : 'it'}("should work", async () => {\
        html_parse();\
        ${scripts.length === 0 ? 'await html_snapshot();' : scripts.join('\n')}
      })
    });
  `;
};

loader.pitch = (f) => {
  filename = f;
};

module.exports = loader;
