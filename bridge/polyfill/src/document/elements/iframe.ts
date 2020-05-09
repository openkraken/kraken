import { Element } from '../element';
import { method } from '../ui-manager';

const iframeBuiltInProperties = ['src'];

export class IframeElement extends Element {
  static DEFAULT_WIDTH = 300;
  static DEFAULT_HEIGHT = 150;

  constructor(tagName: string) {
    super(tagName, undefined, [], iframeBuiltInProperties);
  }

  set width(value: number) {
    this.style['width'] = value + 'px';
  }
  get width() {
    return parseInt(this.style['width']) || IframeElement.DEFAULT_WIDTH;
  }

  set height(value: number) {
    this.style['height'] = value + 'px';
  }
  get height() {
    return parseInt(this.style['height']) || IframeElement.DEFAULT_HEIGHT;
  }

  // https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage
  postMessage = (message: string, targetOrigin: string) => {
    method(this.targetId, 'postMessage', [message, targetOrigin]);
  }

  // Compatible to `iframe.contentWindow.postMessage()`
  get contentWindow() : any {
    return { postMessage: this.postMessage };
  }
}
