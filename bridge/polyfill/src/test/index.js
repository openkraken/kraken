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

  specStarted(result) {
    return new Promise((resolve) => {
      requestAnimationFrame(resolve);
    });
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

function PointerChange() {}
PointerChange.cancel = 0;
PointerChange.add = 1;
PointerChange.remove = 2;
PointerChange.hover = 3;
PointerChange.down = 4;
PointerChange.move = 5;
PointerChange.up = 6;
global.PointerChange = PointerChange;

global.simulatePointer = function simulatePointer(list) {
  return new Promise((resolve) => {
    requestAnimationFrame(() => {
      if (!Array.isArray(list)) throw new Error('list should be an array');

      list.forEach((value, i) => {
        if (!Array.isArray(value)) throw new Error(`list[${i}] should be an array`);
        if (typeof value[0] != 'number') throw new Error(`list[${i}][0] should be an number`);
        if (typeof value[1] != 'number') throw new Error(`list[${i}][1] should be an number`);
        if (typeof value[2] != 'number') throw new Error(`list[${i}][2] should be an number`);
      });

      __kraken_simulate_pointer__(list);

      resolve();
    });
  });
}

global.simulateKeyPress = __kraken_simulate_keypress__;

function clearAllNodes() {
  while (document.body.firstChild) {
    document.body.firstChild.remove();
  }
}

function traverseNode(node, handle) {
  const shouldExit = handle(node);
  if (shouldExit) return;

  if (node.childNodes.length > 0) {
    for (let i = 0, l = node.childNodes.length; i < l; i++) {
      traverseNode(node.childNodes[i], handle);
    }
  }
}

function clearAllEventsListeners() {
  window.__clearListeners__();
  traverseNode(document.body, (node) => {
    node.__clearListeners__();
  });
}

__kraken_executeTest__((done) => {
  jasmineTracker.onSpecDone = (result) => {
    return new Promise((resolve, reject) => {
      try {
        if (window.notNeedInitEnv) {
          resolve();
        } else {
          clearAllTimer();
          clearAllEventsListeners();
          clearAllNodes();
          kraken.methodChannel.clearMethodCallHandler();
          requestAnimationFrame(() => {
            __kraken_refresh_paint__(function (e) {
              if (e) {
                reject(e);
              } else {
                resolve();
              }
            });
          });
        }
      } catch (e) {
        console.log(e);
        reject(e);
      }
    });
  };

  jasmineTracker.onJasmineDone = (result) => {
    done(result.overallStatus);
  };

  env.execute();
});
