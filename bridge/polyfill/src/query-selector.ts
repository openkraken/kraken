function fetchSelector(str: string, regex: RegExp) {
  return {
    selectors: str.match(regex) || [],
    ruleStr: str.replace(regex, ' ')
  };
}

function getElementsBySelector(selector: string): Array<Element | null | HTMLElement> {
  let context = document;
  let temp, tempElements: Array<Element> = [], elements: Array<Element> = [];
  selector = selector.trim();

  // If selector starts with *, find all elements.
  if (selector.charAt(0) === '*') {
    let temps: HTMLCollectionOf<Element> = context.getElementsByTagName('*');
    tempElements = Array.from(temps);
  }

  // Classes. e.g. .row.
  let classes: Array<string> = [];
  selector = selector.split(' ').map(item => {
    if (item && item.charAt(0) === '.') {
      temp = fetchSelector(selector, /\.[\w-_]+/g);
      classes = classes.concat(temp.selectors)
      return temp.ruleStr;
    }
    return item;
  }).join(' ');

  // Ids. e.g. #mail-title.
  temp = fetchSelector(selector, /#[\w-_]+/g);
  let id = temp.selectors ? temp.selectors[0] : null;
  selector = temp.ruleStr;

  // Attributes. e.g. [rel=external].
  temp = fetchSelector(selector, /\[.+?\]/g);
  let attributes = temp.selectors;
  selector = temp.ruleStr;

  // Elements. e.g. header, div.
  temp = fetchSelector(selector, /\w+/g);
  let els = temp.selectors;
  selector = temp.ruleStr;

  // Get by id.
  // Id is supposed to be unique.
  // More need to attach other selectors.
  if (id) {
    id = id.substring(1);
    return [document.getElementById(id) || null];
  }

  // Get by Elements.
  if (els.length !== 0) {
    let temps: HTMLCollectionOf<Element> = context.getElementsByTagName(els[0]);
    tempElements = tempElements.concat(Array.from(temps));
  }

  // Get by class name.
  for (let i = 0, l = classes.length; i !== l; ++i) {
    let className = classes[i].substring(1);
    let temps: HTMLCollectionOf<Element> = context.getElementsByClassName(className);
    let arrTemps: Array<Element> = Array.from(temps);
    if (tempElements.length === 0) {
      // If no temp elements yet, push into tempElements directly.
      tempElements = tempElements.concat(arrTemps);
    }
    else {
      // Otherwise, find intersection.
      let prevs: Array<Element> = [];
      prevs = prevs.concat(tempElements);
      tempElements = [];

      for (let index = 0; index < arrTemps.length; index++) {
        let t = arrTemps[index];
        if (prevs.indexOf(t) !== -1) {
          tempElements = tempElements.concat([t]);
        }
      }
    }
  }

  // Get by attributes.
  if (attributes.length !== 0) {
    let attrs = {};
    for (let i = 0; i < attributes.length; i++) {
      let attribute = attributes[i];
      attribute = attribute.substring(1, attribute.length - 1);
      let parts: Array<string> = (attribute.split('=')).map(item => item.trim());
      if (parts[1]) {
        parts[1] = parts[1].substring(1, parts[1].length - 1);
      }
      attrs[parts[0]] = parts[1];
    }
    let prevs: Array<Element> = [];
    prevs = prevs.concat(tempElements);
    tempElements = [];

    for (let i = 0, l = prevs.length; i !== l; ++i) {
      let t = prevs[i];
      let shouldAdd = true;
      for (let key in attrs) {
        let lastChar = key.charAt(key.length - 1);
        if (/[\^\*\$]$/.test(key)) {
          key = key.substring(0, key.length - 1);
        }
        let tempAttr = t.getAttribute(key) || '';
        // Case: [href*=/en].
        if (lastChar === '*' && tempAttr.indexOf(attrs[key + lastChar]) === -1) {
          shouldAdd = false;
          break;
        }
        // Case: [href^=/en].
        else if (lastChar === '^' && tempAttr.indexOf(attrs[key + lastChar]) !== 0) {
          shouldAdd = false;
          break;
        }
        // Case: [href$=/en].
        else if (lastChar === '$' &&
          (tempAttr.lastIndexOf(attrs[key + lastChar]) === -1
            ? false
            : tempAttr.lastIndexOf(attrs[key + lastChar]))
          !==
          tempAttr.length - attrs[key + lastChar].length) {
          shouldAdd = false;
          break;
        }
        // Case: [href=/en].
        else if (/[\$\*\^]/.test(lastChar) === false && tempAttr !== attrs[key]) {
          shouldAdd = false;
          break;
        }

      }

      if (shouldAdd) {
        tempElements = tempElements.concat([t]);
      }
    }
  }

  elements = elements.concat(tempElements);
  return elements;
}

document.querySelectorAll = function <E extends Element = Element>(selector: string): NodeListOf<E> {
  if (typeof selector !== 'string') {
    throw new TypeError('document.querySelectorAll: Invalid selector type. ' +
      'Expect: string. Found: ' + typeof selector + '.');
  }
  let elements: Array<E> = [];

  // Split `selector` into rules by `,`.
  let rules: Array<string> = selector.split(',').map(item => item.trim());

  // Iterate through each rule.
  // For the sake of performance, use for-loop here rather than forEach.
  for (let i = 0, l = rules.length; i !== l; ++i) {
    let rule = rules[i];

    // TODO: support ' ' and '>'.
    elements = elements.concat(getElementsBySelector.call(this, rule));
  }

  return (elements as any) as NodeListOf<E>;
};

document.querySelector = function (selector: string): Element | null {
  if (typeof selector !== 'string') {
    throw new TypeError('document.querySelector: Invalid selector type. ' +
      'Expect: string. Found: ' + typeof selector + '.');
  }
  let elements = this.querySelectorAll(selector);
  return elements.length > 0 ? elements[0] : null;
}
