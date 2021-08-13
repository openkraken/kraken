const path = require('path');
const glob = require('glob');
const bableTransformSnapshotPlugin = require('./scripts/babel_transform_snapshot');
const quickjsSyntaxFixLoader = require('./scripts/quickjs_syntax_fix_loader');

const context = path.join(__dirname);
const runtimePath = path.join(context, 'runtime');
const globalRuntimePath = path.join(context, 'runtime/global');
const resetRuntimePath = path.join(context, 'runtime/reset');
const buildPath = path.join(context, '.specs');
const testPath = path.join(context, 'specs');
const snapshotPath = path.join(context, 'snapshots');
// const entryFiles = glob.sync('specs/**/*.{js,jsx,ts,tsx}', {
//   cwd: context,
//   ignore: 'node_modules/**',
// }).map((file) => './' + file);
const entryFiles = [
  './specs/dom/nodes/append-child.tsx',
  './specs/dom/nodes/clone-node.ts',
  './specs/timer/timer.ts',
  './specs/dom/nodes/document.ts',
  './specs/dom/nodes/element.ts',
  './specs/dom/nodes/event-target.ts',
  './specs/dom/nodes/get-element-by-id.ts',
  './specs/dom/nodes/get-element-by-tag-name.ts',
  './specs/dom/nodes/insert-before.ts',
  './specs/dom/nodes/node.ts'
];

// Add global vars
entryFiles.unshift(globalRuntimePath);
entryFiles.unshift(resetRuntimePath);

module.exports = {
  context: context,
  mode: 'development',
  devtool: false,
  entry: entryFiles,
  output: {
    path: buildPath,
    filename: 'specs.build.js',
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json', '.ts', '.tsx'],
    alias: {
      '@vanilla-jsx': runtimePath,
    }
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: require.resolve('stylesheet-loader'),
      },
      {
        test: /\.(jsx?|tsx?)$/i,
        exclude: /node_modules/,
        use: [{
          loader: 'babel-loader',
          options: {
            plugins: [
              [
                bableTransformSnapshotPlugin,
                {
                  workspacePath: context,
                  testPath,
                  snapshotPath,
                }
              ]
            ],
            presets: [
              [
                '@babel/preset-env',
                {
                  targets: {
                    chrome: 76,
                  },
                  useBuiltIns: 'usage',
                  corejs: 3,
                }],
              [
                '@babel/preset-typescript',
                {
                  isTSX: true,
                  allExtensions: true
                }
              ],
              [
                '@babel/preset-react',
                {
                  throwIfNamespace: false,
                  runtime: 'automatic',
                  importSource: '@vanilla-jsx'
                }
              ]
            ]
          }
        }, {
          loader: path.resolve('./scripts/quickjs_syntax_fix_loader'),
        }]
      }
    ],
  },
  devServer: {
    hot: false,
    inline: false,
  },
};
