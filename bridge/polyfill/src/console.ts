/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

// https://console.spec.whatwg.org/
import { webfPrint } from './bridge';

const SEPARATOR = ' ';
const INTERPOLATE = /%[sdifoO]/g;
const DIMENSIONS = 3;
const INDENT = '  ';
const times = {};
const counts = {};
const INDEX = '(index)';
const VALUE = '(value)';
const PLACEHOLDER = ' '; // empty placeholder
let groupIndent = '';

function printer(message: string, level?: string) {
  if (groupIndent.length !== 0) {
    if (message.includes('\n')) {
      message = message.replace(/\n/g, `\n${groupIndent}`);
    }
    message = groupIndent + message;
  }

  webfPrint(message, level);
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
      return `'${obj}'`;
    case 'function':
      break;
    case 'object':
      if (obj === null) {
        return 'null';
      }
      break;
    default:
      return '' + obj;
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
        primitive = `'${obj}'`;
      default:
        primitive = '' + obj; // Use "+" convert undefined to "undefined"
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
    case 'Null':
      return 'null';
    case 'Undefined':
      return 'undefined';
    case 'String':
      return within ? `'${obj}'` : obj;
    case 'Function':
      return 'ƒ ()';
    case 'Number':
    case 'Boolean':
    case 'Date':
    case 'RegExp':
      return obj.toString();
    case 'Array':
      var itemList = obj.map((item: any) => inspect(item, true));
      return '[' + itemList.join(', ') + ']';
    default:
      if (typeof obj === 'object') {
        var prefix;
        if (kind == 'Map') {
          let mapList = Array.from(obj.entries()).map((item: any) => item[0] + ' => ' + inspect(item[1], true)).join(', ');
          return 'Map {' + mapList + '}';
          // return JSON.stringify(Array.from(obj.entries()));
        } else if (kind == 'Set') {
          return 'Set { ' + Array.from(obj).map((item: any) => inspect(item, true)).join(', ') + '}'
        } else if (kind == 'Object') {
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
        return '' + obj;
      }
  }
}

function logger(allArgs: any) {
  var args = Array.prototype.slice.call(allArgs, 0);
  var firstArg = args[0];
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

export const console = {
  log(...args: any) {
    printer(logger(arguments));
  },
  info(...args: any) {
    printer(logger(arguments), 'info');
  },
  warn(...args: any) {
    printer(logger(arguments), 'warn');
  },
  debug(...args: any) {
    printer(logger(arguments), 'debug');
  },
  error(...args: any) {
    printer(logger(arguments), 'error');
  },
  dirxml(...args: any) {
    printer(logger(arguments));
  },
  dir(...args: any) {
    var result = [];
    for (var i = 0; i < arguments.length; i++) {
      result.push(formatter(arguments[i], DIMENSIONS, []));
    }
    printer(result.join(SEPARATOR));
  },
  table(data: Array<any>, filterColumns: Array<string>) {
    if (data === null || typeof data !== 'object') {
      return console.log(data);
    }

    const rows: any[] = [];
    const columns: string[] = [];
    const index: any[] = [];
    let hasValueColumn = false;

    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        let row = data[key];
        index.push(key);
        rows.push(row);
        if (typeof row === 'object' && data !== null) {
          Object.keys(row).forEach(columnName => {
            if (columns.indexOf(columnName) === -1) {
              if (Array.isArray(filterColumns) && filterColumns.length !== 0) {
                if (filterColumns.indexOf(columnName) !== -1) {
                  columns.push(columnName);
                }
              } else {
                columns.push(columnName);
              }
            }
          });
        } else {
          hasValueColumn = true;
        }
      }
    }

    // Unshift (index) or push (value) in columns
    columns.unshift(INDEX);
    if (hasValueColumn) columns.push(VALUE);

    var stringRows: any[] = [];
    var columnWidths: number[] = [];

    // Convert each cell to a string. Also
    // figure out max cell width for each column
    columns.forEach((columnName, columnIndex) => {
      columnWidths[columnIndex] = columnName.length;
      rows.forEach((row, rowIndex) => {
        let cellString: string;

        if (columnName === INDEX) cellString = index[rowIndex];
        else if (row[columnName] !== undefined) cellString = logger([row[columnName]]);
        else if (columnName === VALUE && (row === null || typeof row !== 'object')) cellString = logger([row]);
        else cellString = PLACEHOLDER; // empty

        stringRows[rowIndex] = stringRows[rowIndex] || [];
        stringRows[rowIndex][columnIndex] = cellString;
        // Update to the max length value in column
        columnWidths[columnIndex] = Math.max(columnWidths[columnIndex], cellString.length);
      });
    });

    // Join all elements in the row into a single string with | separators
    // (appends extra spaces to each cell to make separators  | aligned)
    function joinRow(row: any[], space = ' ', sep = '│') {
      var cells = row.map(function (cell, i) {
        var extraSpaces = ' '.repeat(columnWidths[i] - cell.length);
        return cell + extraSpaces;
      });
      return cells.join(space + sep + space);
    }

    var separators = columnWidths.map(function (columnWidth) {
      return '─'.repeat(columnWidth);
    });

    var sep = joinRow(separators, '─', '─');
    var header = joinRow(columns);
    var separatorRow = joinRow(separators, '─');
    var table = [sep, header, separatorRow];

    for (var i = 0; i < rows.length; i++) {
      table.push(joinRow(stringRows[i]));
    }

    table.push(sep);

    console.log(table.join('\n'));
  },
  trace(...args: any) {
    var traceStack = 'Trace:';
    var argsInfo = logger(arguments);
    if (argsInfo) {
      traceStack += (' ' + argsInfo);
    }

    var stack = new Error().stack;
    if (stack) {
      // Compilable with V8 that has Error prefix
      stack = stack.replace(/^Error\n/g, '');
      // Slice the top trace is the current function,
      // and compilable with JSC that without space indent
      stack = stack.split('\n').slice(1).map(line => INDENT + line.trim()).join('\n');
      traceStack += ('\n' + stack);
    }

    printer(traceStack);
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
    if (!expression) {
      let msg = args.join(' ');
      throw new Error('Assertion failed:' + msg);
    }
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
    groupIndent += INDENT;
  },
  groupCollapsed(...data: Array<any>) {
    console.group(...data);
  },
  groupEnd() {
    groupIndent = groupIndent.slice(0, groupIndent.length - 2);
  },
  clear() { }
}
