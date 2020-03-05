import { Element } from '../element';
import { method } from '../UIManager';

export class CanvasElement extends Element {
  constructor(tagName: string) {
    super(tagName);
  }

  play() {
    method(this.nodeId, 'play');
  }

  pause() {
    method(this.nodeId, 'pause');
  }

  fastSeek = (duration: number) => {
    method(this.nodeId, 'fastSeek', [duration]);
  };

  set src(value: string) {
    this.setAttribute('src', value);
  }
  get src() {
    return this.getAttribute('src');
  }

  set autoplay(value: any) {
    this.setAttribute('autoplay', value);
  }
  get autoplay() {
    return this.getAttribute('autoplay');
  }

  set loop(value: any) {
    this.setAttribute('loop', value);
  }
  get loop() {
    return this.getAttribute('loop');
  }

  set poster(value: any) {
    this.setAttribute('poster', value);
  }
  get poster() {
    return this.getAttribute('poster');
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
    method(canvas.nodeId, GET_CANVAS_CONTEXT, ['2d']);

    // Define context2d properties.
    PROPERTIES.forEach((property) => {
      const shaowPropertyKey = '_' + property;
      this[shaowPropertyKey] = '';
      Object.defineProperty(this, property, {
        enumerable: true,
        get: () => this[shaowPropertyKey],
        set(value: string) {
          method(this.canvas.nodeId, UPDATE_CANVAS_CONTEXT_2D_PROPERTY, [
            property, value
          ]);
          this[shaowPropertyKey] = value;
        },
      });
    });

    // Define context2d methods.
    METHODS.forEach((methodName) => {
      this[methodName] = function(...args: Array<any>) {
        return method(this.canvas.nodeId, APPLY_CANVAS_CONTEXT_2D_METHOD, [
          methodName, ...args
        ]);
      };
    });
  }

}
