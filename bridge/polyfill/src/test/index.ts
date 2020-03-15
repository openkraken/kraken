const jasmineCore = require('./jasmine.js');
const ConsoleReporter = require('./console_reporter.js');
const jasmine = jasmineCore.core(jasmineCore);
const env = jasmine.getEnv({suppressLoadErrors: true});
const jasmineInterface = jasmineCore.interface(jasmine, env);

const consoleReporter = new ConsoleReporter();

let printCache = '';
function handlePrint(msg: string) {
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
  print: (msg: string) => {
    handlePrint(msg);
  },
  showColors: true,
  random: false,
  jasmineCorePath: 'internal://'
});

env.addReporter(consoleReporter);
Object.assign(global, jasmineInterface);

type KrakenExecuteTest = (fn: (done: (status: boolean) => void) => void) => void;
declare const __kraken_executeTest__: KrakenExecuteTest;

__kraken_executeTest__((done) => {
  env.execute(null, (status: boolean) => {
    console.log('jasmine finished', status);
    console.log(typeof status);
    done(status);
  });
  // done();
});