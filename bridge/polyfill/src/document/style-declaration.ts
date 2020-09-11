import {setStyle} from "./ui-manager";

const builtInCSSProperties = [
  'display',
  'position',
  'opacity',
  'z-index',
  'content-visibility',
  'visibility',
  'box-shadow',
  'color',
  'width',
  'height',
  'top',
  'left',
  'right',
  'bottom',
  'min-height',
  'max-height',
  'min-width',
  'max-width',
  'overflow',
  'overflow-x',
  'overflow-y',
  'padding',
  'padding-left',
  'padding-top',
  'padding-right',
  'padding-bottom',
  'margin',
  'margin-left',
  'margin-top',
  'margin-right',
  'margin-bottom',
  'background',
  'background-attachment',
  'background-repeat',
  'background-position',
  'background-image',
  'background-size',
  'background-color',
  'background-origin',
  'background-clip',
  'border',
  'border-top',
  'border-right',
  'border-bottom',
  'border-left',
  'border-width',
  'border-top-width',
  'border-right-width',
  'border-bottom-width',
  'border-left-width',
  'border-style',
  'border-top-style',
  'border-right-style',
  'border-bottom-style',
  'border-left-style',
  'border-color',
  'border-top-color',
  'border-right-color',
  'border-bottom-color',
  'border-left-color',
  'border-radius',
  'border-top-left-radius',
  'border-top-right-radius',
  'border-bottom-right-radius',
  'border-bottom-left-radius',
  'font',
  'font-style',
  'font-weight',
  'font-size',
  'line-height',
  'font-family',
  'vertical-align',
  'text-overflow',
  'text-decoration',
  'text-decoration-line',
  'text-decoration-color',
  'text-decoration-style',
  'text-shadow',
  'letter-spacing',
  'word-spacing',
  'white-space',
  'flex',
  'flex-grow',
  'flex-shrink',
  'flex-basis',
  'flex-flow',
  'flex-direction',
  'flex-wrap',
  'justify-content',
  'text-align',
  'align-items',
  'align-self',
  'align-content',
  'transform',
  'transform-origin',
  'transition',
  'transition-property',
  'transition-duration',
  'transition-timing-function',
  'transition-delay',
  'object-fit',
  'object-position',
];

interface ICamelize {
  (str: string): string;
}

/**
 * Create a cached version of a pure function.
 */
function cached(fn: ICamelize) {
  const cache = Object.create(null);
  return function cachedFn(str : string) {
    const hit = cache[str];
    return hit || (cache[str] = fn(str));
  };
}

/**
 * Camelize a hyphen-delimited string.
 */
const camelize: ICamelize = (str: string) => {
  const camelizeRE = /-(\w)/g;
  return str.replace(camelizeRE, function (_: string, c: string) {
    return c ? c.toUpperCase() : '';
  });
}

// Cached camelize utility
const cachedCamelize = cached(camelize);

export class StyleDeclaration {
  private _internalProperty = {};
  private targetId: number;
  constructor(targetId: number) {
    this.targetId = targetId;
  }
  setProperty(property: string, value: any) {
    const camelizedProperty = cachedCamelize(property);
    this._internalProperty[camelizedProperty] = value;
    setStyle(this.targetId, camelizedProperty, value);
  }
  removeProperty(property: string) {
    const camelizedProperty = cachedCamelize(property);
    setStyle(this.targetId, camelizedProperty, '');
    const originValue = this[camelizedProperty];
    this._internalProperty[camelizedProperty] = '';
    return originValue;
  }
  getPropertyValue(property: string) {
    const camelizedProperty = cachedCamelize(property);
    return this._internalProperty[camelizedProperty];
  }
}

builtInCSSProperties.forEach(property => {
  const camelizeProperty = cachedCamelize(property);

  Object.defineProperty(StyleDeclaration.prototype, property, {
    get() {
      return this.getPropertyValue(property);
    },
    set(value: any) {
      this.setProperty(property, value);
    }
  });

  if (camelizeProperty != property) {
    Object.defineProperty(StyleDeclaration.prototype, camelizeProperty, {
      get() {
        return this.getPropertyValue(camelizeProperty);
      },
      set(value) {
        this.setProperty(camelizeProperty, value);
      }
    });
  }
});
