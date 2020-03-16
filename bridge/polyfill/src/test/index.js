const { EventEmitter } = require('events');
const jasmineCore = require('./jasmine.js');
const ConsoleReporter = require('./console_reporter');
const jasmine = jasmineCore.core(jasmineCore);
const env = jasmine.getEnv({ suppressLoadErrors: true });
const jasmineInterface = jasmineCore.interface(jasmine, env);

class JasmineTracker extends EventEmitter {
  constructor() {
    super();
    this.onJasmineStarted = () => { };
    this.onJasmineDone = () => { };
    this.onSpecStarted = () => { };
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

// @NOTE: Hack for kraken js engine have no stdout.
function createPrinter(logger) {
  let stdoutMessage = '';
  return function printToStdout(msg) {
    for (let w of msg) {
      if (w === '\n') {
        logger(stdoutMessage);
        stdoutMessage = '';
      } else {
        stdoutMessage += w;
      }
    }
  }
}

consoleReporter.setOptions({
  timer: new jasmine.Timer(),
  print: createPrinter(console.log),
  printError: createPrinter(console.error),
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
      __request_update_frame__();
      __kraken_refresh_paint__(function () {
        resolve();
      });
    });
  };

  jasmineTracker.onJasmineDone = (result) => {
    done(result.overallStatus);
  };

  env.execute();
});
