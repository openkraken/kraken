const { declare } = require('@babel/helper-plugin-utils');
const { types } = require('@babel/core');
const filepath = require('path');

module.exports = declare((api, opts) => {
  api.assertVersion(7);

  return {
    name: 'transform-snapshot',

    visitor: {
      CallExpression: function (path, file) {
        const filename = file.filename;
        const callee = path.get('callee');
        if (callee.node.name == 'snapshot') {
          const args = callee.container.arguments;
          const snapshotFilepath =
          filepath.relative(
            opts.workspacePath,
            filepath.join(
              opts.snapshotPath,
              filepath.relative(opts.testPath, filename),
            )
          );

          if (args.length == 0) {
            // snapshot() => snapshot(null, filename)
            args.push(types.nullLiteral());
            args.push(types.stringLiteral(snapshotFilepath));
          } else if (args.length == 1) {
            // snapshot(0.1) => snapshot(0.1, filename)
            args.push(types.stringLiteral(snapshotFilepath));
          }
        }
      },
    },
  };
});
