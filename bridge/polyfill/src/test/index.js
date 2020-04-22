const jasmineCore = require('./jasmine.js');
const ConsoleReporter = require('./console-reporter');
const jasmine = jasmineCore.core(jasmineCore);
const env = jasmine.getEnv({ suppressLoadErrors: true });
const jasmineInterface = jasmineCore.interface(jasmine, env);
const environment = __kraken_environment__();
const global = globalThis;

let timers = [];

const oldSetTimeout = setTimeout;
const oldSetInterval = setInterval;

// when spec is done, all pending timer should force to stop and never invoke.
function clearAllTimer() {
  timers.forEach((timer, index) => {
    if (timer != null) {
      clearTimeout(timer);
      timers[index] = null;
    }
  });
}

global.setTimeout = function (fn, timeout) {
  let index;
  let timer = oldSetTimeout(() => {
    // if this timer is canceled, just return.
    if (timers[index] == null) {
      return;
    }
    timers[index] = null;
    fn();
  }, timeout);
  index = timers.push(timer) - 1;
  return timer;
};

global.setInterval = function (fn, timeout) {
  let index;
  let timer = oldSetInterval(() => {
    // if this timer is canceled, just return.
    if (timers[index] == null) {
      return;
    }
    fn();
  }, timeout);
  index = timers.push(timer) - 1;
  return timer;
};

class JasmineTracker {
  onJasmineStarted() { }
  onJasmineDone() { }
  onSpecDone() { }

  jasmineStarted(result) {
    return this.onJasmineStarted(result);
  }

  jasmineDone(result) {
    return this.onJasmineDone(result);
  }

  specDone(result) {
    return this.onSpecDone(result);
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
  failFast: environment.KRAKEN_STOP_ON_FAIL === 'true',
  random: false
};

function HtmlSpecFilter(options) {
  var filterString =
    options &&
    options.filterString() &&
    options.filterString().replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
  var filterPattern = new RegExp(filterString);

  this.matches = function (specName) {
    return filterPattern.test(specName);
  };
}

var specFilter = new HtmlSpecFilter({
  filterString() {
    return environment.KRAKEN_TEST_FILTER;
  }
});

config.specFilter = function (spec) {
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
  jasmineTracker.onSpecDone = (result) => {
    return new Promise((resolve, reject) => {
      try {
        clearAllTimer();
        requestAnimationFrame(() => {
          __kraken_refresh_paint__(function (e) {
            if (e) {
              reject(e);
            } else {
              resolve();
            }
          });
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
