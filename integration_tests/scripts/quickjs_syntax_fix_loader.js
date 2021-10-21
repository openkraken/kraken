
// Quickjs has parsing issue when await expression
// add an semicolon before await to avoid this problems
// https://github.com/bellard/quickjs/issues/77
module.exports = function(source) {
  let replacePattern = /\n\s+(await.+);/g;
  source = source.replace(replacePattern, '\n;($1);\n');
  return source;
}
