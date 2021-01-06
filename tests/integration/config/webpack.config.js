const path = require('path');
const glob = require('glob');

const context = path.join(__dirname, '..');
const files = glob.sync('specs/**/*.{js,ts}', {
  cwd: context,
  ignore: 'node_modules/**',
}).map((file) => './' + file);
files.unshift('./global');

module.exports = {
  context: context,
  mode: 'development',
  devtool: false,
  entry: files,
  output: {
    path: path.join(context, '.specs'),
    filename: 'specs.build.js',
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json', '.ts', '.tsx'],
    alias: {
      '@vanilla-jsx': path.join(context, 'runtime'),
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
            presets: [
              ['@babel/preset-env', { 
                targets: {
                  chrome: 86,
                },
                useBuiltIns: 'usage',
                corejs: 3,
               }],
              ['@babel/preset-typescript', { isTSX: true, allExtensions: true }],
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
