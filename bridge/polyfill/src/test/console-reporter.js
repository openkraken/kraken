module.exports = exports = ConsoleReporter;

function ConsoleReporter() {
  var print = function () { },
    printError = function () { },
    showColors = false,
    jasmineCorePath = null,
    specCount,
    executableSpecCount,
    failureCount,
    failedSpecs = [],
    pendingSpecs = [],
    ansi = {
      green: '\x1B[32m',
      red: '\x1B[31m',
      yellow: '\x1B[33m',
      none: '\x1B[0m'
    },
    failedSuites = [],
    stackFilter = defaultStackFilter;

  this.setOptions = function (options) {
    if (options.print) print = options.print;
    if (options.printError) printError = options.printError;

    showColors = options.showColors || false;
    if (options.jasmineCorePath) {
      jasmineCorePath = options.jasmineCorePath;
    }
    if (options.stackFilter) {
      stackFilter = options.stackFilter;
    }
  };

  this.jasmineStarted = function (options) {
    specCount = 0;
    executableSpecCount = 0;
    failureCount = 0;
    if (options && options.order && options.order.random) {
      print('Randomized with seed ' + options.order.seed);
      printNewline();
    }
    printNewline();
  };

  this.jasmineDone = function (result) {
    printNewline();
    printNewline();

    if (pendingSpecs.length > 0) {
      print("Pending:");
    }
    for (i = 0; i < pendingSpecs.length; i++) {
      pendingSpecDetails(pendingSpecs[i], i + 1);
    }

    if (failedSpecs.length > 0) {
      printError('Failures:');
    }
    for (var i = 0; i < failedSpecs.length; i++) {
      specFailureDetails(failedSpecs[i], i + 1);
    }

    for (i = 0; i < failedSuites.length; i++) {
      suiteFailureDetails(failedSuites[i]);
    }

    if (result && result.failedExpectations && result.failedExpectations.length > 0) {
      suiteFailureDetails(result);
    }

    if (specCount > 0) {
      printNewline();

      if (executableSpecCount !== specCount) {
        print('Ran ' + executableSpecCount + ' of ' + specCount + plural(' spec', specCount));
        printNewline();
      }
      var specCounts = executableSpecCount + ' ' + plural('spec', executableSpecCount) + ', ' +
        failureCount + ' ' + plural('failure', failureCount);

      if (pendingSpecs.length) {
        specCounts += ', ' + pendingSpecs.length + ' pending ' + plural('spec', pendingSpecs.length);
      }

      print(specCounts);
    } else {
      print('No specs found');
    }

    printNewline();
    var seconds = result ? result.totalTime / 1000 : 0;
    print('Finished in ' + seconds + ' ' + plural('second', seconds));
    printNewline();

    if (result && result.overallStatus === 'incomplete') {
      print('Incomplete: ' + result.incompleteReason);
      printNewline();
    }

    if (result && result.order && result.order.random) {
      print('Randomized with seed ' + result.order.seed);
      print(' (jasmine --random=true --seed=' + result.order.seed + ')');
      printNewline();
    }
  };

  this.specDone = function (result) {
    specCount++;

    if (result.status == 'pending') {
      pendingSpecs.push(result);
      executableSpecCount++;
      return;
    }

    if (result.status == 'passed') {
      print(colored('green', 'PASS: ') + result.fullName);
      printNewline();
      executableSpecCount++;
      return;
    }

    if (result.status == 'failed') {
      print(colored('red', 'FAIL: ') + result.fullName);
      printNewline();
      result.failedExpectations && result.failedExpectations.forEach((failedExpectation) => {
        print('    Message: ' + colored('red', failedExpectation.message));
        printNewline();
      });
      failureCount++;
      failedSpecs.push(result);
      executableSpecCount++;
    }
  };

  this.suiteDone = function (result) {
    if (result.failedExpectations && result.failedExpectations.length > 0) {
      failureCount++;
      failedSuites.push(result);
    }
  };

  return this;

  function printNewline() {
    print('\n');
  }

  function printErrorNewline() {
    printError('\n');
  }


  function colored(color, str) {
    return showColors ? (ansi[color] + str + ansi.none) : str;
  }

  function plural(str, count) {
    return count == 1 ? str : str + 's';
  }

  function repeat(thing, times) {
    var arr = [];
    for (var i = 0; i < times; i++) {
      arr.push(thing);
    }
    return arr;
  }

  function indent(str, spaces) {
    var lines = (str || '').split('\n');
    var newArr = [];
    for (var i = 0; i < lines.length; i++) {
      newArr.push(repeat(' ', spaces).join('') + lines[i]);
    }
    return newArr.join('\n');
  }

  function defaultStackFilter(stack) {
    if (!stack) {
      return '';
    }

    var filteredStack = stack.split('\n').filter(function (stackLine) {
      return stackLine.indexOf(jasmineCorePath) === -1;
    }).join('\n');
    return filteredStack;
  }

  function specFailureDetails(result, failedSpecNumber) {
    printErrorNewline();
    printError(failedSpecNumber + ') ');
    printError(result.fullName);
    printFailedExpectations(result);
  }

  function suiteFailureDetails(result) {
    printErrorNewline();
    printError('Suite error: ' + result.fullName);
    printFailedExpectations(result);
  }

  function printFailedExpectations(result) {
    for (var i = 0; i < result.failedExpectations.length; i++) {
      var failedExpectation = result.failedExpectations[i];
      printErrorNewline();
      printError(indent('Message:', 2));
      printErrorNewline();
      printError(colored('red', indent(failedExpectation.message, 4)));
      printErrorNewline();
      printError(indent('Stack:', 2));
      printErrorNewline();
      printError(indent(stackFilter(failedExpectation.stack), 4));
    }

    printErrorNewline();
  }

  function pendingSpecDetails(result, pendingSpecNumber) {
    printNewline();
    print(pendingSpecNumber + ') ');
    print(result.fullName);
    printNewline();
    var pendingReason = "No reason given";
    if (result.pendingReason && result.pendingReason !== '') {
      pendingReason = result.pendingReason;
    }
    print(indent(colored('yellow', pendingReason), 2));
    printNewline();
  }
}
