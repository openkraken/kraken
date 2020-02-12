module.exports = () => {
  const config = {
    mode: process.env['KRAKEN_WEBPACK_BUILD'] || 'none',
    entry: './src/index.ts',
    devServer: {
      hot: false,
      inline: false
    },
    resolve: {
      // Add `.ts` and `.tsx` as a resolvable extension.
      extensions: [".ts", ".tsx", ".js"]
    },
    module: {
      rules: [
        // all files with a `.ts` or `.tsx` extension will be handled by `ts-loader`
        { test: /\.tsx?$/, loader: "ts-loader" }
      ]
    },
    plugins: [
    ],
  };
  return config;
};
