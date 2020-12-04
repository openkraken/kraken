import { Element } from '../element';
import { method } from '../ui-manager';

const builtInProperties = ['width', 'height'];
/**
 * Use the HTML <canvas> element with either the canvas
 * scripting API or the WebGL API to draw graphics and
 * animations.
 *
 * Attributes:
 * - height: The height of the coordinate space in CSS pixels. Defaults to 150.
 * - width: The width of the coordinate space in CSS pixels. Defaults to 300.
 *
 * Definition: https://html.spec.whatwg.org/multipage/scripting.html#the-canvas-element
 */
export class CanvasElement extends Element {
  constructor() {
    super('canvas', undefined, undefined, builtInProperties);
  }

  getContext(contextType: string) {
    if (contextType === '2d') {
      return new CanvasRenderingContext2D(this);
    } else {
      throw new TypeError(`Canvas not support context type of ${contextType}.`);
    }
  }
}

const GET_CANVAS_CONTEXT = 'getContext';
const UPDATE_CANVAS_CONTEXT_2D_PROPERTY = 'updateContext2DProperty';
const APPLY_CANVAS_CONTEXT_2D_METHOD = 'applyContext2DMethod';
const PROPERTIES = [
  'font',
  'fillStyle',
  'strokeStyle',
];
const METHODS = [
  'fillRect',
  'clearRect',
  'strokeRect',
  'fillText',
  'strokeText',
];

class CanvasRenderingContext2D {
  readonly canvas: CanvasElement;
  constructor(canvas: CanvasElement) {
    this.canvas = canvas;
    // Sync to dart, retain a conext2d instance.
    method(canvas.targetId, GET_CANVAS_CONTEXT, ['2d']);

    // Define context2d properties.
    PROPERTIES.forEach((property) => {
      const shaowPropertyKey = '_' + property;
      this[shaowPropertyKey] = '';
      Object.defineProperty(this, property, {
        enumerable: true,
        get: () => this[shaowPropertyKey],
        set(value: string) {
          method(this.canvas.targetId, UPDATE_CANVAS_CONTEXT_2D_PROPERTY, [
            property, value
          ]);
          this[shaowPropertyKey] = value;
        },
      });
    });

    // Define context2d methods.
    METHODS.forEach((methodName) => {
      this[methodName] = function(...args: Array<any>) {
        return method(this.canvas.targetId, APPLY_CANVAS_CONTEXT_2D_METHOD, [
          methodName, ...args
        ]);
      };
    });
  }
}
