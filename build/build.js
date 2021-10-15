process.env.NODE_ENV = 'production'

var ora = require('ora')
var rm = require('rimraf')
var fs = require("fs");
var path = require('path')
var chalk = require('chalk')
var webpack = require('webpack')
var config = require('../config')
var webpackConfig = require('./webpack.prod.conf')

var spinner = ora('HEY STO BUILDANDO...')
spinner.start()

var JavaScriptObfuscator = require('javascript-obfuscator');
var UglifyJS = require("uglify-js");

/*
var options = {
  compact: true,
  controlFlowFlattening: false,
  controlFlowFlatteningThreshold: 0.75,
  deadCodeInjection: false,
  deadCodeInjectionThreshold: 0.4,
  debugProtection: false,
  debugProtectionInterval: false,
  disableConsoleOutput: false,
  domainLock: [],
  log: false,
  mangle: false,
  renameGlobals: false,
  reservedNames: [],
  rotateStringArray: true,
  seed: 0,
  selfDefending: false,
  sourceMap: false,
  sourceMapBaseUrl: '',
  sourceMapFileName: '',
  sourceMapMode: 'separate',
  stringArray: true,
  stringArrayEncoding: false,
  stringArrayThreshold: 0.75,
  target: 'browser',
  unicodeEscapeSequence: false
}
*/

const minifyFiles = ["app.js", "vendor.js", "manifest.js"]
// const objuscateFiles = ["app.js"]
const objuscateFiles = []

rm(path.join(config.build.assetsRoot, config.build.assetsSubDirectory), err => {
  if (err) throw err
  webpack(webpackConfig, function (err, stats) {
    spinner.stop()
    if (err) throw err
    process.stdout.write(stats.toString({
      colors: true,
      modules: false,
      children: false,
      chunks: false,
      chunkModules: false
    }) + '\n\n')
    console.log(chalk.cyan('Building completato, modifica dei file in corso...\n'))
    minifyFiles.forEach(file => {
      let path = config.build.assetsRoot + '/static/js/' + file
      MinifyFile(path, file, () => {
        if (objuscateFiles.includes(file)) ObfuscateFile(path, file)
      })
    })
  })
})

function makeid(length) {
  var result = [];
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;
  for (var i = 0; i < length; i++) result.push(characters.charAt(Math.floor(Math.random() * charactersLength)));
  return result.join('');
}

function MinifyFile(path, file, cb) {
  var min = ora('Minifying del file in corso (' + file + ') ...')
  min.start()
  fs.readFile(path, "utf8", function(err, data) {
    if (err) { return console.log(err) }
    var code = UglifyJS.minify(data, { mangle: { toplevel: true } }).code
    fs.writeFile(path, code, function(err) {
      if (err) { return console.log(err) }
      min.stop()
      console.log(chalk.cyan('Minifying del file completato (' + file + ').'))
      if (cb) cb();
    });
  });
}

function ObfuscateFile(path, file, cb) {
  var obf = ora('Offuscamento del file in corso (' + file + ') ...')
  obf.start()
  fs.readFile(path, "utf8", function(err, data) {
    if (err) { return console.log(err) }
    // Obfuscate content of the JS file
    var newseed = makeid(50)
    var obfuscationResult = JavaScriptObfuscator.obfuscate(data, {
      selfDefending: true,
      numbersToExpressions: true,
      shuffleStringArray: true,
      splitStrings: true,

      stringArray: true,
      stringArrayEncoding: ['base64'],
      stringArrayIndexShift: true,
      rotateStringArray: true,

      deadCodeInjection: true,
      seed: newseed,
      disableConsoleOutput: true,
      compact: true
    });
    
    // Write the obfuscated code into a new file
    fs.writeFile(path, obfuscationResult.getObfuscatedCode(), function(err) {
      if (err) { return console.log(err) }
      obf.stop()
      console.log(chalk.cyan('Offuscamento del file completato (' + file + ').\nSeed generato: ' + newseed))
      if (cb) cb();
    });
  });
}
