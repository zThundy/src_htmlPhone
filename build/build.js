require('./check-versions')()

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

    console.log(chalk.cyan('  HEY HO FINITO UPPAMI!!11!!111!.\n'))
    // console.log(chalk.yellow(
    //   '  Tip: built files are meant to be served over an HTTP server.\n' +
    //   '  Opening index.html over file:// won\'t work.\n'
    // ))
    
    // let path = 'C:/Users/anton/Desktop/src_htmlPhone/resource/zth_gcphone/html/static/js/app.js'
    // ObfuscateFile(path, "app.js", () => {
    // })

    // disabilito la doppia obfuscazione che tanto
    // è inutile per ora
    // setTimeout(() => {
    //   ObfuscateFile()
    // }, 3500)
  })
})

function makeid(length) {
  var result = [];
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;
  for (var i = 0; i < length; i++) {
    result.push(characters.charAt(Math.floor(Math.random() * charactersLength)));
  }
  return result.join('');
}

function ObfuscateFile(path, file, cb) {
  var obf = ora('METTENDOLO IN CULO AI DUMPER (' + file + ') ...')
  obf.start()

  setTimeout(() => {
    fs.readFile(path, "utf8", function(err, data) {
      if (err) { return console.log(err) }
  
      // Obfuscate content of the JS file
      // var obfuscationResult = JavaScriptObfuscator.obfuscate(data, options);
      var newseed = makeid(50)
      var obfuscationResult = JavaScriptObfuscator.obfuscate(data, {
        selfDefending: true,
        numbersToExpressions: true,
        shuffleStringArray: true,
        splitStrings: true,

        stringArray: true,
        stringArrayEncoding: ['base64'],
        stringArrayIndexShift: true,

        deadCodeInjection: true,
        seed: newseed
      });
      
      // Write the obfuscated code into a new file
      fs.writeFile(path, obfuscationResult.getObfuscatedCode(), function(err) {
        if (err) { return console.log(err) }
        
        obf.stop()
        console.log(chalk.cyan('  FILE OFFUSCATO (' + file + '). FANCULO DUMPERS.\n  SEED GENERATO: ' + newseed))
        if (cb) cb();
      });
    });
  }, 2500)
}
