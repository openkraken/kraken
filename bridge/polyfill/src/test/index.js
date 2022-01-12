const jasmineCore = require('./jasmine');
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

// https://jasmine.github.io/api/edge/Reporter.html
class JasmineTracker {
  onJasmineDone() { }

  jasmineDone(result) {
    return this.onJasmineDone(result);
  }

  specDone(result) {
    clearAllTimer();
    resetDocumentElement();
    kraken.methodChannel.clearMethodCallHandler();
  }
  specStarted(result) {
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

let config = {
  oneFailurePerSpec: true,
  failFast: environment.KRAKEN_STOP_ON_FAIL === 'true',
  random: false,
  specFilter: function (spec) {
    return specFilter.matches(spec.getFullName());
  }
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

global.simulatePointer = function simulatePointer(list, pointer) {
  return new Promise((resolve) => {
    requestAnimationFrame(() => {
      if (!Array.isArray(list)) throw new Error('list should be an array');

      list.forEach((value, i) => {
        if (!Array.isArray(value)) throw new Error(`list[${i}] should be an array`);
        if (typeof value[0] != 'number') throw new Error(`list[${i}][0] should be an number`);
        if (typeof value[1] != 'number') throw new Error(`list[${i}][1] should be an number`);
        if (typeof value[2] != 'number') throw new Error(`list[${i}][2] should be an number`);
      });

      __kraken_simulate_pointer__(list, pointer);

      resolve();
    });
  });
}

global.simulateInputText = __kraken_simulate_inputtext__;

function resetDocumentElement() {
  window.scrollTo(0, 0);
  document.removeChild(document.documentElement);
  let html = document.createElement('html');
  document.appendChild(html);

  let head = document.createElement('head');
  document.documentElement.appendChild(head);

  let body = document.createElement('body');
  document.documentElement.appendChild(body);

  document.documentElement.style.backgroundColor = 'white';
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

__kraken_execute_test__((done) => {
  jasmineTracker.onJasmineDone = (result) => {
    done(result.overallStatus);
  };

  // Trigger global js exception to test window.onerror.
  __kraken_trigger_global_error__();

  env.execute();
});
