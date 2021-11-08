const path = require('path');
const glob = require('glob');
const bableTransformSnapshotPlugin = require('./scripts/babel_transform_snapshot');

const context = path.join(__dirname);
const runtimePath = path.join(context, 'runtime');
const globalRuntimePath = path.join(context, 'runtime/global');
const resetRuntimePath = path.join(context, 'runtime/reset');
const buildPath = path.join(context, '.specs');
const testPath = path.join(context, 'specs');
const snapshotPath = path.join(context, 'snapshots');
const coreSpecFiles = glob.sync('specs/**/*.{js,jsx,ts,tsx,html}', {
  cwd: context,
  ignore: ['node_modules/**'],
}).map((file) => './' + file).filter(name => name.indexOf('plugins') < 0);

const pluginSpecFiles =  glob.sync('specs/plugins/**/*.{js,jsx,ts,tsx}', {
  cwd: context,
  ignore: 'node_modules/**',
}).map((file) => './' + file);

// Add global vars
coreSpecFiles.unshift(globalRuntimePath);
coreSpecFiles.unshift(resetRuntimePath);
pluginSpecFiles.unshift(globalRuntimePath);
pluginSpecFiles.unshift(resetRuntimePath);

module.exports = {
  context: context,
  mode: 'development',
  devtool: false,
  entry: {
    core: coreSpecFiles,
    plugin: pluginSpecFiles
  },
  output: {
    path: buildPath,
    filename: '[name].build.js',
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
        test: /\.(html?)$/i,
        exclude: /node_modules/,
        use: [
          {
            loader: path.resolve('./scripts/html_loader'),
            options: {
              workspacePath: context,
              testPath,
              snapshotPath,
            }
          }
        ]
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
