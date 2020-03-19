const { EventEmitter } = require('events');
const jasmineCore = require('./jasmine.js');
const ConsoleReporter = require('./console_reporter');
const jasmine = jasmineCore.core(jasmineCore);
const env = jasmine.getEnv({ suppressLoadErrors: true });
const jasmineInterface = jasmineCore.interface(jasmine, env);

const environment = __kraken_environment__();

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

  specDone(result) {
    // Force update frames.
    __request_update_frame__();
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

let config = {
  oneFailurePerSpec: true,
  failFast: environment.KRAKEN_STOP_ON_FAIL !== 'false',
  random: false
};

function HtmlSpecFilter(options) {
  var filterString =
    options &&
    options.filterString() &&
    options.filterString().replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
  var filterPattern = new RegExp(filterString);

  this.matches = function(specName) {
    return filterPattern.test(specName);
  };
}

var specFilter = new HtmlSpecFilter({
  filterString: function() { return environment.KRAKEN_TEST_FILTER; }
});

config.specFilter = function(spec) {
  return specFilter.matches(spec.getFullName());
};

env.configure(config);

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
      try {
        __request_update_frame__();
        __kraken_refresh_paint__(function (e) {
          if (e) {
            reject(e);
          } else {
            resolve();
          }
        });
      } catch (e) {
        reject(e);
      }
    });
  };

  jasmineTracker.onJasmineDone = (result) => {
    done(result.overallStatus);
  };

  env.execute();
});
