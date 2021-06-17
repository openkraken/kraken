const fs = require('fs');
const path = require('path');
const glob = require('glob');

const entryFilePath = path.join(__dirname, '../specs/index.ts');

module.exports = function() {
  const entryFiles = glob.sync('**/*.{js,jsx,ts,tsx}', {
    cwd: path.join(__dirname, '../specs'),
    ignore: 'node_modules/**',
  }).map((file) => './' + file);

  // Add global vars
  entryFiles.unshift('../runtime/global.ts');
  entryFiles.unshift('../runtime/reset.ts');

  let template = `// @ts-nocheck
(async () => {
  ${entryFiles.map(p => `await import('${p.split('.ts')[0]}');`).join('\n  ')}
})();`;

  fs.writeFileSync(entryFilePath, template);
};
