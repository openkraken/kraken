const {EventEmitter} = require('events');
const jasmineCore = require('./jasmine.js');
const ConsoleReporter = require('jasmine/lib/reporters/console_reporter');
const jasmine = jasmineCore.core(jasmineCore);
const env = jasmine.getEnv({suppressLoadErrors: true});
const jasmineInterface = jasmineCore.interface(jasmine, env);

class JasmineTracker extends EventEmitter {
  constructor() {
    super();
    this.onJasmineStarted = () => {};
    this.onJasmineDone = () => {};
    this.onSpecStarted = () => {};
  }

  jasmineStarted(result) {
    return this.onJasmineStarted(result);
  }

  jasmineDone(result) {
    return this.onJasmineDone(result);
  }

  specStarted(result) {
    return this.onSpecStarted(result);
  }
}

const consoleReporter = new ConsoleReporter();
const jasmineTracker = new JasmineTracker();

let printCache = '';
function handlePrint(msg) {
  for (let w of msg) {
    if (w === '\n') {
      console.log(printCache);
      printCache = '';
    } else {
      printCache += w;
    }
  }
}

consoleReporter.setOptions({
  timer: new jasmine.Timer(),
  print: (msg) => {
    handlePrint(msg);
  },
  showColors: true,
  random: false,
  jasmineCorePath: 'internal://'
});

env.addReporter(consoleReporter);
env.addReporter(jasmineTracker);
Object.assign(global, jasmineInterface);

__kraken_executeTest__((done) => {
  jasmineTracker.onSpecStarted = (result) => {
    return new Promise((resolve, reject) => {
      __kraken_refresh_paint__(function() {
        resolve();
      });
    });
  };

  jasmineTracker.onJasmineDone = (result) => {
    done(result.overallStatus);
  };

  env.execute();
});