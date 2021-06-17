const path = require('path');
const bableTransformSnapshotPlugin = require('./scripts/babel_transform_snapshot');
const generateEntryFile = require('./scripts/generate_entry_file');

const context = path.join(__dirname);
const runtimePath = path.join(context, 'runtime');
const buildPath = path.join(context, '.specs');
const testPath = path.join(context, 'specs');
const snapshotPath = path.join(context, 'snapshots');

generateEntryFile();

module.exports = {
  context: context,
  mode: 'development',
  devtool: false,
  entry: './specs/index.ts',
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
        use: {
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
        }
      }
    ],
  },
  devServer: {
    hot: false,
    inline: false,
  },
};
