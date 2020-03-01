// https://console.spec.whatwg.org/
import { krakenPrint } from './kraken';

const SEPARATOR = ' ';
const INTERPOLATE = /%[sdifoO]/g;
const DIMENSIONS = 3;
const INDENT = '  ';
const times = {};
const counts = {};
let groupIndent = '';

function printer(message: string, level?: string) {
  if (groupIndent.length !== 0) {
    if (message.includes('\n')) {
      message = message.replace(/\n/g, `\n${groupIndent}`);
    }
    message = groupIndent + message;
  }

  krakenPrint(message, level);
}

/**
 * formatter({x:2, y:8}) === '{x: 2, y: 8}'
 * @param {*} obj
 * @param {Number} limit dimension of objects
 * @param {Array} stack of parent objects
 * @return {String} string representation of input
 */
function formatter(obj: any, limit: number, stack: Array<any>): string {
  var type = typeof obj;
  switch (type) {
    case 'string':
      return `"${obj}"`;
    case 'function':
      break;
    case 'object':
      if (obj === null) {
        return 'null';
      }
      break;
    default:
      return obj.toString();
  }

  var prefix;
  var kind = Object.prototype.toString.call(obj).slice(8, -1);
  if (kind == 'Object') {
    prefix = '';
  } else {
    prefix = kind + ' ';
    var primitive;
    switch (typeof obj) {
      case 'object':
      case 'function':
        break;
      case 'string':
        primitive = `"${obj}"`;
      default:
        primitive = obj.toString();
    }
    if (primitive) {
      prefix += primitive + ' ';
    }
  }

  if (!limit) {
    return prefix + '{...}';
  }
  // Check circular references
  var stackLength = stack.length;
  for (var s = 0; s < stackLength; s++) {
    if (stack[s] === obj) {
      return '#';
    }
  }
  stack[stackLength++] = obj;
  var indent = INDENT.repeat(stackLength);
  var keys = Object.getOwnPropertyNames(obj);

  var result = prefix + '{';
  if (!keys.length) {
    return result + '}';
  }

  var items = [];
  for (var n = 0; n < keys.length; n++) {
    let key = keys[n];
    var value = formatter(obj[key], limit - 1, [...stack]);
    items.push('\n' + indent + key + ': ' + value);
  }
  return result + items.join(', ') + '\n' + INDENT.repeat(stackLength - 1) + '}';
}

function inspect(obj: any, within?: boolean): string {
  var result = '';

  if (Object(obj) !== obj) {
    if (within && typeof obj == 'string') {
      return '"' + obj + '"';
    }
    return obj;
  }

  if (obj && obj.nodeType == 1) {
    // Is element?
    result = '<' + obj.tagName.toLowerCase();
    for (var i = 0, ii = obj.attributes.length; i < ii; i++) {
      if (obj.attributes[i].specified) {
        result += ' ' + obj.attributes[i].name + '="' + obj.attributes[i].value + '"';
      }
    }
    if (obj.childNodes && obj.childNodes.length === 0) {
      result += '/';
    }
    return result + '>';
  }

  var kind = Object.prototype.toString.call(obj).slice(8, -1);
  switch (kind) {
    case 'String':
      return `"${obj}"`;
    case 'Function':
      return 'ƒ ()';
    case 'Number':
    case 'Boolean':
    case 'Date':
    case 'RegExp':
      return obj.toString();
    case 'Array':
    case 'HTMLCollection':
    case 'NodeList':
      // Is array-like object?
      result = kind == 'Array' ? '[' : kind + ' [';
      var itemList = [];
      for (var j = 0, jj = obj.length; j < jj; j++) {
        itemList[j] = inspect(obj[j], true);
      }
      return result + itemList.join(', ') + ']';
    default:
      if (typeof obj === 'object') {
        var prefix;
        if (kind == 'Object') {
          prefix = '';
        } else {
          prefix = kind + ' ';
        }
        if (within) {
          return prefix + '{...}';
        }
        if (Object.getOwnPropertyNames) {
          var keys = Object.getOwnPropertyNames(obj);
        } else {
          keys = [];
          for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
              keys.push(key);
            }
          }
        }
        result = prefix + '{';
        if (!keys.length) {
          return result + "}";
        }
        keys = keys.sort();
        var properties = [];
        for (var n = 0; n < keys.length; n++) {
          key = keys[n];
          try {
            var value = inspect(obj[key], true);
            properties.push(key + ': ' + value);
          } catch (e) { }
        }
        return result + properties.join(', ') + '}';
      } else {
        return obj.toString();
      }
  }
}

function logger(firstArg: any, allArgs: IArguments) {
  var args = Array.prototype.slice.call(allArgs, 0);
  var result = [];
  if (typeof firstArg === 'string' && INTERPOLATE.test(firstArg)) {
    args.shift();
    result.push(firstArg.replace(INTERPOLATE, function () {
      return inspect(args.shift());
    }));
  }
  for (var i = 0; i < args.length; i++) {
    result.push(inspect(args[i]));
  }
  return result.join(SEPARATOR);
}

const console = {
  log(...args: any) {
    printer(logger(arguments[0], arguments));
  },
  info(...args: any) {
    printer(logger(arguments[0], arguments), 'info');
  },
  warn(...args: any) {
    printer(logger(arguments[0], arguments), 'warn');
  },
  debug(...args: any) {
    printer(logger(arguments[0], arguments), 'debug');
  },
  error(...args: any) {
    printer(logger(arguments[0], arguments), 'error');
  },
  dirxml(...args: any) {
    printer(logger(arguments[0], arguments));
  },
  dir(...args: any) {
    var result = [];
    for (var i = 0; i < arguments.length; i++) {
      result.push(formatter(arguments[i], DIMENSIONS, []));
    }
    printer(result.join(SEPARATOR));
  },
  table(data: any, columns: Array<string>) {
    console.dir(data);
  },
  trace(...args: any) {
    var traceStack: Array<string> = ['Trace: '];
    var argsInfo = logger(arguments[0], arguments);
    if (argsInfo) {
      traceStack.push(argsInfo);
    }

    var stack = new Error().stack;
    if (stack) {
      traceStack.concat(stack.split('\n').slice(1));
    }

    printer(traceStack.join('\n'));
  },
  // Defined by: https://console.spec.whatwg.org/#count
  count(label = 'default') {
    label = String(label);
    if (counts[label] === undefined) {
      counts[label] = 1;
    } else {
      counts[label]++;
    }
    console.info(label + ' ' + counts[label]);
  },
  // Defined by: https://console.spec.whatwg.org/#countreset
  countReset(label = 'default') {
    label = String(label);
    if (counts[label] === undefined) {
      console.warn(`Count for '${label}' does not exist`);
    } else {
      counts[label] = 0;
    }
  },
  assert(expression: boolean, ...args: Array<any>) {
    if (!expression) console.error('Assertion failed:', ...args);
  },
  time(label = 'default') {
    label = String(label);
    if (times[label] === undefined) {
      times[label] = (new Date).getTime();
    } else {
      console.warn(`Timer '${label}' already exists`);
    }
  },
  timeLog(label = 'default', ...args: Array<any>) {
    label = String(label);
    var start = times[label];
    if (start) {
      var end = (new Date).getTime();
      console.log(label + ': ' + (end - start) + 'ms', ...args);
    } else {
      console.warn(`Timer '${label}' does not exist`);
    }
  },
  timeEnd(label = 'default') {
    label = String(label);
    var start = times[label];
    if (start) {
      var end = (new Date).getTime();
      console.info(label + ': ' + (end - start) + 'ms');
      delete times[label];
    } else {
      console.warn(`Timer '${label}' does not exist`);
    }
  },
  group(...data: Array<any>) {
    if (data.length > 0) {
      console.log(...data);
    }
    groupIndent += '  ';
  },
  groupCollapsed(...data: Array<any>) {
    console.group(...data);
  },
  groupEnd() {
    groupIndent = groupIndent.slice(0, groupIndent.length - 2);
  },
  clear() { }
}

Object.defineProperty(global, 'console', {
  enumerable: true,
  writable: false,
  value: console,
  configurable: false
});
