// http://eslint.org/docs/user-guide/configuring

module.exports = {
  root: true,
  parser: 'babel-eslint',
  parserOptions: {
    sourceType: 'module'
  },
  env: {
    browser: true,
  },
  // https://github.com/feross/standard/blob/master/RULES.md#javascript-standard-style
  extends: 'standard',
  // required to lint *.vue files
  plugins: [ 'html' ],
  // add your custom rules here
  'rules': {
    // allow paren-less arrow functions
    'arrow-parens': 0,
    // allow async-await
    'generator-star-spacing': 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0,
    // ignore parentesys spaces after function like switch()
    'keyword-spacing': "off",
    'comma-dangle': "off",
    'no-unused-vars': "warn",
    'quotes': "off",
    'no-redeclare': "off",
    "space-before-function-paren": "off",
    "eol-last": "off",
    "no-trailing-spaces": "off",
    "curly": "off",
    "no-unreachable": "warn",
    "semi": "off"
  }
}
